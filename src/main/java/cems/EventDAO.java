package cems;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {
	//private static Connection connection = null;

	// CREATE - Insert new event
	public static void addEvent(EventBean event) throws SQLException {
 String query = "INSERT INTO event (eventID, eventName, eventDate, eventTime, eventVenue, eventPax, eventStatus, staffID, packID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(query)) {
	        
	        ps.setString(1, event.getEventID());
	        ps.setString(2, event.getEventName());
	        ps.setDate(3, event.getEventDate());
	        ps.setTimestamp(4, event.getEventTime());
	        ps.setString(5, event.getEventVenue());
	        ps.setInt(6, event.getEventPax());
	        ps.setString(7, event.getEventStatus());
	        ps.setString(8, event.getStaffID());
	        ps.setString(9, event.getPackID()); // <--- Masukkan packID di sini

	        ps.executeUpdate();
	    } catch (SQLException e) {
	        e.printStackTrace();
	        throw e; 
	    }
	}

	// SELECT - get all events (Hanya yang belum dipadam)
	public static List<EventBean> getAllEvents() throws SQLException {
	    List<EventBean> events = new ArrayList<>();
	    // TAMBAH: WHERE e.is_deleted = 0
	    String query = "SELECT e.*, p.packName FROM event e " +
	                   "LEFT JOIN packageCatering p ON e.packID = p.packID " +
	                   "WHERE e.is_deleted = 0"; 

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(query);
	         ResultSet rs = ps.executeQuery()) {

	        while (rs.next()) {
	            EventBean event = new EventBean();
	            event.setEventID(rs.getString("eventID"));
	            event.setEventName(rs.getString("eventName"));
	            event.setEventDate(rs.getDate("eventDate"));
	            event.setEventTime(rs.getTimestamp("eventTime"));
	            event.setEventVenue(rs.getString("eventVenue"));
	            event.setEventPax(rs.getInt("eventPax"));
	            event.setEventStatus(rs.getString("eventStatus"));
	            event.setStaffID(rs.getString("staffID"));
	            event.setPackID(rs.getString("packID"));
	            event.setPackName(rs.getString("packName"));
	            events.add(event);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return events;
	}
// READ - Get a event by ID
    public static EventBean getEventById(String eventID) throws SQLException {
        EventBean event = null;
	String query = "SELECT e.*, s.staffName, p.packName " +
                       "FROM event e " +
                       "LEFT JOIN Staff s ON e.staffID = s.staffID " +
                       "LEFT JOIN packageCatering p ON e.packID = p.packID " +
                       "WHERE e.eventID = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, eventID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    event = new EventBean();
                    event.setEventID(rs.getString("eventID"));
                    event.setEventName(rs.getString("eventName"));
                    event.setEventDate(rs.getDate("eventDate"));
                    event.setEventTime(rs.getTimestamp("eventTime"));
                    event.setEventVenue(rs.getString("eventVenue"));
                    event.setEventPax(rs.getInt("eventPax"));
                    event.setEventStatus(rs.getString("eventStatus"));
                    event.setStaffID(rs.getString("staffID"));
                    event.setStaffName(rs.getString("staffName"));
                    event.setPackID(rs.getString("packID")); // PENTING: Untuk cari equipment nanti
                    event.setPackName(rs.getString("packName"));
                    
                    // JANGAN letak rs.getString("eqpName") di sini!
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return event;
    }
	// UPDATE - Modify an existing event
	public static void updateEvent(EventBean event) throws SQLException {
        // 1. Pastikan jumlah ? sama dengan jumlah ps.set...
        // 2. Buang packName (sebab table Event tak ada column packName)
        String query = "UPDATE event SET eventName=?, eventDate=?, eventTime=?, eventVenue=?, eventPax=?, eventStatus=?, staffID=?, packID=? WHERE eventID=?";
        
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {

            ps.setString(1, event.getEventName());
            ps.setDate(2, event.getEventDate());
            ps.setTimestamp(3, event.getEventTime());
            ps.setString(4, event.getEventVenue());
            ps.setInt(5, event.getEventPax());
            ps.setString(6, event.getEventStatus());
            ps.setString(7, event.getStaffID());
            ps.setString(8, event.getPackID());    // Simpan ID sahaja
            ps.setString(9, event.getEventID());   // WHERE clause

            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

 
 // DELETE - Tukar status is_deleted kepada 1
    public static void deleteEvent(String eventID) throws SQLException {
        
        String query = "UPDATE event SET is_deleted = 1 WHERE eventID = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, eventID);
            int rowsUpdated = ps.executeUpdate();
            
            if (rowsUpdated > 0) {
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            throw e; 
        }
    }
 	
 	public static String getLastID() {
 	    String nextID = "V001"; 
 	    String query = "SELECT eventID FROM event ORDER BY eventID DESC FETCH FIRST 1 ROWS ONLY";
 	    
 	    try (Connection conn = ConnectionManager.getConnection();
 	         PreparedStatement ps = conn.prepareStatement(query);
 	         ResultSet rs = ps.executeQuery()) {
 	        
 	        if (rs.next()) {
 	            String lastID = rs.getString("eventID");
 	            System.out.println("DEBUG: ID Terakhir dlm DB: " + lastID); // Tengok kat console
 	            
 	            int numericPart = Integer.parseInt(lastID.substring(1)); 
 	            nextID = String.format("V%03d", numericPart + 1);
 	            System.out.println("DEBUG: ID Baru dijana: " + nextID); // Tengok kat console
 	        }
 	    } catch (Exception e) {
 	        e.printStackTrace();
 	    }
 	    return nextID;
 	}
 	
 	public static List<EventBean> getEquipmentByPackage(String packID) {
 	    List<EventBean> equipmentList = new ArrayList<>();
 	    // QUERY DIPERBAIKI: Ambil qtyRequired dari EquipmentPackage, bukan totQtyInUse dari Equipment
 	    String query = "SELECT e.eqpID, e.eqpName, ep.qtyRequired, s.serviceSet, sup.eqpFunction " +
 	                   "FROM Equipment e " +
 	                   "JOIN EquipmentPackage ep ON e.eqpID = ep.eqpID " +
 	                   "LEFT JOIN ServiceEquipment s ON e.eqpID = s.eqpID " +
 	                   "LEFT JOIN SupportEquipment sup ON e.eqpID = sup.eqpID " +
 	                   "WHERE ep.packID = ?";
 	    
 	    try (Connection conn = ConnectionManager.getConnection();
 	         PreparedStatement ps = conn.prepareStatement(query)) {
 	        
 	        ps.setString(1, packID);
 	        try (ResultSet rs = ps.executeQuery()) {
 	            while (rs.next()) {
 	                EventBean item = new EventBean();
 	                item.setEqpID(rs.getString("eqpID"));
 	                item.setEqpName(rs.getString("eqpName"));
 	                // Simpan qtyRequired ke dalam totQtyInUse supaya mudah dipanggil di JSP
 	                item.setTotQtyInUse(rs.getInt("qtyRequired")); 
 	                
 	                String sSet = rs.getString("serviceSet");
 	                item.setServiceSet(sSet != null ? sSet : "-");
 	                
 	                String eFunc = rs.getString("eqpFunction");
 	                item.setEqpFunction(eFunc != null ? eFunc : "-");
 	                
 	                equipmentList.add(item);
 	            }
 	        }
 	    } catch (SQLException e) {
 	        e.printStackTrace();
 	    }
 	    return equipmentList;
 	}
 	
 	public static List<EventBean> checkEquipmentAvailability(String packID, String eventDate) {
 	    List<EventBean> list = new ArrayList<>();
 	    // Query ditambah LEFT JOIN untuk ambil serviceSet dan eqpFunction
 	    String query = "SELECT e.eqpID, e.eqpName, ep.qtyRequired, " +
 	                   "s.serviceSet, sup.eqpFunction, " + // Tambah column ni
 	                   "(e.eqpQty - COALESCE((SELECT SUM(ee.qtyInUse) " +
 	                   "FROM EventEquipment ee JOIN Event ev ON ee.eventID = ev.eventID " +
 	                   "WHERE ee.eqpID = e.eqpID AND TRUNC(ev.eventDate) = TO_DATE(?, 'YYYY-MM-DD') " +
 	                   "AND ev.is_deleted = 0), 0)) AS currentAvailable " +
 	                   "FROM Equipment e " +
 	                   "JOIN EquipmentPackage ep ON e.eqpID = ep.eqpID " +
 	                   "LEFT JOIN ServiceEquipment s ON e.eqpID = s.eqpID " +
 	                   "LEFT JOIN SupportEquipment sup ON e.eqpID = sup.eqpID " +
 	                   "WHERE ep.packID = ?";

 	    try (Connection conn = ConnectionManager.getConnection();
 	         PreparedStatement ps = conn.prepareStatement(query)) {
 	        ps.setString(1, eventDate);
 	        ps.setString(2, packID);
 	        try (ResultSet rs = ps.executeQuery()) {
 	            while (rs.next()) {
 	                EventBean item = new EventBean();
 	                item.setEqpID(rs.getString("eqpID"));
 	                item.setEqpName(rs.getString("eqpName"));
 	                item.setTotQtyInUse(rs.getInt("qtyRequired")); 
 	                item.setTotQtyAvailable(rs.getInt("currentAvailable"));
 	                
 	                // Gabungkan category: Ambil serviceSet, kalau tak ada ambil eqpFunction
 	                String cat = rs.getString("serviceSet");
 	                if (cat == null || cat.isEmpty()) cat = rs.getString("eqpFunction");
 	                if (cat == null) cat = "-";
 	                item.setEqpFunction(cat); // Simpan dalam property eqpFunction
 	                
 	                list.add(item);
 	            }
 	        }
 	    } catch (SQLException e) { e.printStackTrace(); }
 	    return list;
 	}
 	
 // Tambah method ini dalam EventDAO.java
 	public static void insertEventEquipment(String eventID, String eqpID, int qty) throws SQLException {
 	    String query = "INSERT INTO EventEquipment (eventID, eqpID, qtyInUse, returnStatus) VALUES (?, ?, ?, 'N')";
 	    
 	    try (Connection conn = ConnectionManager.getConnection();
 	         PreparedStatement ps = conn.prepareStatement(query)) {
 	        
 	        ps.setString(1, eventID);
 	        ps.setString(2, eqpID);
 	        ps.setInt(3, qty);
 	        
 	        ps.executeUpdate();
 	    } catch (SQLException e) {
 	        e.printStackTrace();
 	        throw e; // Lemparkan error supaya Controller tahu jika gagal
 	    }
 	}
 	
 // 1. Ganti method isStaffBusy (Digunakan masa POST/Save)
    public static boolean isStaffBusy(String staffID, String date) throws SQLException {
        // Rule: Check tarikh sahaja. Kalau ada 1 event pun hari tu, dia busy.
        String query = "SELECT COUNT(*) FROM event " +
                       "WHERE staffID = ? " +
                       "AND eventDate = TO_DATE(?, 'YYYY-MM-DD') " +
                       "AND eventStatus = 'In-progress'";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, staffID);
            ps.setString(2, date);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    return count > 0; 
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 	
 // 2. Ganti method getBusyStaffIds (TAMBAH STATIC DI SINI)
    public static List<String> getBusyStaffIds(String date) {
        List<String> busyIds = new ArrayList<>();
        String sql = "SELECT DISTINCT staffID FROM Event " +
                     "WHERE TRUNC(eventDate) = TO_DATE(?, 'YYYY-MM-DD') " +
                     "AND is_deleted = 0"; // Tambah ni!
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    busyIds.add(rs.getString("staffID"));
                }
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return busyIds;
    }
    
    public static int countEventsByDate(String date) {
        int count = 0;
        // Guna TRUNC untuk tarikh dan pastikan is_deleted adalah 0
        String query = "SELECT COUNT(*) FROM Event " +
                       "WHERE TRUNC(eventDate) = TO_DATE(?, 'YYYY-MM-DD') " +
                       "AND is_deleted = 0";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("DEBUG DAO: Tarikh " + date + " ada " + count + " event aktif."); 
        return count;
    }

    public static List<String> getFullDates() {
        List<String> fullDates = new ArrayList<>();
        String query = "SELECT TO_CHAR(eventDate, 'YYYY-MM-DD') as tarikh " +
                       "FROM Event " +
                       "WHERE is_deleted = 0 " + // Tambah ni!
                       "GROUP BY TO_CHAR(eventDate, 'YYYY-MM-DD') " +
                       "HAVING COUNT(*) >= 4";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                fullDates.add(rs.getString("tarikh"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return fullDates;
    }
}
