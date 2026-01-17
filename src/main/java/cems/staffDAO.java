package cems; // Changed to match your previous package name


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class staffDAO {

    // CREATE - Insert new staff member
    public static void addStaff(staffBean staff) {
        String query = "INSERT INTO STAFF (STAFFNAME, STAFFEMAIL, STAFFPHONENUM, STAFFPASSWORD, STAFFROLE, MANAGERID) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

        	ps.setString(1, staff.getStaffName());
            ps.setString(2, staff.getStaffEmail());
            ps.setString(3, staff.getStaffPhoneNum());
            ps.setString(4, staff.getStaffPassword());
            ps.setString(5, staff.getStaffRole());

         // MANAGERID is null initially as per your requirement
            ps.setNull(6, java.sql.Types.VARCHAR); 

            ps.executeUpdate();
            System.out.println("Staff registered successfully!");
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
 // staff login
    public staffBean loginStaff(String email, String password, String role) {
        staffBean staff = null;
        String sql = "SELECT * FROM STAFF WHERE STAFFEMAIL = ? AND STAFFPASSWORD = ? AND STAFFROLE = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, password);
            ps.setString(3, role);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                staff = new staffBean();
                staff.setStaffID(rs.getString("STAFFID"));
                staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                staff.setStaffName(rs.getString("STAFFNAME"));
                staff.setStaffRole(rs.getString("STAFFROLE"));
                staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                staff.setStaffPassword(rs.getString("STAFFPASSWORD"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staff;
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
    public static staffBean getStaffById(int staffID) {
    	staffBean staff = null;
        String query = "SELECT * FROM STAFF WHERE STAFFID = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, staffID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    staff = new staffBean();
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
    
 // ecList- COORDINATOR
    public List<staffBean> getAllCoordinators() {
        List<staffBean> list = new ArrayList<>();
        String sql = "SELECT * FROM STAFF WHERE STAFFROLE = 'Coordinator'";
        
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
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

 // UPDATE - Modify staff phone number
    public static void updateStaffPhoneNum(staffBean staff) {
        // Query only needs 2 parameters: the new phone number and the ID
        String query = "UPDATE STAFF SET STAFFPHONENUM=? WHERE STAFFID=?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, staff.getStaffPhoneNum());
            ps.setString(2, staff.getStaffID());

            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // UPDATE - Modify staff password
    public static void updateStaffPassword(staffBean staff) { // Fixed typo in method name
        // Changed SET clause to STAFFPASSWORD and ensured correct placeholders
        String query = "UPDATE STAFF SET STAFFPASSWORD=? WHERE STAFFID=?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
	
            ps.setString(1, staff.getStaffPassword());
            ps.setString(2, staff.getStaffID());
	
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // DELETE - Remove staff member
    public static void deleteStaff(int staffID) {
        String query = "DELETE FROM STAFF WHERE STAFFID = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, staffID);
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
}