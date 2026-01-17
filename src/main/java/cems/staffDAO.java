package cems;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class staffDAO {

    // =============================
    // CREATE STAFF
    // =============================
    public static void addStaff(staffBean staff) {

        String sql =
            "INSERT INTO staff " +
            "(staffname, staffemail, staffphonenum, staffpassword, staffrole, managerid) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staff.getStaffName());
            ps.setString(2, staff.getStaffEmail());
            ps.setString(3, staff.getStaffPhoneNum());
            ps.setString(4, staff.getStaffPassword());
            ps.setString(5, staff.getStaffRole());
            ps.setNull(6, java.sql.Types.VARCHAR);

            ps.executeUpdate();
            conn.commit();

            System.out.println("✅ Staff registered (PostgreSQL)");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // =============================
    // LOGIN
    // =============================
    public staffBean loginStaff(String email, String password, String role) {

        staffBean staff = null;

        String sql =
            "SELECT * FROM staff " +
            "WHERE staffemail = ? AND staffpassword = ? AND staffrole = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);
            ps.setString(3, role);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                staff = new staffBean();
                staff.setStaffID(rs.getString("staffid"));
                staff.setStaffName(rs.getString("staffname"));
                staff.setStaffEmail(rs.getString("staffemail"));
                staff.setStaffPhoneNum(rs.getString("staffphonenum"));
                staff.setStaffPassword(rs.getString("staffpassword"));
                staff.setStaffRole(rs.getString("staffrole"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staff;
    }

    // =============================
    // GET ALL STAFF
    // =============================
    public static List<staffBean> getAllStaff() {

        List<staffBean> list = new ArrayList<>();

        String sql = "SELECT * FROM staff";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                staffBean s = new staffBean();
                s.setStaffID(rs.getString("staffid"));
                s.setStaffName(rs.getString("staffname"));
                s.setStaffEmail(rs.getString("staffemail"));
                s.setStaffPhoneNum(rs.getString("staffphonenum"));
                s.setStaffPassword(rs.getString("staffpassword"));
                s.setStaffRole(rs.getString("staffrole"));
                s.setManagerId(rs.getString("managerid"));
                list.add(s);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // =============================
    // GET STAFF BY ID
    // =============================
    public static staffBean getStaffById(String staffID) {

        staffBean staff = null;

        String sql = "SELECT * FROM staff WHERE staffid = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffID);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                staff = new staffBean();
                staff.setStaffID(rs.getString("staffid"));
                staff.setStaffName(rs.getString("staffname"));
                staff.setStaffEmail(rs.getString("staffemail"));
                staff.setStaffPhoneNum(rs.getString("staffphonenum"));
                staff.setStaffPassword(rs.getString("staffpassword"));
                staff.setStaffRole(rs.getString("staffrole"));
                staff.setManagerId(rs.getString("managerid"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return staff;
    }

    // =============================
    // COORDINATOR LIST
    // =============================
    public List<staffBean> getAllCoordinators() {

        List<staffBean> list = new ArrayList<>();

        String sql =
            "SELECT * FROM staff WHERE staffrole = 'COORDINATOR'";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                staffBean s = new staffBean();
                s.setStaffID(rs.getString("staffid"));
                s.setStaffName(rs.getString("staffname"));
                s.setStaffEmail(rs.getString("staffemail"));
                s.setStaffPhoneNum(rs.getString("staffphonenum"));
                s.setStaffRole(rs.getString("staffrole"));
                list.add(s);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // =============================
    // UPDATE PHONE
    // =============================
    public static void updateStaffPhoneNum(staffBean staff) {

        String sql =
            "UPDATE staff SET staffphonenum = ? WHERE staffid = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staff.getStaffPhoneNum());
            ps.setString(2, staff.getStaffID());

            ps.executeUpdate();
            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // =============================
    // UPDATE PASSWORD
    // =============================
    public static void updateStaffPassword(staffBean staff) {

        String sql =
            "UPDATE staff SET staffpassword = ? WHERE staffid = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staff.getStaffPassword());
            ps.setString(2, staff.getStaffID());

            ps.executeUpdate();
            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // =============================
    // DELETE STAFF
    // =============================
    public static void deleteStaff(String staffID) {

        String sql = "DELETE FROM staff WHERE staffid = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffID);
            ps.executeUpdate();
            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // =============================
    // CHECK EMAIL EXISTS
    // =============================
    public boolean isEmailExists(String email) {

        boolean exists = false;

        String sql =
            "SELECT COUNT(*) FROM staff WHERE staffemail = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return exists;
    }
}
