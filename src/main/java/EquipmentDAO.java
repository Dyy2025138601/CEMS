package cems;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EquipmentDAO {

    // Helper to generate the next ID (e.g., E001, E002)
    private static String generateNextId(Connection conn) throws SQLException {
        // Oracle compatible fetch
        String sql = "SELECT eqpID FROM EQUIPMENT ORDER BY LENGTH(eqpID) DESC, eqpID DESC FETCH FIRST 1 ROWS ONLY";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String lastId = rs.getString("eqpID");
                int numericPart = Integer.parseInt(lastId.replaceAll("[^0-9]", ""));
                int nextId = numericPart + 1;
                return String.format("E%03d", nextId); 
            } else {
                return "E001"; // Default start ID
            }
        }
    }
    // CREATE - Add new equipment
    public static boolean addEquipment(Equipment eqp) {
        
        // FIX: Insert into tracking columns immediately. 
        // We initialize Available and TotalAsset to match the Input Quantity.
        String sqlParent = "INSERT INTO EQUIPMENT (EQPID, EQPNAME, EQPQTY, EQPIMAGE, " +
                           "TOTQTYAVAILABLE, EQPTOTQTY, TOTQTYINUSE, EQPTOTDAMAGE, EQPTOTLOST) " +
                           "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0)";
        Connection conn = null;

        try {
            conn = ConnectionManager.getConnection();
            conn.setAutoCommit(false); 

            // Generate ID
            String nextId = generateNextId(conn);

            try (PreparedStatement psParent = conn.prepareStatement(sqlParent)) {
                psParent.setString(1, nextId);
                psParent.setString(2, eqp.getEqpName());
                psParent.setInt(3, eqp.getEqpQty());
                psParent.setString(4, eqp.getEqpImage());
                
                // Initialize Tracking Data
                psParent.setInt(5, eqp.getEqpQty()); // Available = Input Qty
                psParent.setInt(6, eqp.getEqpQty()); // Total Asset = Input Qty

                psParent.executeUpdate();

                // Insert into Child Table
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
                System.out.println("Equipment successfully added with ID: " + nextId);
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
    /*public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        
        // UPDATED SQL: Added a subquery to calculate 'DAY_QTY_IN_USE'
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION, " +
                     "  (SELECT COALESCE(SUM(ee.QTYINUSE), 0) " +
                     "   FROM EVENTEQUIPMENT ee " +
                     "   JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "   WHERE ee.EQPID = e.EQPID " +
                     "   AND TRUNC(ev.EVENTDATE) = TRUNC(SYSDATE) " + 
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
                
                // Handle Subclass Instantiation
                if (serviceSet != null) {
                    ServiceEquipment s = new ServiceEquipment();
                    s.setServiceSet(serviceSet);
                    eqp = s;
                } else {
                    SupportEquipment su = new SupportEquipment();
                    su.setEqpFunction(supportFunc);
                    eqp = su;
                }

                // Set Basic Attributes
                eqp.setEqpID(rs.getString("EQPID"));
                eqp.setEqpName(rs.getString("EQPNAME"));
                eqp.setEqpQty(rs.getInt("EQPQTY"));
                eqp.setEqpImage(rs.getString("EQPIMAGE"));
                
                // Set Tracking Attributes
                eqp.setTotQtyInUse(rs.getInt("TOTQTYINUSE"));
                eqp.setTotQtyAvailable(rs.getInt("TOTQTYAVAILABLE")); 
                eqp.setEqpTotQty(rs.getInt("EQPTOTQTY"));
                eqp.setEqpTotDamage(rs.getInt("EQPTOTDAMAGE"));
                eqp.setEqpTotLost(rs.getInt("EQPTOTLOST"));
                
                // --- NEW COLUMN EXTRACTION ---
                // Ensure your Equipment class has a setter for this new field
                eqp.setDailyQtyInUse(rs.getInt("DAY_QTY_IN_USE")); 
                
                list.add(eqp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // READ - Get Single Equipment by ID
    public Equipment getEquipmentById(String id) {
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION " +
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
                    String supportVal = rs.getString("EQPFUNCTION");

                    if (serviceVal != null) {
                        ServiceEquipment s = new ServiceEquipment();
                        s.setServiceSet(serviceVal);
                        eqp = s;
                    } else {
                        SupportEquipment su = new SupportEquipment();
                        su.setEqpFunction(supportVal);
                        eqp = su;
                    }

                    // FIX: Ensure all tracking data is fetched here too
                    eqp.setEqpID(rs.getString("EQPID"));
                    eqp.setEqpName(rs.getString("EQPNAME"));
                    eqp.setEqpQty(rs.getInt("EQPQTY"));
                    eqp.setEqpImage(rs.getString("EQPIMAGE"));
                    
                    eqp.setTotQtyInUse(rs.getInt("TOTQTYINUSE"));
                    eqp.setTotQtyAvailable(rs.getInt("TOTQTYAVAILABLE")); 
                    eqp.setEqpTotQty(rs.getInt("EQPTOTQTY"));
                    eqp.setEqpTotDamage(rs.getInt("EQPTOTDAMAGE"));
                    eqp.setEqpTotLost(rs.getInt("EQPTOTLOST"));
                    
                    return eqp;
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return null;
    }*/
    
 // READ - Get All Equipment
 // READ - Get All Equipment
    public List<Equipment> getAllEquipment() {
        List<Equipment> list = new ArrayList<>();
        
        // FIX: Changed "ev.RETURNSTATUS" to "ee.RETURNSTATUS"
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION, " +
                     "  (SELECT COALESCE(SUM(ee.QTYINUSE), 0) " +
                     "   FROM EVENTEQUIPMENT ee " +
                     "   JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "   WHERE ee.EQPID = e.EQPID " +
                     "   AND TRUNC(ev.EVENTDATE) = TRUNC(SYSDATE) " + 
                     "   AND ee.RETURNSTATUS = 'N' " + // FIXED: referring to EVENTEQUIPMENT table
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
                
                // Set Tracking Attributes
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
        // FIX: Changed "ev.RETURNSTATUS" to "ee.RETURNSTATUS"
        String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION, " +
                     "  (SELECT COALESCE(SUM(ee.QTYINUSE), 0) " +
                     "   FROM EVENTEQUIPMENT ee " +
                     "   JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "   WHERE ee.EQPID = e.EQPID " +
                     "   AND TRUNC(ev.EVENTDATE) = TRUNC(SYSDATE) " + 
                     "   AND ee.RETURNSTATUS = 'N' " + // FIXED: referring to EVENTEQUIPMENT table
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
                    String supportVal = rs.getString("EQPFUNCTION");

                    if (serviceVal != null) {
                        ServiceEquipment s = new ServiceEquipment();
                        s.setServiceSet(serviceVal);
                        eqp = s;
                    } else {
                        SupportEquipment su = new SupportEquipment();
                        su.setEqpFunction(supportVal);
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
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return null;
    }
    
    // UPDATE - Update Base Quantity Only
    public static boolean updateEquipmentQty(String id, int qty) {
        // NOTE: This updates the "Listing Quantity". 
        // Depending on your logic, you might also want to update TOTQTYAVAILABLE here.
        // For now, I will add logic to update Available by the difference, 
        // assuming an admin edit means we bought more stock.
        
        String sqlSelect = "SELECT EQPQTY FROM EQUIPMENT WHERE EQPID = ?";
        String sqlUpdate = "UPDATE EQUIPMENT SET EQPQTY = ?, TOTQTYAVAILABLE = TOTQTYAVAILABLE + ?, EQPTOTQTY = EQPTOTQTY + ? WHERE EQPID = ?";
        
        try (Connection conn = ConnectionManager.getConnection()) {
            
            // 1. Get old quantity to find the difference
            int oldQty = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setString(1, id);
                try(ResultSet rs = ps.executeQuery()){
                    if(rs.next()) oldQty = rs.getInt("EQPQTY");
                }
            }
            
            int difference = qty - oldQty; // e.g., Changed 50 to 60. Diff = 10.
            
            // 2. Update Listing, Available, and Total Asset
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setInt(1, qty);
                ps.setInt(2, difference); // Add 10 to Available
                ps.setInt(3, difference); // Add 10 to Total Asset Count
                ps.setString(4, id);
                
                int rowsAffected = ps.executeUpdate();
                return rowsAffected > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updateEquipment(Equipment eqp) {
        return updateEquipmentQty(eqp.getEqpID(), eqp.getEqpQty()); 
    }
    
    public static int getTotalEquipmentCount() {
        int total = 0;
        String query = "SELECT SUM(EQPTOTQTY) FROM EQUIPMENT";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) total = rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return total;
    }
    
 // Calculate % of equipment that is damaged/lost relative to total stock
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
    
    //equipment condiiton chart
    public static String getCategorizedConditionStats() {
        // We will build a string for Chart.js: "labels|goodData|damagedData|lostData"
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
            ") GROUP BY category";

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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // Return formatted for JS array injection
        return labels + "|" + good + "|" + damaged + "|" + lost;
    }
    
   /*public java.util.Map<String, Object> getEquipmentIssueSummary(String start, String end) throws java.sql.SQLException {
        java.util.Map<String, Object> summary = new java.util.HashMap<>();
        java.util.List<java.util.Map<String, Object>> details = new java.util.ArrayList<>();
        
        // Updated SQL to JOIN with Service and Support tables to get the "Type"
        String sql = "SELECT e.EQPID, e.EQPNAME, ee.QTYINUSE, ee.QTYRETURN, ee.QTYDAMAGE, ee.QTYLOST, " +
                     "COALESCE(s.SERVICESET, su.EQPFUNCTION, '-') AS EQP_TYPE " +
                     "FROM EQUIPMENT e " +
                     "JOIN EVENTEQUIPMENT ee ON e.EQPID = ee.EQPID " +
                     "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "LEFT JOIN SERVICEEQUIPMENT s ON e.EQPID = s.EQPID " + 
                     "LEFT JOIN SUPPORTEQUIPMENT su ON e.EQPID = su.EQPID " +
                     "WHERE ev.EVENTDATE BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') " +
                     "AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0) " +
                     "ORDER BY e.EQPID ASC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, start);
            ps.setString(2, end);
            
            long tAssigned = 0, tReturned = 0, tDamaged = 0, tLost = 0;
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    
                    int assigned = rs.getInt("QTYINUSE");
                    int returned = rs.getInt("QTYRETURN");
                    int damaged = rs.getInt("QTYDAMAGE");
                    int lost = rs.getInt("QTYLOST");

                    tAssigned += assigned;
                    tReturned += returned;
                    tDamaged += damaged;
                    tLost += lost;

                    row.put("id", rs.getString("EQPID"));
                    row.put("name", rs.getString("EQPNAME"));
                    row.put("type", rs.getString("EQP_TYPE")); // Now included
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
    }*/
    
    public java.util.Map<String, Object> getEquipmentIssueSummary(String start, String end) throws java.sql.SQLException {
        java.util.Map<String, Object> summary = new java.util.HashMap<>();
        java.util.List<java.util.Map<String, Object>> details = new java.util.ArrayList<>();
        
        // 1. Updated SQL: Added 'e.TOTQTYINUSE' to the SELECT list
        String sql = "SELECT e.EQPID, e.EQPNAME, e.TOTQTYINUSE, ee.QTYINUSE, ee.QTYRETURN, ee.QTYDAMAGE, ee.QTYLOST, " +
                     "COALESCE(s.SERVICESET, su.EQPFUNCTION, '-') AS EQP_TYPE " +
                     "FROM EQUIPMENT e " +
                     "JOIN EVENTEQUIPMENT ee ON e.EQPID = ee.EQPID " +
                     "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "LEFT JOIN SERVICEEQUIPMENT s ON e.EQPID = s.EQPID " + 
                     "LEFT JOIN SUPPORTEQUIPMENT su ON e.EQPID = su.EQPID " +
                     "WHERE ev.EVENTDATE BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') " +
                     "AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0) " +
                     "ORDER BY e.EQPID ASC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, start);
            ps.setString(2, end);
            
            long tAssigned = 0, tReturned = 0, tDamaged = 0, tLost = 0;
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    
                    // 2. Retrieve the TOTQTYINUSE (Global total) and QTYINUSE (Event specific)
                    int totQtyInUse = rs.getInt("TOTQTYINUSE"); // From EQUIPMENT table
                    int assigned = rs.getInt("QTYINUSE");       // From EVENTEQUIPMENT table
                    int returned = rs.getInt("QTYRETURN");
                    int damaged = rs.getInt("QTYDAMAGE");	
                    int lost = rs.getInt("QTYLOST");

                    // 3. Changed calculation as requested
                    tAssigned += totQtyInUse; // Accumulates the global 'Total In Use' count
                    
                    tReturned += returned;
                    tDamaged += damaged;
                    tLost += lost;

                    row.put("id", rs.getString("EQPID"));
                    row.put("name", rs.getString("EQPNAME"));
                    row.put("type", rs.getString("EQP_TYPE"));
                    row.put("totalInUse", totQtyInUse); // Optional: Added to map for visibility
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
    
    
    //equipment details, issues
    public List<java.util.Map<String, Object>> getUsageHistory(String eqpID) {
        List<java.util.Map<String, Object>> history = new ArrayList<>();
        
        /*String sql = "SELECT s.STAFFNAME, ev.EVENTNAME, ev.EVENTDATE, ee.QTYDAMAGE, ee.QTYLOST " +
                     "FROM EVENTEQUIPMENT ee " +
                     "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                     "JOIN STAFF s ON ev.STAFFID = s.STAFFID " +
                     "WHERE ee.EQPID = ? AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0) " +
                     "ORDER BY ev.EVENTDATE DESC";*/
        
        String sql = "SELECT s.STAFFNAME, ev.EVENTNAME, ev.EVENTDATE, ee.QTYDAMAGE, ee.QTYLOST " +
                "FROM EVENTEQUIPMENT ee " +
                "JOIN EVENT ev ON ee.EVENTID = ev.EVENTID " +
                // Use LEFT JOIN for Staff in case the staff member was deleted
                "LEFT JOIN STAFF s ON ev.STAFFID = s.STAFFID " + 
                "WHERE ee.EQPID = ? AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0) " +
                "ORDER BY ev.EVENTDATE DESC";
        

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, eqpID);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("staffName", rs.getString("STAFFNAME"));
                    row.put("eventName", rs.getString("EVENTNAME"));
                    row.put("eventDate", rs.getDate("EVENTDATE"));
                    row.put("qtyDamage", rs.getInt("QTYDAMAGE"));
                    row.put("qtyLost", rs.getInt("QTYLOST"));
                    history.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    } 
    
    //sync table equipment data with eventEquipment
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
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
 // READ - Get just the Total Stock Quantity (Lightweight)
    public int getEquipmentStock(String eqpID) {
        String sql = "SELECT EQPQTY FROM EQUIPMENT WHERE EQPID = ?";
        int stock = 0;

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, eqpID); // Corrected to String
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stock = rs.getInt("EQPQTY");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stock;
    }
    
    // UPDATED METHOD: Accepts String ID and uses proper Date comparison
    public int getBookedQtyOnDate(String eqpID, String eventDateStr) { 
        int bookedQty = 0;
        
        // SQL: No need for TO_DATE if we bind it as a Java SQL Date object
        String sql = "SELECT SUM(ee.QTYINUSE) FROM EVENTEQUIPMENT ee " +
                     "JOIN EVENT e ON ee.EVENTID = e.EVENTID " +
                     "WHERE ee.EQPID = ? " +
                     "AND e.EVENTDATE = ? " +  // Compare Date directly
                     "AND e.IS_DELETED = 0"; 

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, eqpID); // Fix: Now accepts String ID (e.g., "E001")
            
            // Fix: Convert String (YYYY-MM-DD) to SQL Date for accurate DB comparison
            ps.setDate(2, java.sql.Date.valueOf(eventDateStr)); 
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    bookedQty = rs.getInt(1); 
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookedQty;
    }
}