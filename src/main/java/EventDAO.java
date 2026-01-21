package cems;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class EventDAO {

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
			ps.setString(9, event.getPackID());

			ps.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		}
	}

	// SELECT -get all events
	public static List<EventBean> getAllEvents() throws SQLException {
		List<EventBean> events = new ArrayList<>();

		String query = "SELECT e.*, p.packName FROM event e " + 
		"LEFT JOIN packageCatering p ON e.packID = p.packID " + 
		"WHERE e.is_deleted = 0 " + 
		"ORDER BY e.eventDate ASC, e.eventTime ASC";

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

				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return event;
	}

	// UPDATE - Modify an existing event
	public static void updateEvent(EventBean event) throws SQLException {

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
			ps.setString(8, event.getPackID()); // Simpan ID sahaja
			ps.setString(9, event.getEventID()); // WHERE clause

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

	public static List<EventBean> getEquipmentByPackage(String packID, int currentPax) {
	    List<EventBean> list = new ArrayList<>();

	    // SQL Fixed: Restored the 'WHEN' clause so the calculation works
	    // and the '?' placeholder exists for parameter 1.
	    String query = "SELECT e.eqpID, e.eqpName, s.serviceSet, sup.eqpFunction, " + 
	                   "CASE " + 
	                   "  WHEN ep.is_paxDepend = 'Y' THEN (ep.qtyRequired * ?) " + 
	                   "  ELSE ep.qtyRequired " + 
	                   "END AS qtyRequired " + 
	                   "FROM Equipment e " + 
	                   "JOIN EquipmentPackage ep ON e.eqpID = ep.eqpID " + 
	                   "LEFT JOIN ServiceEquipment s ON e.eqpID = s.eqpID " + 
	                   "LEFT JOIN SupportEquipment sup ON e.eqpID = sup.eqpID " + 
	                   "WHERE ep.packID = ?";

	    try (Connection conn = ConnectionManager.getConnection(); 
	         PreparedStatement ps = conn.prepareStatement(query)) {

	        // This parameter is required by the '?' in the SQL above
	        ps.setInt(1, currentPax);
	        ps.setString(2, packID);

	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                EventBean bean = new EventBean();
	                bean.setEqpID(rs.getString("eqpID"));
	                bean.setEqpName(rs.getString("eqpName"));
	                
	                // The SQL has already calculated the total quantity for us
	                bean.setTotQtyInUse(rs.getInt("qtyRequired"));

	                // Set Service/Support fields
	                String sSet = rs.getString("serviceSet");
	                bean.setServiceSet(sSet != null ? sSet : "-");
	                
	                String eFunc = rs.getString("eqpFunction");
	                bean.setEqpFunction(eFunc != null ? eFunc : "-");

	                
	                list.add(bean);
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return list;
	}

	public static List<EventBean> checkEquipmentAvailability(String packID, String eventDate, int currentPax) {
		List<EventBean> list = new ArrayList<>();

		//eqpTotQty by date
	    String query = "SELECT e.eqpID, e.eqpName, " +
	                   "CASE " +
	                   "  WHEN ep.is_paxDepend = 'Y' THEN (ep.qtyRequired * ?) " +
	                   "  ELSE ep.qtyRequired " +
	                   "END AS qtyRequired, " +
	                   "s.serviceSet, sup.eqpFunction, " +
	                   "(e.eqpTotQty - COALESCE((SELECT SUM(ee.qtyInUse) " +
	                   "FROM EventEquipment ee JOIN Event ev ON ee.eventID = ev.eventID " +
	                   "WHERE ee.eqpID = e.eqpID " +
	                   "AND TRUNC(ev.eventDate) = TO_DATE(?, 'YYYY-MM-DD') " +
	                   "AND ev.eventStatus NOT IN ('Completed') " +
	                   "AND ev.is_deleted = 0), 0)) AS currentAvailable " +
	                   "FROM Equipment e " +
	                   "JOIN EquipmentPackage ep ON e.eqpID = ep.eqpID " +
	                   "LEFT JOIN ServiceEquipment s ON e.eqpID = s.eqpID " +
	                   "LEFT JOIN SupportEquipment sup ON e.eqpID = sup.eqpID " +
	                   "WHERE ep.packID = ?";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(query)) {

			ps.setInt(1, currentPax);
			ps.setString(2, eventDate);
			ps.setString(3, packID);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					EventBean item = new EventBean();
					item.setEqpID(rs.getString("eqpID"));
					item.setEqpName(rs.getString("eqpName"));
					item.setTotQtyInUse(rs.getInt("qtyRequired"));
					item.setTotQtyAvailable(rs.getInt("currentAvailable"));

					String cat = rs.getString("serviceSet");
					if (cat == null || cat.isEmpty())
						cat = rs.getString("eqpFunction");
					if (cat == null)
						cat = "-";
					item.setEqpFunction(cat);

					list.add(item);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	public static void insertEventEquipment(String eventID, String eqpID, int qty) throws SQLException {
	    // We ONLY insert into the tracking table. 
	    // We DO NOT touch the Master Equipment table here.
	    String insertQuery = "INSERT INTO EventEquipment (eventID, eqpID, qtyInUse, returnStatus) VALUES (?, ?, ?, 'N')";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement psInsert = conn.prepareStatement(insertQuery)) {

	        psInsert.setString(1, eventID);
	        psInsert.setString(2, eqpID);
	        psInsert.setInt(3, qty);

	        psInsert.executeUpdate();
	        
	    } catch (SQLException e) {
	        e.printStackTrace();
	        throw e;
	    }
	}

	// 1. Ganti method isStaffBusy (Digunakan masa POST/Save)
	/*public static boolean isStaffBusy(String staffID, String date) throws SQLException {
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
	}*/

	// 2. Ganti method getBusyStaffIds (TAMBAH STATIC DI SINI)
	/*public static List<String> getBusyStaffIds(String date) {
		List<String> busyIds = new ArrayList<>();
		String sql = "SELECT DISTINCT staffID FROM Event " + 
		"WHERE TRUNC(eventDate) = TO_DATE(?, 'YYYY-MM-DD') " + 
		"AND is_deleted = 0"; 

		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
	}*/
	
	// NEW: Get list of Coordinators who are AVAILABLE on a specific date
	// (Filters by Role = 'COORDINATOR' and ensures they have no active events)
	public static List<staffBean> getAvailableCoordinators(String date) {
	    List<staffBean> availableList = new ArrayList<>();
	    
	    // Select Coordinators who are NOT in the list of busy staff for that date
	    String query = "SELECT staffID, staffName " + 
	                   "FROM Staff " + 
	                   "WHERE staffRole = 'COORDINATOR' " + 
	                   "AND staffID NOT IN (" + 
	                   "    SELECT staffID " + 
	                   "    FROM Event " + 
	                   "    WHERE TRUNC(eventDate) = TO_DATE(?, 'YYYY-MM-DD') " + 
	                   "    AND is_deleted = 0 " +
	                   ") " +
	                   "ORDER BY staffName ASC";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(query)) {

	        ps.setString(1, date);

	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                staffBean staff = new staffBean();
	                staff.setStaffID(rs.getString("staffID"));
	                staff.setStaffName(rs.getString("staffName"));
	                availableList.add(staff);
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return availableList;
	}
	
	// UPDATED: Get IDs of Coordinators who are BUSY on a specific date
	public static List<String> getBusyStaffIds(String date) {
	    List<String> busyIds = new ArrayList<>();
	    
	    // Added JOIN to Staff table to check staffRole = 'COORDINATOR'
	    String sql = "SELECT DISTINCT e.staffID " + 
	                 "FROM Event e " + 
	                 "JOIN Staff s ON e.staffID = s.staffID " + 
	                 "WHERE TRUNC(e.eventDate) = TO_DATE(?, 'YYYY-MM-DD') " + 
	                 "AND e.is_deleted = 0 " + 
	                 "AND s.staffRole = 'COORDINATOR'"; 

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
						"WHERE TRUNC(eventDate) = TO_DATE(?, 'YYYY-MM-DD') "+ 
						"AND is_deleted = 0";

		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

			ps.setString(1, date);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					count = rs.getInt(1);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		System.out.println("DEBUG DAO: Date " + date + " have " + count + " active event.");
		return count;
	}

	public static List<String> getFullDates() {
		List<String> fullDates = new ArrayList<>();
		String query = "SELECT TO_CHAR(eventDate, 'YYYY-MM-DD') as date " + 
						"FROM Event " + 
						"WHERE is_deleted = 0 " + 																										
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

	// list of equipment assigned for each package in event
	public static List<EventEquipment> getEventEquipmentList(String eventID) {
		List<EventEquipment> list = new ArrayList<>();

		// Join EventEquipment with Equipment table to get names/types
		/*String query = "SELECT ee.eventID, ee.eqpID, ee.qtyInUse, ee.qtyReturn, ee.qtyDamage, ee.qtyLost, "
				+ "e.eqpName, s.serviceSet, p.eqpFunction " + "FROM eventEquipment ee "
				+ "JOIN equipment e ON ee.eqpID = e.eqpID " + "LEFT JOIN serviceEquipment s ON e.eqpID = s.eqpID "
				+ "LEFT JOIN supportEquipment p ON e.eqpID = p.eqpID " + "WHERE ee.eventID = ?";*/
		
		String query = "SELECT ee.eventID, ee.eqpID, ee.qtyInUse, ee.qtyReturn, ee.qtyLost, ee.qtyDamage, "
		        + "e.eqpName, s.serviceSet, p.eqpFunction " 
		        + "FROM eventEquipment ee "
		        + "LEFT JOIN equipment e ON ee.eqpID = e.eqpID " 
		        + "LEFT JOIN serviceEquipment s ON e.eqpID = s.eqpID "
		        + "LEFT JOIN supportEquipment p ON e.eqpID = p.eqpID " 
		        + "WHERE ee.eventID = ?";	

		try (Connection connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query)) {

			ps.setString(1, eventID);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				EventEquipment item = new EventEquipment();
				item.setEventID(rs.getString("eventID"));
				item.setEqpID(rs.getString("eqpID"));
				item.setQtyInUse(rs.getInt("qtyInUse"));
				item.setQtyReturn(rs.getInt("qtyReturn"));
				item.setQtyLost(rs.getInt("qtyLost"));
				item.setQtyDamage(rs.getInt("qtyDamage"));
				item.setEqpName(rs.getString("eqpName"));
				item.setServiceSet(rs.getString("serviceSet"));
				item.setEqpFunction(rs.getString("eqpFunction"));

				list.add(item);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	// UPDATE: Save the return status
	public static void updateReturnStatus(String eventID, String eqpID, int qtyReturn, int qtyLost, int qtyDamage) {
		String query = "UPDATE eventEquipment " + "SET qtyReturn = ?, qtyLost = ?, qtyDamage = ?, "
				+ "returnStatus = 'Y' " + "WHERE eventID = ? AND eqpID = ?";

		try (Connection connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query)) {

			ps.setInt(1, qtyReturn);
			ps.setInt(2, qtyLost);
			ps.setInt(3, qtyDamage);
			ps.setString(4, eventID);
			ps.setString(5, eqpID);

			ps.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	// list of event for coordinator
	public List<EventBean> getEventsByStaff(String staffID) throws SQLException {
	    List<EventBean> events = new ArrayList<>();

	    String sql = "SELECT e.*, p.packName " + 
	                 "FROM event e " + 
	                 "LEFT JOIN packageCatering p ON e.packID = p.packID " + 
	                 "WHERE e.staffID = ? AND e.is_deleted = 0 " + 
	                 "ORDER BY e.eventDate ASC, e.eventTime ASC";

		try (Connection conn = ConnectionManager.getConnection(); 
		PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setString(1, staffID);

			try (ResultSet rs = ps.executeQuery()) {
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
					// ----------------------------------

					events.add(event);
				}
			}
		}
		return events;
	}

	// 1. Update quantities for specific items (Loop this in Controller)
	public static void updateEquipmentQty(String eventID, String eqpID, int qtyReturn, int qtyLost, int qtyDamage)
			throws SQLException {

		String query = "UPDATE EventEquipment SET qtyReturn = ?, qtyLost = ?, qtyDamage = ? "
				+ "WHERE eventID = ? AND eqpID = ?";

		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

			ps.setInt(1, qtyReturn);
			ps.setInt(2, qtyLost);
			ps.setInt(3, qtyDamage);
			ps.setString(4, eventID);
			ps.setString(5, eqpID);

			ps.executeUpdate();
		}
	}

	public static int getQuantityUsedOnDate(String eqpID, String targetDate) {
		String query = "SELECT SUM(ee.qtyInUse) AS totalUsed " +
	                   "FROM EventEquipment ee " +
	                   "JOIN Event e ON ee.eventID = e.eventID " +
	                   "WHERE ee.eqpID = ? " +
	                   "AND TRUNC(e.eventDate) = TO_DATE(?, 'YYYY-MM-DD') " +
	                  
	                   "AND e.eventStatus NOT IN ('Completed') " +
	                   "AND e.is_deleted = 0";

		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

			ps.setString(1, eqpID);
			ps.setString(2, targetDate);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt("totalUsed");
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return 0;
	}

	// equipment return
	/*public boolean processEquipmentReturn(EventEquipment data) {
	    Connection conn = null;
	    PreparedStatement psEvent = null;
	    PreparedStatement psInsert = null; // New PreparedStatement for Insert
	    PreparedStatement psMaster = null;

	    // 1. Try updating existing record first
	    String sqlUpdateEvent = "UPDATE EventEquipment SET qtyReturn=?, qtyLost=?, qtyDamage=?, returnStatus='Y' "
	            + "WHERE eventID=? AND eqpID=?";

	    // 2. If update fails (0 rows), insert a new record
	    String sqlInsertEvent = "INSERT INTO EventEquipment (eventID, eqpID, qtyInUse, qtyReturn, qtyLost, qtyDamage, returnStatus) "
	            + "VALUES (?, ?, ?, ?, ?, ?, 'Y')";

	    // 3. Update Master Inventory (Your Logic)
	    String sqlUpdateMaster = "UPDATE Equipment SET " 
	            + "totQtyInUse = totQtyInUse - ?, "
	            + "totQtyAvailable = totQtyAvailable + ?, " 
	            + "eqpTotDamage = eqpTotDamage + ?, "
	            + "eqpTotLost = eqpTotLost + ?, " 
	            + "eqpTotQty = eqpTotQty - ? " 
	            + "WHERE eqpID=?";

	    try {
	        conn = ConnectionManager.getConnection();
	        conn.setAutoCommit(false); // Start Transaction

	        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

	        // --- Step 1: Update EventEquipment ---
	        psEvent = conn.prepareStatement(sqlUpdateEvent);
	        psEvent.setInt(1, data.getQtyReturn());
	        psEvent.setInt(2, data.getQtyLost());
	        psEvent.setInt(3, data.getQtyDamage());
	        psEvent.setDate(4, today);
	        psEvent.setString(5, data.getEventID());
	        psEvent.setString(6, data.getEqpID());
	        
	        int rowEvent = psEvent.executeUpdate();

	        // --- FIX: If Update found 0 rows, INSERT instead ---
	        if (rowEvent == 0) {
	            psInsert = conn.prepareStatement(sqlInsertEvent);
	            psInsert.setString(1, data.getEventID());
	            psInsert.setString(2, data.getEqpID());
	            psInsert.setInt(3, data.getQtyInUse()); // Ensure your JSP passes this!
	            psInsert.setInt(4, data.getQtyReturn());
	            psInsert.setInt(5, data.getQtyLost());
	            psInsert.setInt(6, data.getQtyDamage());
	            psInsert.setDate(7, today);
	            
	            rowEvent = psInsert.executeUpdate();
	        }

	        // --- Step 2: Update Master Equipment Inventory ---
	        // Accounting Math:
	        int totalAccountedFor = data.getQtyReturn() + data.getQtyDamage() + data.getQtyLost();
	        
	        // Write-off Math (Damaged + Lost are removed from Total Asset count)
	        int totalWriteOff = data.getQtyDamage() + data.getQtyLost();

	        psMaster = conn.prepareStatement(sqlUpdateMaster);
	        psMaster.setInt(1, totalAccountedFor); // Reduce InUse
	        psMaster.setInt(2, data.getQtyReturn()); // Increase Available
	        psMaster.setInt(3, data.getQtyDamage()); // Log Damage
	        psMaster.setInt(4, data.getQtyLost());   // Log Lost
	        psMaster.setInt(5, totalWriteOff);      // Permanently reduce Total Asset
	        psMaster.setString(6, data.getEqpID());

	        int rowMaster = psMaster.executeUpdate();

	        // --- Final Check ---
	        if (rowEvent > 0 && rowMaster > 0) {
	            conn.commit(); // Save everything
	            return true;
	        } else {
	            conn.rollback(); // Undo if Master update failed
	            return false;
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	        if (conn != null) {
	            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
	        }
	        return false;
	    } finally {
	        // Close all resources
	        try { if (psEvent != null) psEvent.close(); } catch (Exception e) {}
	        try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
	        try { if (psMaster != null) psMaster.close(); } catch (Exception e) {}
	        try { if (conn != null) conn.close(); } catch (Exception e) {}
	    }
	}*/
	
	public boolean processEquipmentReturn(EventEquipment data) {
	    Connection conn = null;
	    PreparedStatement psEvent = null;
	    PreparedStatement psInsert = null;
	    PreparedStatement psMaster = null;

	    // 1. Try updating existing record first
	    // Parameters: qtyReturn(1), qtyLost(2), qtyDamage(3), eventID(4), eqpID(5)
	    String sqlUpdateEvent = "UPDATE EventEquipment SET qtyReturn=?, qtyLost=?, qtyDamage=?, returnStatus='Y' "
	            + "WHERE eventID=? AND eqpID=?";

	    // 2. If update fails (0 rows), insert a new record
	    // Parameters: eventID(1), eqpID(2), qtyInUse(3), qtyReturn(4), qtyLost(5), qtyDamage(6)
	    String sqlInsertEvent = "INSERT INTO EventEquipment (eventID, eqpID, qtyInUse, qtyReturn, qtyLost, qtyDamage, returnStatus) "
	            + "VALUES (?, ?, ?, ?, ?, ?, 'Y')";

	    // 3. Update Master Inventory
	    String sqlUpdateMaster = "UPDATE Equipment SET " 
	            + "totQtyInUse = totQtyInUse - ?, "
	            + "totQtyAvailable = totQtyAvailable + ?, " 
	            + "eqpTotDamage = eqpTotDamage + ?, "
	            + "eqpTotLost = eqpTotLost + ?, " 
	            + "eqpTotQty = eqpTotQty - ? " 
	            + "WHERE eqpID=?";

	    try {
	        conn = ConnectionManager.getConnection();
	        conn.setAutoCommit(false); // Start Transaction

	        // --- Step 1: Update EventEquipment ---
	        psEvent = conn.prepareStatement(sqlUpdateEvent);
	        psEvent.setInt(1, data.getQtyReturn());
	        psEvent.setInt(2, data.getQtyLost());
	        psEvent.setInt(3, data.getQtyDamage());
	        // FIX: Removed setDate. Re-indexed the following parameters:
	        psEvent.setString(4, data.getEventID()); 
	        psEvent.setString(5, data.getEqpID());
	        
	        int rowEvent = psEvent.executeUpdate();

	        // --- Step 1.5: INSERT if Update found 0 rows ---
	        if (rowEvent == 0) {
	            psInsert = conn.prepareStatement(sqlInsertEvent);
	            psInsert.setString(1, data.getEventID());
	            psInsert.setString(2, data.getEqpID());
	            psInsert.setInt(3, data.getQtyInUse()); 
	            psInsert.setInt(4, data.getQtyReturn());
	            psInsert.setInt(5, data.getQtyLost());
	            psInsert.setInt(6, data.getQtyDamage());
	            // FIX: Removed setDate. The SQL only has 6 parameters.
	            
	            rowEvent = psInsert.executeUpdate();
	        }

	        // --- Step 2: Update Master Equipment Inventory ---
	        int totalAccountedFor = data.getQtyReturn() + data.getQtyDamage() + data.getQtyLost();
	        int totalWriteOff = data.getQtyDamage() + data.getQtyLost();

	        psMaster = conn.prepareStatement(sqlUpdateMaster);
	        psMaster.setInt(1, totalAccountedFor); // Reduce InUse
	        psMaster.setInt(2, data.getQtyReturn()); // Increase Available
	        psMaster.setInt(3, data.getQtyDamage()); // Log Damage
	        psMaster.setInt(4, data.getQtyLost());   // Log Lost
	        psMaster.setInt(5, totalWriteOff);      // Permanently reduce Total Asset
	        psMaster.setString(6, data.getEqpID());

	        int rowMaster = psMaster.executeUpdate();

	        // --- Final Check ---
	        if (rowEvent > 0 && rowMaster > 0) {
	            conn.commit(); // Save everything
	            return true;
	        } else {
	            conn.rollback(); // Undo if Master update failed
	            return false;
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	        if (conn != null) {
	            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
	        }
	        return false;
	    } finally {
	        // Close all resources
	        try { if (psEvent != null) psEvent.close(); } catch (Exception e) {}
	        try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
	        try { if (psMaster != null) psMaster.close(); } catch (Exception e) {}
	        try { if (conn != null) conn.close(); } catch (Exception e) {}
	    }
	}

	// 2. Finalize the Event Return
	public static void finalizeEventReturn(String eventID) throws SQLException {
		String query = "UPDATE Event SET eventStatus = 'Completed' WHERE eventID = ?";

		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

			ps.setString(1, eventID);
			ps.executeUpdate();
		}
	}

	// MANAGER DASHBOARD
	public static int getTotalEventsCount() {
		int count = 0;
		String query = "SELECT COUNT(*) FROM EVENT WHERE IS_DELETED = 0";
		try (Connection conn = ConnectionManager.getConnection();
				PreparedStatement ps = conn.prepareStatement(query);
				ResultSet rs = ps.executeQuery()) {
			if (rs.next())
				count = rs.getInt(1);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	// MANAGER DASHBOARD
	public static List<EventBean> getUpcomingEvents() {
		List<EventBean> list = new ArrayList<>();
		String sql = "SELECT e.*, p.PACKNAME FROM EVENT e " + "LEFT JOIN PACKAGECATERING p ON e.PACKID = p.PACKID "
				+ "WHERE e.IS_DELETED = 0 AND e.EVENTDATE >= CURRENT_DATE "
				+ "ORDER BY e.EVENTDATE ASC FETCH FIRST 5 ROWS ONLY";
		try (Connection conn = ConnectionManager.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				EventBean eb = new EventBean();
				eb.setEventID(rs.getString("eventID"));
				eb.setEventName(rs.getString("eventName"));
				eb.setEventDate(rs.getDate("eventDate"));
				eb.setEventTime(rs.getTimestamp("eventTime"));
				eb.setEventVenue(rs.getString("eventVenue"));
				eb.setEventStatus(rs.getString("eventStatus"));
				eb.setPackName(rs.getString("packName"));
				list.add(eb);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	// MANAGER DASHBOARD
	public static double getEventGrowthRate() {
		double rate = 0.0;
		// Compares events in the last 30 days against total events to show "activity
		// trend"
		String query = "SELECT (COUNT(CASE WHEN EVENTDATE >= CURRENT_DATE - 30 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) "
				+ "FROM EVENT WHERE IS_DELETED = 0";
		try (Connection conn = ConnectionManager.getConnection();
				PreparedStatement ps = conn.prepareStatement(query);
				ResultSet rs = ps.executeQuery()) {
			if (rs.next())
				rate = rs.getDouble(1);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return rate;
	}

	// Calculate % of events that are still "In-progress" (MANAGER DASHBOARD)
	public static double getPendingReturnRate() {
		double rate = 0.0;
		String query = "SELECT (COUNT(CASE WHEN returnStatus = 'N' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) "
				+ "FROM eventEquipment";
		try (Connection conn = ConnectionManager.getConnection();
				PreparedStatement ps = conn.prepareStatement(query);
				ResultSet rs = ps.executeQuery()) {
			if (rs.next())
				rate = rs.getDouble(1);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return rate;
	}

	// MANAGER DASHBOARD
	public static int getPendingReturnsCount() {
		int count = 0;
		String query = "SELECT COUNT(DISTINCT eventID) FROM eventEquipment WHERE returnStatus = 'N'";
		try (Connection conn = ConnectionManager.getConnection();
				PreparedStatement ps = conn.prepareStatement(query);
				ResultSet rs = ps.executeQuery()) {
			if (rs.next())
				count = rs.getInt(1);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	// MANAGER DASHBOARD
	public static int[] getEventStatusStats() {
		int[] stats = new int[3]; // [Completed, In-Progress, Upcoming/Others]
		String query = "SELECT " + "COUNT(CASE WHEN EVENTSTATUS = 'Completed' THEN 1 END), "
				+ "COUNT(CASE WHEN EVENTSTATUS = 'In-progress' THEN 1 END), "
				+ "COUNT(CASE WHEN EVENTSTATUS NOT IN ('Completed', 'In-progress') THEN 1 END) "
				+ "FROM EVENT WHERE IS_DELETED = 0";
		try (Connection conn = ConnectionManager.getConnection();
				PreparedStatement ps = conn.prepareStatement(query);
				ResultSet rs = ps.executeQuery()) {
			if (rs.next()) {
				stats[0] = rs.getInt(1);
				stats[1] = rs.getInt(2);
				stats[2] = rs.getInt(3);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return stats;
	}

	// Get total event count for a specific coordinator (COORDINATOR DASHBOARD)
	public static int getEventCountByStaff(String staffID) {
		int count = 0;
		String sql = "SELECT COUNT(*) FROM event " + "WHERE staffID = ? AND is_deleted = 0 "
				+ "AND TO_CHAR(eventDate, 'MM-YYYY') = TO_CHAR(SYSDATE, 'MM-YYYY')";
		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, staffID);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next())
					count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	// Get pending returns count for a specific coordinator (COORDINATOR DASHBOARD)
	public static int getPendingReturnsByStaff(String staffID) {
		int count = 0;
		String sql = "SELECT COUNT(DISTINCT e.eventID) FROM event e "
				+ "JOIN eventEquipment ee ON e.eventID = ee.eventID "
				+ "WHERE e.staffID = ? AND ee.returnStatus = 'N' AND e.is_deleted = 0 "
				+ "AND TO_CHAR(e.eventDate, 'MM-YYYY') = TO_CHAR(SYSDATE, 'MM-YYYY')";
		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, staffID);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next())
					count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	// COORDINATOR DASHBOARD return rate
	public static double getReturnRateByStaffMonth(String staffID) {
		String sql = "SELECT "
				+ "(COUNT(CASE WHEN ee.returnStatus = 'N' THEN 1 END) * 100.0 / NULLIF(COUNT(DISTINCT e.eventID), 0)) "
				+ "FROM event e " + "LEFT JOIN eventEquipment ee ON e.eventID = ee.eventID "
				+ "WHERE e.staffID = ? AND e.is_deleted = 0 "
				+ "AND TO_CHAR(e.eventDate, 'MM-YYYY') = TO_CHAR(SYSDATE, 'MM-YYYY')";
		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, staffID);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next())
					return rs.getDouble(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return 0.0;
	}

	// COORDINATOR DASHBOARD event rate
	public static double getEventGrowthByStaffMonth(String staffID) {
		String sql = "SELECT " + "((curr.cnt - prev.cnt) * 100.0 / NULLIF(prev.cnt, 0)) " + "FROM "
				+ "(SELECT COUNT(*) as cnt FROM event WHERE staffID = ? AND is_deleted = 0 AND TO_CHAR(eventDate, 'MM-YYYY') = TO_CHAR(SYSDATE, 'MM-YYYY')) curr, "
				+ "(SELECT COUNT(*) as cnt FROM event WHERE staffID = ? AND is_deleted = 0 AND TO_CHAR(eventDate, 'MM-YYYY') = TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'MM-YYYY')) prev";
		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, staffID);
			ps.setString(2, staffID);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next())
					return rs.getDouble(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return 0.0;
	}

	// Get event status distribution for the Pie Chart (COORDINATOR DASHBOARD)
	public static String getEvChartDataByStaff(String staffID) {
		String data = "0,0,0";
		String sql = "SELECT " + "COUNT(CASE WHEN eventStatus = 'Completed' THEN 1 END), "
				+ "COUNT(CASE WHEN eventStatus = 'In-progress' THEN 1 END), "
				+ "COUNT(CASE WHEN eventStatus NOT IN ('Completed', 'In-progress') THEN 1 END) "
				+ "FROM event WHERE staffID = ? AND is_deleted = 0 "
				+ "AND TO_CHAR(eventDate, 'MM-YYYY') = TO_CHAR(SYSDATE, 'MM-YYYY')";
		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, staffID);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					data = rs.getInt(1) + "," + rs.getInt(2) + "," + rs.getInt(3);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return data;
	}

	// DASHBOARD COORDINATOR
	public static List<EventBean> getUpcomingEventsByStaff(String staffID) {
		List<EventBean> list = new ArrayList<>();
		// Logic: Assigned to staff AND not completed AND date is today or future
		String sql = "SELECT e.*, p.packName FROM event e " + "LEFT JOIN packageCatering p ON e.packID = p.packID "
				+ "WHERE e.staffID = ? " + "AND e.is_deleted = 0 " + "AND e.eventStatus != 'Completed' "
				+ "AND e.eventDate >= TRUNC(SYSDATE) " + "ORDER BY e.eventDate ASC, e.eventTime ASC "
				+ "FETCH FIRST 5 ROWS ONLY";

		try (Connection conn = ConnectionManager.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setString(1, staffID);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					EventBean eb = new EventBean();
					eb.setEventID(rs.getString("eventID"));
					eb.setEventName(rs.getString("eventName"));
					eb.setEventDate(rs.getDate("eventDate"));
					eb.setEventTime(rs.getTimestamp("eventTime"));
					eb.setEventVenue(rs.getString("eventVenue"));
					eb.setEventStatus(rs.getString("eventStatus"));
					eb.setPackName(rs.getString("packName"));
					list.add(eb);
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}
	//get equipment stats for each coordinator
	public List<Map<String, Object>> getCoordinatorIssues(String staffID) throws SQLException {
	    List<Map<String, Object>> list = new ArrayList<>();
	    
	    String sql = "SELECT e.EVENTID, eq.EQPNAME, ee.QTYLOST, ee.QTYDAMAGE " +
	                 "FROM EVENT e " +
	                 "JOIN EVENTEQUIPMENT ee ON e.EVENTID = ee.EVENTID " +
	                 "JOIN EQUIPMENT eq ON ee.EQPID = eq.EQPID " +
	                 "WHERE e.STAFFID = ? " +
	                 "AND (ee.QTYLOST > 0 OR ee.QTYDAMAGE > 0)"; 

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        
	        ps.setString(1, staffID);
	        
	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                // Create a "dynamic bean" using HashMap
	                Map<String, Object> issue = new HashMap<>();
	                
	                // Map DB columns to names your JSP expects
	                issue.put("eventID", rs.getString("EVENTID"));
	                issue.put("eqpName", rs.getString("EQPNAME"));
	                issue.put("qtyLost", rs.getInt("QTYLOST"));
	                issue.put("qtyDamage", rs.getInt("QTYDAMAGE"));
	                
	                list.add(issue);
	            }
	        }
	    }
	    return list;
	}
	
	// Method for Event Report with JOIN to get Staff Names
	// Inside EventDAO.java
	public static List<EventBean> getEventReport(String start, String end) throws SQLException {
	    List<EventBean> list = new ArrayList<>();
	    // Join with Staff table to get Coordinator Name
	    String sql = "SELECT e.EVENTID, e.EVENTDATE, e.EVENTTIME, e.EVENTNAME, e.EVENTPAX, e.EVENTVENUE, s.STAFFNAME " +
	                 "FROM EVENT e " +
	                 "LEFT JOIN STAFF s ON e.STAFFID = s.STAFFID " +
	                 "WHERE e.EVENTDATE BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD') " +
	                 "AND e.IS_DELETED = 0 " +
	                 "ORDER BY e.EVENTDATE ASC, e.EVENTTIME ASC";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        
	        ps.setString(1, start);
	        ps.setString(2, end);
	        
	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                EventBean eb = new EventBean();
	                eb.setEventID(rs.getString("EVENTID"));
	                eb.setEventDate(rs.getDate("EVENTDATE"));
	                eb.setEventTime(rs.getTimestamp("EVENTTIME"));
	                eb.setEventName(rs.getString("EVENTNAME"));
	                eb.setEventPax(rs.getInt("EVENTPAX"));
	                eb.setEventVenue(rs.getString("EVENTVENUE"));
	                eb.setStaffName(rs.getString("STAFFNAME")); // Coordinator Name
	                list.add(eb);
	            }
	        }
	    }
	    return list;
	}
	
	//report event issues
	public static List<Map<String, Object>> getIssuesForEvent(String eventID) throws SQLException {
	    List<Map<String, Object>> issues = new ArrayList<>();
	    String sql = "SELECT ee.QTYLOST, ee.QTYDAMAGE, eq.EQPNAME FROM EVENTEQUIPMENT ee " +
	                 "JOIN EQUIPMENT eq ON ee.EQPID = eq.EQPID " +
	                 "WHERE ee.EVENTID = ? AND (ee.QTYLOST > 0 OR ee.QTYDAMAGE > 0)";
	    
	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        ps.setString(1, eventID);
	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                Map<String, Object> issue = new HashMap<>();
	                issue.put("eqpName", rs.getString("EQPNAME"));
	                issue.put("qtyLost", rs.getInt("QTYLOST"));
	                issue.put("qtyDamage", rs.getInt("QTYDAMAGE"));
	                issues.add(issue);
	            }
	        }
	    }
	    return issues;
	}

	// Method for Equipment Report
	public static List<Map<String, Object>> getEquipmentReport(String start, String end) throws SQLException {
	    List<Map<String, Object>> list = new ArrayList<>();
	    // Using Equipment schema from image_6116cb.png
	    String sql = "SELECT EQPID, EQPNAME, EQPQTY, TOTQTYAVAILABLE, EQPTOTDAMAGE, EQPTOTLOST " +
	                 "FROM EQUIPMENT ORDER BY EQPID ASC";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql);
	         ResultSet rs = ps.executeQuery()) {
	        while (rs.next()) {
	            Map<String, Object> map = new HashMap<>();
	            map.put("id", rs.getString("EQPID"));
	            map.put("name", rs.getString("EQPNAME"));
	            map.put("total", rs.getInt("EQPQTY"));
	            map.put("available", rs.getInt("TOTQTYAVAILABLE"));
	            map.put("damage", rs.getInt("EQPTOTDAMAGE"));
	            map.put("lost", rs.getInt("EQPTOTLOST"));
	            list.add(map);
	        }
	    }
	    return list;
	}public List<EventBean> getEventsByStaffId(String staffID) {
        List<EventBean> events = new ArrayList<>();
        // SQL: Select all events managed by this specific staff member
        String sql = "SELECT * FROM EVENT WHERE STAFFID = ? ORDER BY EVENTDATE DESC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, staffID);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EventBean event = new EventBean();
                    event.setEventID(rs.getString("EVENTID"));
                    event.setEventName(rs.getString("EVENTNAME"));
                    
                    Timestamp tsDate = rs.getTimestamp("EVENTDATE");
                    if (tsDate != null) {
                        event.setEventDate(new java.sql.Date(tsDate.getTime()));
                    }

                    event.setEventTime(rs.getTimestamp("EVENTTIME"));
                    
                    event.setEventVenue(rs.getString("EVENTVENUE"));
                    event.setEventStatus(rs.getString("EVENTSTATUS"));
                    event.setStaffID(rs.getString("STAFFID"));
                    
                    events.add(event);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }
    
    public List<Map<String, Object>> getIssuesByStaffId(String staffID) {
        List<Map<String, Object>> issues = new ArrayList<>();
        
        // SQL: Joins EventEquipment -> Event -> Equipment
        // Filters for events by this staff ID where damage or loss occurred
        String sql = "SELECT ee.EVENTID, e.EVENTNAME, eq.EQPNAME, ee.QTYDAMAGE, ee.QTYLOST " +
                     "FROM EVENTEQUIPMENT ee " +
                     "JOIN EVENT e ON ee.EVENTID = e.EVENTID " +
                     "JOIN EQUIPMENT eq ON ee.EQPID = eq.EQPID " +
                     "WHERE e.STAFFID = ? AND (ee.QTYDAMAGE > 0 OR ee.QTYLOST > 0)";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, staffID);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    // Keys must match what you use in JSP: ${issue.eventID}, ${issue.eqpName}, etc.
                    row.put("eventID", rs.getString("EVENTID"));
                    row.put("eventName", rs.getString("EVENTNAME"));
                    row.put("eqpName", rs.getString("EQPNAME"));
                    row.put("qtyDamage", rs.getInt("QTYDAMAGE"));
                    row.put("qtyLost", rs.getInt("QTYLOST"));
                    
                    issues.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return issues;
    }
	
	
}
