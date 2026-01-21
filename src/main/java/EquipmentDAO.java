package cems;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class EquipmentDAO {

    // Helper to generate the next ID (e.g., E001, E002)
    private static String generateNextId(Connection conn) throws SQLException {
        // PostgreSQL: Use LIMIT 1 and LENGTH()
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

    // CREATE - Add new equipment
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

    // READ - Get All Equipment
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        
        // PostgreSQL: Use CURRENT_DATE or ev.EVENTDATE::date
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION, " +
                     "  (SELECT COALESCE(SUM(ee.QTYINUSE), 0) " +
                     "   FROM EVENTEQUIPMENT ee " +
                     "   JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "   WHERE ee.EQPID = e.EQPID " +
                     "   AND ev.EVENTDATE::date = CURRENT_DATE " + 
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
                String supportFunc = rs.getString("EQPFUNCTION");
                
                if (serviceSet != null) {
                    ServiceEquipment s = new ServiceEquipment();
                    s.setServiceSet(serviceSet);
                    eqp = s;
                } else {
                    SupportEquipment su = new SupportEquipment();
                    su.setEqpFunction(supportFunc);
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

    // READ - Get Single Equipment by ID
    public Equipment getEquipmentById(String id) {
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION, " +
                     "  (SELECT COALESCE(SUM(ee.QTYINUSE), 0) " +
                     "   FROM EVENTEQUIPMENT ee " +
                     "   JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "   WHERE ee.EQPID = e.EQPID " +
                     "   AND ev.EVENTDATE::date = CURRENT_DATE " + 
                     "   AND ee.RETURNSTATUS = 'N' " +
                     "  ) AS DAY_QTY_IN_USE " +
                     "FROM EQUIPMENT e " +
                     "LEFT JOIN SERVICEEQUIPMENT s ON e.EQPID = s.EQPID " +
                     "LEFT JOIN SUPPORTEQUIPMENT su ON e.EQPID = su.EQPID " +
                     "WHERE e.EQPID = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Equipment eqp;
                    String serviceVal = rs.getString("SERVICESET");
                    if (serviceVal != null) {
                        ServiceEquipment s = new ServiceEquipment();
                        s.setServiceSet(serviceVal);
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
                    return eqp;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public static boolean updateEquipmentQty(String id, int qty) {
        String sqlSelect = "SELECT EQPQTY FROM EQUIPMENT WHERE EQPID = ?";
        // PostgreSQL standard update
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
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public static double getEquipmentLossRate() {
        double rate = 0.0;
        // PostgreSQL: Use NULLIF to avoid division by zero; 100.0 ensures float division
        String query = "SELECT (SUM(EQPTOTDAMAGE + EQPTOTLOST) * 100.0 / NULLIF(SUM(EQPTOTQTY), 0)) FROM EQUIPMENT";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) rate = rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return rate;
    }

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
            ") sub GROUP BY category"; // PostgreSQL requires aliases for subqueries

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

    public Map<String, Object> getEquipmentIssueSummary(String start, String end) throws SQLException {
        Map<String, Object> summary = new HashMap<>();
        List<Map<String, Object>> details = new ArrayList<>();
        
        // PostgreSQL: TO_DATE works, but usually casted or compared via date 'YYYY-MM-DD'
        String sql = "SELECT e.EQPID, e.EQPNAME, e.TOTQTYINUSE, ee.QTYINUSE, ee.QTYRETURN, ee.QTYDAMAGE, ee.QTYLOST, " +
                     "COALESCE(s.SERVICESET, su.EQPFUNCTION, '-') AS EQP_TYPE " +
                     "FROM EQUIPMENT e " +
                     "JOIN EVENTEQUIPMENT ee ON e.EQPID = ee.EQPID " +
                     "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "LEFT JOIN SERVICEEQUIPMENT s ON e.EQPID = s.EQPID " + 
                     "LEFT JOIN SUPPORTEQUIPMENT su ON e.EQPID = su.EQPID " +
                     "WHERE ev.EVENTDATE BETWEEN ?::date AND ?::date " +
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
                    int totInUse = rs.getInt("TOTQTYINUSE");
                    tAssigned += totInUse;
                    tReturned += rs.getInt("QTYRETURN");
                    tDamaged += rs.getInt("QTYDAMAGE");
                    tLost += rs.getInt("QTYLOST");

                    row.put("id", rs.getString("EQPID"));
                    row.put("name", rs.getString("EQPNAME"));
                    row.put("type", rs.getString("EQP_TYPE"));
                    row.put("damaged", rs.getInt("QTYDAMAGE"));
                    row.put("lost", rs.getInt("QTYLOST"));
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

    public void syncEquipmentTotals(String eqpID) {
        // PostgreSQL: Update without alias 'e' in SET clause
        String sql = "UPDATE EQUIPMENT SET " +
                     "EQPTOTDAMAGE = (SELECT COALESCE(SUM(ee.QTYDAMAGE), 0) FROM EVENTEQUIPMENT ee WHERE ee.EQPID = ?), " +
                     "EQPTOTLOST = (SELECT COALESCE(SUM(ee.QTYLOST), 0) FROM EVENTEQUIPMENT ee WHERE ee.EQPID = ?) " +
                     "WHERE EQPID = ?";
                     
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eqpID);
            ps.setString(2, eqpID);
            ps.setString(3, eqpID);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public int getBookedQtyOnDate(String eqpID, String eventDateStr) { 
        int bookedQty = 0;
        // PostgreSQL: Direct date comparison
        String sql = "SELECT SUM(ee.QTYINUSE) FROM EVENTEQUIPMENT ee " +
                     "JOIN EVENT e ON ee.EVENTID = e.EVENTID " +
                     "WHERE ee.EQPID = ? " +
                     "AND e.EVENTDATE::date = ?::date " + 
                     "AND e.IS_DELETED = 0"; 

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eqpID);
            ps.setString(2, eventDateStr); 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) bookedQty = rs.getInt(1); 
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return bookedQty;
    }
}