package cems;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EquipmentDAO {

    /**
     * Helper to generate the next ID (e.g., E001, E002)
     * PostgreSQL uses LIMIT 1 instead of FETCH FIRST.
     */
    private static String generateNextId(Connection conn) throws SQLException {
        String sql = "SELECT eqpID FROM EQUIPMENT ORDER BY LENGTH(eqpID) DESC, eqpID DESC LIMIT 1";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String lastId = rs.getString("eqpID");
                int numericPart = Integer.parseInt(lastId.replaceAll("[^0-9]", ""));
                int nextId = numericPart + 1;
                return String.format("E%03d", nextId); 
            } else {
                return "E001";
            }
        }
    }

    /**
     * CREATE - Add new equipment with transaction support
     */
    public static boolean addEquipment(Equipment eqp) {
        String sqlParent = "INSERT INTO EQUIPMENT (EQPID, EQPNAME, EQPQTY, EQPIMAGE, " +
                           "TOTQTYAVAILABLE, EQPTOTQTY, TOTQTYINUSE, EQPTOTDAMAGE, EQPTOTLOST) " +
                           "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0)";
        Connection conn = null;

        try {
            conn = ConnectionManager.getConnection();
            conn.setAutoCommit(false); 

            String nextId = generateNextId(conn);

            try (PreparedStatement psParent = conn.prepareStatement(sqlParent)) {
                psParent.setString(1, nextId);
                psParent.setString(2, eqp.getEqpName());
                psParent.setInt(3, eqp.getEqpQty());
                psParent.setString(4, eqp.getEqpImage());
                psParent.setInt(5, eqp.getEqpQty()); 
                psParent.setInt(6, eqp.getEqpQty()); 

                psParent.executeUpdate();

                // Handle Subclasses
                if (eqp instanceof ServiceEquipment) {
                    String val = ((ServiceEquipment) eqp).getServiceSet();
                    if (val == null) val = "GUEST"; 
                    String sqlChild = "INSERT INTO SERVICEEQUIPMENT (EQPID, SERVICESET) VALUES (?, ?)";
                    try (PreparedStatement psChild = conn.prepareStatement(sqlChild)) {
                        psChild.setString(1, nextId);
                        psChild.setString(2, val);
                        psChild.executeUpdate();
                    }
                } else if (eqp instanceof SupportEquipment) {
                    String val = ((SupportEquipment) eqp).getEqpFunction();
                    if (val == null) val = "STORAGE";
                    String sqlChild = "INSERT INTO SUPPORTEQUIPMENT (EQPID, EQPFUNCTION) VALUES (?, ?)";
                    try (PreparedStatement psChild = conn.prepareStatement(sqlChild)) {
                        psChild.setString(1, nextId);
                        psChild.setString(2, val);
                        psChild.executeUpdate();
                    }
                }

                conn.commit(); 
                System.out.println("Equipment added successfully: " + nextId);
                return true;
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    /**
     * READ - Get All Equipment
     * Uses PostgreSQL CURRENT_DATE and ::DATE casting
     */
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION, " +
                     "  (SELECT COALESCE(SUM(ee.QTYINUSE), 0) " +
                     "   FROM EVENTEQUIPMENT ee " +
                     "   JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "   WHERE ee.EQPID = e.EQPID " +
                     "   AND ev.EVENTDATE::DATE = CURRENT_DATE " + 
                     "   AND ee.RETURNSTATUS = 'N' " +
                     "  ) AS DAY_QTY_IN_USE " + 
                     "FROM EQUIPMENT e " +
                     "LEFT JOIN SERVICEEQUIPMENT s ON e.EQPID = s.EQPID " +
                     "LEFT JOIN SUPPORTEQUIPMENT su ON e.EQPID = su.EQPID " + 
                     "ORDER BY e.EQPID ASC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Equipment eqp;
                String serviceSet = rs.getString("SERVICESET");
                if (serviceSet != null) {
                    ServiceEquipment s = new ServiceEquipment();
                    s.setServiceSet(serviceSet);
                    eqp = s;
                } else {
                    SupportEquipment su = new SupportEquipment();
                    su.setEqpFunction(rs.getString("EQPFUNCTION"));
                    eqp = su;
                }

                eqp.setEqpID(rs.getString("EQPID"));
                eqp.setEqpName(rs.getString("EQPNAME"));
                eqp.setEqpQty(rs.getInt("EQPQTY"));
                eqp.setEqpImage(rs.getString("EQPIMAGE"));
                eqp.setTotQtyInUse(rs.getInt("DAY_QTY_IN_USE")); 
                eqp.setTotQtyAvailable(rs.getInt("TOTQTYAVAILABLE")); 
                eqp.setEqpTotQty(rs.getInt("EQPTOTQTY"));
                eqp.setEqpTotDamage(rs.getInt("EQPTOTDAMAGE"));
                eqp.setEqpTotLost(rs.getInt("EQPTOTLOST"));
                
                list.add(eqp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * UPDATE - Update Base Quantity and sync totals
     */
    public static boolean updateEquipmentQty(String id, int qty) {
        String sqlSelect = "SELECT EQPQTY FROM EQUIPMENT WHERE EQPID = ?";
        String sqlUpdate = "UPDATE EQUIPMENT SET EQPQTY = ?, TOTQTYAVAILABLE = TOTQTYAVAILABLE + ?, EQPTOTQTY = EQPTOTQTY + ? WHERE EQPID = ?";
        
        try (Connection conn = ConnectionManager.getConnection()) {
            int oldQty = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setString(1, id);
                try(ResultSet rs = ps.executeQuery()){
                    if(rs.next()) oldQty = rs.getInt("EQPQTY");
                }
            }
            
            int difference = qty - oldQty; 
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setInt(1, qty);
                ps.setInt(2, difference);
                ps.setInt(3, difference);
                ps.setString(4, id);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Dashboard Statistics: Equipment Loss Rate
     */
    public static double getEquipmentLossRate() {
        double rate = 0.0;
        String query = "SELECT (SUM(EQPTOTDAMAGE + EQPTOTLOST) * 100.0 / NULLIF(SUM(EQPTOTQTY), 0)) FROM EQUIPMENT";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) rate = rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return rate;
    }

    /**
     * Chart Data: Categorized condition
     * Note: PostgreSQL requires subqueries in FROM to have an alias (e.g., "sub")
     */
    public static String getCategorizedConditionStats() {
        StringBuilder labels = new StringBuilder();
        StringBuilder good = new StringBuilder();
        StringBuilder damaged = new StringBuilder();
        StringBuilder lost = new StringBuilder();

        String query = 
            "SELECT category, SUM(totQtyAvailable) as good, SUM(eqpTotDamage) as damage, SUM(eqpTotLost) as lost " +
            "FROM (" +
            "  SELECT s.serviceSet as category, e.totQtyAvailable, e.eqpTotDamage, e.eqpTotLost " +
            "  FROM Equipment e JOIN ServiceEquipment s ON e.eqpID = s.eqpID " +
            "  UNION ALL " +
            "  SELECT p.eqpFunction as category, e.totQtyAvailable, e.eqpTotDamage, e.eqpTotLost " +
            "  FROM Equipment e JOIN SupportEquipment p ON e.eqpID = p.eqpID " +
            ") sub GROUP BY category";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    labels.append(","); good.append(","); damaged.append(","); lost.append(",");
                }
                labels.append("'").append(rs.getString("category")).append("'");
                good.append(rs.getInt("good"));
                damaged.append(rs.getInt("damage"));
                lost.append(rs.getInt("lost"));
                first = false;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return labels + "|" + good + "|" + damaged + "|" + lost;
    }

    /**
     * Report Summary: Damages and Losses within date range
     */
    public Map<String, Object> getEquipmentIssueSummary(String start, String end) throws SQLException {
        Map<String, Object> summary = new HashMap<>();
        List<Map<String, Object>> details = new ArrayList<>();
        
        String sql = "SELECT e.EQPID, e.EQPNAME, e.TOTQTYINUSE, ee.QTYINUSE, ee.QTYRETURN, ee.QTYDAMAGE, ee.QTYLOST, " +
                     "COALESCE(s.SERVICESET, su.EQPFUNCTION, '-') AS EQP_TYPE " +
                     "FROM EQUIPMENT e " +
                     "JOIN EVENTEQUIPMENT ee ON e.EQPID = ee.EQPID " +
                     "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "LEFT JOIN SERVICEEQUIPMENT s ON e.EQPID = s.EQPID " + 
                     "LEFT JOIN SUPPORTEQUIPMENT su ON e.EQPID = su.EQPID " +
                     "WHERE ev.EVENTDATE BETWEEN ?::DATE AND ?::DATE " +
                     "AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0) " +
                     "ORDER BY e.EQPID ASC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, start);
            ps.setString(2, end);
            
            long tAssigned = 0, tReturned = 0, tDamaged = 0, tLost = 0;
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    int totQtyInUse = rs.getInt("TOTQTYINUSE");
                    int returned = rs.getInt("QTYRETURN");
                    int damaged = rs.getInt("QTYDAMAGE"); 
                    int lost = rs.getInt("QTYLOST");

                    tAssigned += totQtyInUse;
                    tReturned += returned;
                    tDamaged += damaged;
                    tLost += lost;

                    row.put("id", rs.getString("EQPID"));
                    row.put("name", rs.getString("EQPNAME"));
                    row.put("type", rs.getString("EQP_TYPE"));
                    row.put("damaged", damaged);
                    row.put("lost", lost);
                    details.add(row);
                }
            }
            summary.put("details", details);
            summary.put("totalAssigned", tAssigned);
            summary.put("totalReturned", tReturned);
            summary.put("totalDamaged", tDamaged);
            summary.put("totalLost", tLost);
        }
        return summary;
    }

    /**
     * Usage History for specific item
     */
    public List<Map<String, Object>> getUsageHistory(String eqpID) {
        List<Map<String, Object>> history = new ArrayList<>();
        String sql = "SELECT s.STAFFNAME, ev.EVENTNAME, ev.EVENTDATE, ee.QTYDAMAGE, ee.QTYLOST " +
                     "FROM EVENTEQUIPMENT ee " +
                     "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "LEFT JOIN STAFF s ON ev.STAFFID = s.STAFFID " + 
                     "WHERE ee.EQPID = ? AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0) " +
                     "ORDER BY ev.EVENTDATE DESC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eqpID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("staffName", rs.getString("STAFFNAME"));
                    row.put("eventName", rs.getString("EVENTNAME"));
                    row.put("eventDate", rs.getDate("EVENTDATE"));
                    row.put("qtyDamage", rs.getInt("QTYDAMAGE"));
                    row.put("qtyLost", rs.getInt("QTYLOST"));
                    history.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return history;
    }

    /**
     * Sync local EQUIPMENT table totals with log table
     */
    public void syncEquipmentTotals(String eqpID) {
        String sql = "UPDATE EQUIPMENT e SET " +
                     "e.EQPTOTDAMAGE = (SELECT COALESCE(SUM(ee.QTYDAMAGE), 0) FROM EVENTEQUIPMENT ee WHERE ee.EQPID = ?), " +
                     "e.EQPTOTLOST = (SELECT COALESCE(SUM(ee.QTYLOST), 0) FROM EVENTEQUIPMENT ee WHERE ee.EQPID = ?) " +
                     "WHERE e.EQPID = ?";
                     
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eqpID);
            ps.setString(2, eqpID);
            ps.setString(3, eqpID);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /**
     * Check how many items are booked for a specific future date
     */
    public int getBookedQtyOnDate(String eqpID, String eventDateStr) { 
        int bookedQty = 0;
        String sql = "SELECT SUM(ee.QTYINUSE) FROM EVENTEQUIPMENT ee " +
                     "JOIN EVENT e ON ee.EVENTID = e.EVENTID " +
                     "WHERE ee.EQPID = ? " +
                     "AND e.EVENTDATE = ?::DATE " + 
                     "AND e.IS_DELETED = 0"; 

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eqpID);
            ps.setDate(2, java.sql.Date.valueOf(eventDateStr)); 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) bookedQty = rs.getInt(1); 
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return bookedQty;
    }
}