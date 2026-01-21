package cems; 

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.Statement;

public class staffDAO {

	// CREATE - Insert new staff member with Manual ID
	public boolean addStaff(staffBean staff) {
	    boolean isSuccess = false;

	    // 1. We include STAFFID in the INSERT statement now
	    String sql = "INSERT INTO STAFF (STAFFID, STAFFNAME, STAFFEMAIL, STAFFPHONENUM, STAFFPASSWORD, STAFFROLE) VALUES (?, ?, ?, ?, ?, ?)";

	    try (Connection con = ConnectionManager.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        // 2. Set the manually generated ID (e.g., S006)
	        ps.setString(1, staff.getStaffID()); 
	        
	        ps.setString(2, staff.getStaffName());
	        ps.setString(3, staff.getStaffEmail());
	        ps.setString(4, staff.getStaffPhoneNum());
	        ps.setString(5, staff.getStaffPassword()); 
	        ps.setString(6, staff.getStaffRole());

	        int rowsAffected = ps.executeUpdate();

	        if (rowsAffected > 0) {
	            isSuccess = true;
	        }
	        
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    
	    return isSuccess; 
	}
    
 // staff login
    public staffBean loginStaff(String email, String password, String role) {
        staffBean staff = null;
        String encryptedInput = EncryptionUtil.encrypt(password);
        String sql = "SELECT * FROM STAFF WHERE STAFFEMAIL = ? AND STAFFPASSWORD = ? AND STAFFROLE = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, encryptedInput);
            ps.setString(3, role);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                staff = new staffBean();
                staff.setStaffID(rs.getString("STAFFID"));
                staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                staff.setStaffName(rs.getString("STAFFNAME"));
                staff.setStaffRole(rs.getString("STAFFROLE"));
                staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                String encryptedPasswordFromDB = rs.getString("STAFFPASSWORD");
                String actualPassword = EncryptionUtil.decrypt(encryptedPasswordFromDB);
                
                // Store the readable password in the bean for the JSP to use
                staff.setStaffPassword(actualPassword);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staff;
    }
    
    
    public void updateStaffPasswordByEmail(staffBean staff) {
        String sql = "UPDATE STAFF SET STAFFPASSWORD = ? WHERE STAFFEMAIL = ?";
        try (Connection conn = ConnectionManager.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, staff.getStaffPassword());
            ps.setString(2, staff.getStaffEmail());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // SELECT - Get all staff members
    public static List<staffBean> getAllStaff() {
        List<staffBean> staffList = new ArrayList<>();
        String query = "SELECT * FROM STAFF";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                staffBean s = new staffBean();
             // Inside the while(rs.next()) loop
                String encryptedPass = rs.getString("STAFFPASSWORD");
                s.setStaffPassword(EncryptionUtil.decrypt(encryptedPass)); // Decrypt here
                s.setStaffID(rs.getString("STAFFID"));
                s.setStaffName(rs.getString("STAFFNAME"));
                s.setStaffEmail(rs.getString("STAFFEMAIL"));
                s.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                s.setStaffPassword(rs.getString("STAFFPASSWORD"));
                s.setStaffRole(rs.getString("STAFFROLE"));
                s.setManagerId(rs.getString("MANAGERID"));
                staffList.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staffList;
    }

    // READ - Get staff by ID
    public staffBean getStaffById(String staffID) {
    	staffBean staff = null;
        String query = "SELECT * FROM STAFF WHERE STAFFID = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, staffID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    staff = new staffBean();
                 // Inside the while(rs.next()) loop
                    String encryptedPass = rs.getString("STAFFPASSWORD");
                    staff.setStaffPassword(EncryptionUtil.decrypt(encryptedPass)); // Decrypt here
                    staff.setStaffID(rs.getString("STAFFID"));
                    staff.setStaffName(rs.getString("STAFFNAME"));
                    staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                    staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                    staff.setStaffPassword(rs.getString("STAFFPASSWORD"));
                    staff.setStaffRole(rs.getString("STAFFROLE"));
                    staff.setManagerId(rs.getString("MANAGERID"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staff;
    }

    
 // READ - Get the last registered Staff ID (for auto-generation)
    public String getLastStaffId() {
        String lastId = null;
        // Order by ID descending implies the top one is the latest
        String sql = "SELECT STAFFID FROM STAFF ORDER BY STAFFID DESC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            // We only need the first row
            if (rs.next()) {
                lastId = rs.getString("STAFFID");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lastId; // Returns "S005" (or null if table is empty)
    }
    
 // ecList- COORDINATOR
    public List<staffBean> getAllCoordinators() {
        List<staffBean> list = new ArrayList<>();
        // Subquery to count events assigned to each coordinator
        /*String sql = "SELECT s.*, (SELECT COUNT(*) FROM EVENT e WHERE e.STAFFID = s.STAFFID) as totalEvents " +
                     "FROM STAFF s WHERE s.STAFFROLE = 'COORDINATOR' ORDER BY s.STAFFID ASC";*/
        
        String sql = "SELECT s.*, " +
                "(SELECT COUNT(*) FROM EVENT e " +
                " WHERE e.STAFFID = s.STAFFID " +
                " AND TO_CHAR(e.EVENTDATE, 'MM-YYYY') = TO_CHAR(SYSDATE, 'MM-YYYY') " + 
                ") as totalEvents " +
                "FROM STAFF s WHERE s.STAFFROLE = 'COORDINATOR' ORDER BY s.STAFFID ASC";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                staffBean s = new staffBean();
                s.setStaffID(rs.getString("STAFFID"));
                s.setStaffName(rs.getString("STAFFNAME"));
                s.setStaffEmail(rs.getString("STAFFEMAIL"));
                s.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                s.setStaffRole(rs.getString("STAFFROLE"));
                // Store the count in a temporary field or use a custom property
                s.setAssignmentCount(rs.getInt("totalEvents")); 
                list.add(s);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

 // UPDATE - Modify staff phone number
 // Remove 'static' so it can be called via 'dao.updateStaffPhoneNum'
    public boolean updateStaffPhoneNum(staffBean staff) {
        String query = "UPDATE STAFF SET STAFFPHONENUM=? WHERE STAFFID=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, staff.getStaffPhoneNum());
            ps.setString(2, staff.getStaffID());

            int rowsUpdated = ps.executeUpdate();
            return rowsUpdated > 0; // Success if at least 1 row changed
        } catch (SQLException e) {
            e.printStackTrace();
            return false; // Failure
        }
    }
    
    // UPDATE - Modify staff password
    public boolean updateStaffPassword(staffBean staff) {
        String query = "UPDATE STAFF SET STAFFPASSWORD=? WHERE STAFFID=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, staff.getStaffPassword());
            ps.setString(2, staff.getStaffID());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - Remove staff member
    public static void deleteStaff(int staffId) {
        String query = "DELETE FROM STAFF WHERE STAFFID = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, staffId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    
    public boolean isEmailExists(String email) {
        boolean exists = false;
        String sql = "SELECT COUNT(*) FROM STAFF WHERE STAFFEMAIL = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                if (rs.getInt(1) > 0) {
                    exists = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return exists;
    }
    
    //relate dekat account (update phone number-dia check ada yang sama tak dgn staff lain nye phone num
    public boolean isPhoneExists(String phoneNum, String currentStaffID) {
        boolean exists = false;
        String query = "SELECT COUNT(*) FROM staff WHERE staffPhoneNum = ? AND staffId != ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, phoneNum);
            ps.setString(2, currentStaffID);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                exists = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }
    
}