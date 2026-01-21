package cems;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class staffDAO {

    /**
     * Helper method to prevent NullPointerException.
     * Checks if the connection from ConnectionManager is valid.
     */
    private Connection getSafeConnection() {
        Connection conn = ConnectionManager.getConnection();
        if (conn == null) {
            System.err.println("❌ Error: Connection is null. Check AWS RDS Security Groups and credentials.");
        }
        return conn;
    }

    // CREATE - Insert new staff with manual ID and Transaction Commit
    public boolean addStaff(staffBean staff) {
        boolean isSuccess = false;
        String sql = "INSERT INTO STAFF (STAFFID, STAFFNAME, STAFFEMAIL, STAFFPHONENUM, STAFFPASSWORD, STAFFROLE) VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, staff.getStaffID());
                ps.setString(2, staff.getStaffName());
                ps.setString(3, staff.getStaffEmail());
                ps.setString(4, staff.getStaffPhoneNum());
                ps.setString(5, staff.getStaffPassword());
                ps.setString(6, staff.getStaffRole());

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    conn.commit(); // Required because autoCommit is false
                    isSuccess = true;
                }
            } catch (SQLException e) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return isSuccess;
    }

    // READ - Login check
    public staffBean loginStaff(String email, String password, String role) {
        staffBean staff = null;
        String encryptedInput = EncryptionUtil.encrypt(password);
        String sql = "SELECT * FROM STAFF WHERE STAFFEMAIL = ? AND STAFFPASSWORD = ? AND STAFFROLE = ?";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
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
                        
                        // Decrypt password for local session use
                        String dbPass = rs.getString("STAFFPASSWORD");
                        staff.setStaffPassword(EncryptionUtil.decrypt(dbPass));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return staff;
    }

    // UPDATE - Update password by email with Commit
    public void updateStaffPasswordByEmail(staffBean staff) {
        String sql = "UPDATE STAFF SET STAFFPASSWORD = ? WHERE STAFFEMAIL = ?";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, staff.getStaffPassword());
                ps.setString(2, staff.getStaffEmail());
                if (ps.executeUpdate() > 0) {
                    conn.commit();
                }
            } catch (SQLException e) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // SELECT - Get all staff
    public static List<staffBean> getAllStaff() {
        List<staffBean> staffList = new ArrayList<>();
        String query = "SELECT * FROM STAFF";
        Connection conn = ConnectionManager.getConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    staffBean s = new staffBean();
                    s.setStaffID(rs.getString("STAFFID"));
                    s.setStaffName(rs.getString("STAFFNAME"));
                    s.setStaffEmail(rs.getString("STAFFEMAIL"));
                    s.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                    s.setStaffRole(rs.getString("STAFFROLE"));
                    s.setManagerId(rs.getString("MANAGERID"));
                    
                    String encryptedPass = rs.getString("STAFFPASSWORD");
                    s.setStaffPassword(EncryptionUtil.decrypt(encryptedPass));
                    staffList.add(s);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return staffList;
    }

    // READ - Get specific staff by ID
    public staffBean getStaffById(String staffID) {
        staffBean staff = null;
        String query = "SELECT * FROM STAFF WHERE STAFFID = ?";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(query)) {
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
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return staff;
    }

    // READ - Get last ID for auto-generation (PostgreSQL syntax)
    public String getLastStaffId() {
        String lastId = null;
        String sql = "SELECT STAFFID FROM STAFF ORDER BY STAFFID DESC LIMIT 1";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    lastId = rs.getString("STAFFID");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return lastId;
    }

    // SELECT - Coordinators with monthly event count (PostgreSQL syntax)
    public List<staffBean> getAllCoordinators() {
        List<staffBean> list = new ArrayList<>();
        String sql = "SELECT s.*, " +
                     "(SELECT COUNT(*) FROM EVENT e " +
                     " WHERE e.STAFFID = s.STAFFID " +
                     " AND TO_CHAR(e.EVENTDATE, 'MM-YYYY') = TO_CHAR(CURRENT_DATE, 'MM-YYYY') " + 
                     ") as totalEvents " +
                     "FROM STAFF s WHERE s.STAFFROLE = 'COORDINATOR' ORDER BY s.STAFFID ASC";
        
        Connection conn = getSafeConnection();
        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(sql);
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
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return list;
    }

    // UPDATE - Update phone number with Commit
    public boolean updateStaffPhoneNum(staffBean staff) {
        String query = "UPDATE STAFF SET STAFFPHONENUM=? WHERE STAFFID=?";
        Connection conn = getSafeConnection();
        boolean success = false;

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, staff.getStaffPhoneNum());
                ps.setString(2, staff.getStaffID());
                if (ps.executeUpdate() > 0) {
                    conn.commit();
                    success = true;
                }
            } catch (SQLException e) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return success;
    }

    // DELETE - Staff deletion with Commit
    public void deleteStaff(String staffId) {
        String query = "DELETE FROM STAFF WHERE STAFFID = ?";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, staffId);
                if (ps.executeUpdate() > 0) {
                    conn.commit();
                }
            } catch (SQLException e) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // VALIDATION - Check email existence
    public boolean isEmailExists(String email) {
        boolean exists = false;
        String sql = "SELECT COUNT(*) FROM STAFF WHERE STAFFEMAIL = ?";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        exists = rs.getInt(1) > 0;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return exists;
    }

    // VALIDATION - Check phone existence (excluding current staff)
    public boolean isPhoneExists(String phoneNum, String currentStaffID) {
        boolean exists = false;
        String query = "SELECT COUNT(*) FROM STAFF WHERE STAFFPHONENUM = ? AND STAFFID != ?";
        Connection conn = getSafeConnection();

        if (conn != null) {
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, phoneNum);
                ps.setString(2, currentStaffID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        exists = rs.getInt(1) > 0;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return exists;
    }
}