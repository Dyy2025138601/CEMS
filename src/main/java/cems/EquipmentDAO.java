package cems;

import java.sql.*;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

public class EquipmentDAO {
	
	private static String generateNextId(Connection conn) throws SQLException {
		String sql = "SELECT EQPID FROM EQUIPMENT ORDER BY LENGTH(EQPID) DESC, EQPID DESC FETCH FIRST 1 ROWS ONLY"; 
	    // Nota: Kalau guna MySQL guna "LIMIT 1", kalau Oracle/Derby guna "FETCH FIRST 1 ROWS ONLY"
	    
	    try (PreparedStatement ps = conn.prepareStatement(sql);
	         ResultSet rs = ps.executeQuery()) {
	        if (rs.next()) {
	            String lastId = rs.getString("EQPID");
	            // Contoh kalau ID format "EQP001", kita buang "EQP" dan ambil nombor
	            // Kalau ID cuma nombor "1", "2", terus convert pi int
	            int numericPart = Integer.parseInt(lastId.replaceAll("[^0-9]", ""));
	            int nextId = numericPart + 1;
	            
	            // Pulangkan balik dalam format asal (Contoh: EQP004)
	            return String.format("EQP%03d", nextId); 
	        } else {
	            return "EQP001"; // Kalau table kosong, start dengan ID pertama
	        }
	    }
	}

	public static boolean addEquipment(Equipment eqp) {
	    // Tambah EQPID dalam SQL string
	    String sqlParent = "INSERT INTO EQUIPMENT (EQPID, EQPNAME, EQPQTY, EQPIMAGE) VALUES (?, ?, ?, ?)";
	    Connection conn = null;

	    try {
	        conn = ConnectionManager.getConnection();
	        conn.setAutoCommit(false); 

	        // --- STEP BARU: Generate ID Baru ---
	        String nextId = generateNextId(conn);
	        // ------------------------------------

	        try (PreparedStatement psParent = conn.prepareStatement(sqlParent)) {
	            psParent.setString(1, nextId); // Masukkan ID baru kat sini
	            psParent.setString(2, eqp.getEqpName());
	            psParent.setInt(3, eqp.getEqpQty());
	            psParent.setString(4, eqp.getEqpImage());

	            psParent.executeUpdate();

	            // 3. Insert into Child Table (Guna nextId tadi)
	            if (eqp instanceof ServiceEquipment) {
	                String val = ((ServiceEquipment) eqp).getServiceSet();
	                if (val == null) val = "GUEST"; 
	                
	                String sqlChild = "INSERT INTO SERVICEEQUIPMENT (EQPID, SERVICESET) VALUES (?, ?)";
	                try (PreparedStatement psChild = conn.prepareStatement(sqlChild)) {
	                    psChild.setString(1, nextId); // Guna nextId
	                    psChild.setString(2, val);
	                    psChild.executeUpdate();
	                }
	            } else if (eqp instanceof SupportEquipment) {
	                String val = ((SupportEquipment) eqp).getEqpFunction();
	                if (val == null) val = "STORAGE";

	                String sqlChild = "INSERT INTO SUPPORTEQUIPMENT (EQPID, EQPFUNCTION) VALUES (?, ?)";
	                try (PreparedStatement psChild = conn.prepareStatement(sqlChild)) {
	                    psChild.setString(1, nextId); // Guna nextId
	                    psChild.setString(2, val);
	                    psChild.executeUpdate();
	                }
	            }

	            conn.commit(); 
	            System.out.println("DEBUG: Berjaya tambah equipment dengan ID: " + nextId);
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

	public List<Equipment> getAllEquipment() {
	    List<Equipment> list = new ArrayList<>();
	    // Join parent with both child tables
	    String sql = "SELECT e.*, s.SERVICESET, su.EQPFUNCTION " +
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
	            
	            // Logic: Determine object type based on which child table has data
	            if (serviceSet != null) {
	                ServiceEquipment s = new ServiceEquipment();
	                s.setServiceSet(serviceSet);
	                eqp = s;
	            } else {
	                SupportEquipment su = new SupportEquipment();
	                su.setEqpFunction(supportFunc);
	                eqp = su;
	            }

	            // Set common attributes
	            eqp.setEqpID(rs.getString("EQPID"));
	            eqp.setEqpName(rs.getString("EQPNAME"));
	            eqp.setEqpQty(rs.getInt("EQPQTY"));
	            eqp.setEqpImage(rs.getString("EQPIMAGE"));
	           
	            
	            list.add(eqp);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return list;
	}
	
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

	                eqp.setEqpID(rs.getString("EQPID"));
	                eqp.setEqpName(rs.getString("EQPNAME"));
	                eqp.setEqpQty(rs.getInt("EQPQTY"));
	                eqp.setEqpImage(rs.getString("EQPIMAGE"));
	                return eqp;
	            }
	        }
	    } catch (SQLException e) { e.printStackTrace(); }
	    return null;
	}
	
	//update qty only
	public static boolean updateEquipmentQty(String id, int qty) {
	    String sql = "UPDATE EQUIPMENT SET EQPQTY = ? WHERE EQPID = ?";
	    
	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        
	        ps.setInt(1, qty);
	        ps.setString(2, id);
	        
	        int rowsAffected = ps.executeUpdate();
	        return rowsAffected > 0;
	        
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false;
	    }
	}
	public static boolean updateEquipment(Equipment eqp) {
	    // Kita guna logic update qty yang hang dah ada
	    return updateEquipmentQty(eqp.getEqpID(), eqp.getEqpQty()); 
	}
}
