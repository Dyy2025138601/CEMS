package cems;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class staffDAO {

    // CREATE - Insert new staff member with Manual ID
    public boolean addStaff(staffBean staff) {
        boolean isSuccess = false;
        String sql = "INSERT INTO STAFF (STAFFID, STAFFNAME, STAFFEMAIL, STAFFPHONENUM, STAFFPASSWORD, STAFFROLE, MANAGERID) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = ConnectionManager.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
           
            ps.setString(1, staff.getStaffID()); 
            ps.setString(2, staff.getStaffName());
            ps.setString(3, staff.getStaffEmail());
            ps.setString(4, staff.getStaffPhoneNum());
            ps.setString(5, EncryptionUtil.encrypt(staff.getStaffPassword()));
            ps.setString(6, staff.getStaffRole());
            ps.setNull(7, java.sql.Types.VARCHAR);
            
            int rowsAffected = ps.executeUpdate();
            isSuccess = rowsAffected > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return isSuccess; 
    }
    
    // Staff Login
    public staffBean loginStaff(String email, String password, String role) {
        staffBean staff = null;
        String encryptedInput = EncryptionUtil.encrypt(password);
        String sql = "SELECT * FROM STAFF WHERE STAFFEMAIL = ? AND STAFFPASSWORD = ? AND STAFFROLE = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, encryptedInput);
            ps.setString(3, role);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    staff = new staffBean();
                    staff.setStaffID(rs.getString("STAFFID"));
                    staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                    staff.setStaffName(rs.getString("STAFFNAME"));
                    staff.setStaffRole(rs.getString("STAFFROLE"));
                    staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                    
                    // Decrypt password for use in the application/JSP
                    String encryptedPasswordFromDB = rs.getString("STAFFPASSWORD");
                    staff.setStaffPassword(EncryptionUtil.decrypt(encryptedPasswordFromDB));
                }
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
                s.setStaffID(rs.getString("STAFFID"));
                s.setStaffName(rs.getString("STAFFNAME"));
                s.setStaffEmail(rs.getString("STAFFEMAIL"));
                s.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                s.setStaffRole(rs.getString("STAFFROLE"));
                s.setManagerId(rs.getString("MANAGERID"));
                
                // Decrypt and set password
                String encryptedPass = rs.getString("STAFFPASSWORD");
                s.setStaffPassword(EncryptionUtil.decrypt(encryptedPass));
                
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
                    staff.setStaffID(rs.getString("STAFFID"));
                    staff.setStaffName(rs.getString("STAFFNAME"));
                    staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                    staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                    staff.setStaffRole(rs.getString("STAFFROLE"));
                    staff.setManagerId(rs.getString("MANAGERID"));
                    
                    String encryptedPass = rs.getString("STAFFPASSWORD");
                    staff.setStaffPassword(EncryptionUtil.decrypt(encryptedPass));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staff;
    }

    // READ - Get the last registered Staff ID for auto-generation
    public String getLastStaffId() {
        String lastId = null;
        // PostgreSQL standard sorting works for strings like 'S001'
        String sql = "SELECT STAFFID FROM STAFF ORDER BY STAFFID DESC LIMIT 1";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                lastId = rs.getString("STAFFID");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lastId;
    }
    
    // COORDINATOR List with Monthly Event Count
    public List<staffBean> getAllCoordinators() {
        List<staffBean> list = new ArrayList<>();
        
        // POSTGRESQL CHANGE: Use CURRENT_DATE instead of SYSDATE
        String sql = "SELECT s.*, " +
                     "(SELECT COUNT(*) FROM EVENT e " +
                     " WHERE e.STAFFID = s.STAFFID " +
                     " AND TO_CHAR(e.EVENTDATE, 'MM-YYYY') = TO_CHAR(CURRENT_DATE, 'MM-YYYY') " + 
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
                s.setAssignmentCount(rs.getInt("totalEvents")); 
                list.add(s);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateStaffPhoneNum(staffBean staff) {
        String query = "UPDATE STAFF SET STAFFPHONENUM=? WHERE STAFFID=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, staff.getStaffPhoneNum());
            ps.setString(2, staff.getStaffID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateStaffPassword(staffBean staff) {
        String query = "UPDATE STAFF SET STAFFPASSWORD=? WHERE STAFFID=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, staff.getStaffPassword());
            ps.setString(2, staff.getStaffID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - Removed 'static' for consistency and changed parameter to String
    public void deleteStaff(String staffId) {
        String query = "DELETE FROM STAFF WHERE STAFFID = ?";
        
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, staffId);
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
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exists = rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return exists;
    }
    
    public boolean isPhoneExists(String phoneNum, String currentStaffID) {
        boolean exists = false;
        String query = "SELECT COUNT(*) FROM STAFF WHERE STAFFPHONENUM = ? AND STAFFID != ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, phoneNum);
            ps.setString(2, currentStaffID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exists = rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }
}