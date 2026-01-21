package cems;

import java.sql.*;
import java.util.*;

public class EquipmentDAO {

    /* =====================================================
       DATABASE CONNECTION
    ====================================================== */

    private Connection getConnection() throws SQLException {
        return ConnectionManager.getConnection();
    }

    /* =====================================================
       ID GENERATION
    ====================================================== */

    private String generateNextId(Connection conn) throws SQLException {

        String sql =
                "SELECT eqpid FROM equipment " +
                "ORDER BY length(eqpid) DESC, eqpid DESC LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                String last = rs.getString("eqpid");
                int num = Integer.parseInt(last.replaceAll("\\D", ""));
                return String.format("E%03d", num + 1);
            }
        }
        return "E001";
    }

    /* =====================================================
       ADD EQUIPMENT
    ====================================================== */

    public boolean addEquipment(Equipment eqp) {

        Connection conn = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String newId = generateNextId(conn);

            String sql =
                "INSERT INTO equipment " +
                "(eqpid, eqpname, eqpqty, eqpimage, totqtyavailable, eqptotqty, totqtyinuse, eqptotdamage, eqptotlost) " +
                "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newId);
                ps.setString(2, eqp.getEqpName());
                ps.setInt(3, eqp.getEqpQty());
                ps.setString(4, eqp.getEqpImage());
                ps.setInt(5, eqp.getEqpQty());
                ps.setInt(6, eqp.getEqpQty());
                ps.executeUpdate();
            }

            if (eqp instanceof ServiceEquipment se) {

                String s =
                        "INSERT INTO serviceequipment(eqpid, serviceset) VALUES (?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(s)) {
                    ps.setString(1, newId);
                    ps.setString(2,
                            se.getServiceSet() == null ? "GENERAL" : se.getServiceSet());
                    ps.executeUpdate();
                }

            } else if (eqp instanceof SupportEquipment su) {

                String s =
                        "INSERT INTO supportequipment(eqpid, eqpfunction) VALUES (?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(s)) {
                    ps.setString(1, newId);
                    ps.setString(2,
                            su.getEqpFunction() == null ? "STORAGE" : su.getEqpFunction());
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ignored) {}
            e.printStackTrace();
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }

    /* =====================================================
       GET ALL EQUIPMENT
    ====================================================== */

    public List<Equipment> getAllEquipment() {

        List<Equipment> list = new ArrayList<>();

        String sql =
            "SELECT e.*, s.serviceset, su.eqpfunction, " +
            "COALESCE((" +
            " SELECT SUM(ee.qtyinuse) FROM eventequipment ee " +
            " JOIN event ev ON ee.eventid = ev.eventid " +
            " WHERE ee.eqpid = e.eqpid " +
            " AND DATE(ev.eventdate) = CURRENT_DATE " +
            " AND ee.returnstatus = 'N'" +
            "),0) AS todayuse " +
            "FROM equipment e " +
            "LEFT JOIN serviceequipment s ON e.eqpid = s.eqpid " +
            "LEFT JOIN supportequipment su ON e.eqpid = su.eqpid " +
            "ORDER BY e.eqpid";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Equipment eqp;

                if (rs.getString("serviceset") != null) {
                    ServiceEquipment s = new ServiceEquipment();
                    s.setServiceSet(rs.getString("serviceset"));
                    eqp = s;
                } else {
                    SupportEquipment su = new SupportEquipment();
                    su.setEqpFunction(rs.getString("eqpfunction"));
                    eqp = su;
                }

                eqp.setEqpID(rs.getString("eqpid"));
                eqp.setEqpName(rs.getString("eqpname"));
                eqp.setEqpQty(rs.getInt("eqpqty"));
                eqp.setEqpImage(rs.getString("eqpimage"));

                eqp.setTotQtyInUse(rs.getInt("todayuse"));
                eqp.setTotQtyAvailable(rs.getInt("totqtyavailable"));
                eqp.setEqpTotQty(rs.getInt("eqptotqty"));
                eqp.setEqpTotDamage(rs.getInt("eqptotdamage"));
                eqp.setEqpTotLost(rs.getInt("eqptotlost"));

                list.add(eqp);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /* =====================================================
       GET EQUIPMENT BY ID
    ====================================================== */

    public Equipment getEquipmentById(String id) {

        String sql =
            "SELECT e.*, s.serviceset, su.eqpfunction " +
            "FROM equipment e " +
            "LEFT JOIN serviceequipment s ON e.eqpid = s.eqpid " +
            "LEFT JOIN supportequipment su ON e.eqpid = su.eqpid " +
            "WHERE e.eqpid = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) return null;

                Equipment eqp;

                if (rs.getString("serviceset") != null) {
                    ServiceEquipment s = new ServiceEquipment();
                    s.setServiceSet(rs.getString("serviceset"));
                    eqp = s;
                } else {
                    SupportEquipment su = new SupportEquipment();
                    su.setEqpFunction(rs.getString("eqpfunction"));
                    eqp = su;
                }

                eqp.setEqpID(rs.getString("eqpid"));
                eqp.setEqpName(rs.getString("eqpname"));
                eqp.setEqpQty(rs.getInt("eqpqty"));
                eqp.setEqpImage(rs.getString("eqpimage"));

                eqp.setTotQtyAvailable(rs.getInt("totqtyavailable"));
                eqp.setEqpTotQty(rs.getInt("eqptotqty"));
                eqp.setEqpTotDamage(rs.getInt("eqptotdamage"));
                eqp.setEqpTotLost(rs.getInt("eqptotlost"));

                return eqp;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /* =====================================================
       UPDATE EQUIPMENT QUANTITY
    ====================================================== */

    public boolean updateEquipmentQty(String eqpId, int qty) {

        String sql =
            "UPDATE equipment SET eqpqty = ?, totqtyavailable = ? WHERE eqpid = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, qty);
            ps.setInt(2, qty);
            ps.setString(3, eqpId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* =====================================================
       TOTAL EQUIPMENT COUNT
    ====================================================== */

    public int getTotalEquipmentCount() {

        String sql = "SELECT COUNT(*) FROM equipment";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* =====================================================
       ISSUE SUMMARY (USED BY CONTROLLER)
    ====================================================== */

    public Map<String, Integer> getEquipmentIssueSummary(String from, String to) {

        Map<String, Integer> map = new HashMap<>();

        String sql =
            "SELECT condition, COUNT(*) " +
            "FROM eventequipment ee " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "WHERE ev.eventdate BETWEEN ?::date AND ?::date " +
            "GROUP BY condition";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, from);
            ps.setString(2, to);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString(1), rs.getInt(2));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    /* =====================================================
       USAGE HISTORY
    ====================================================== */

    public List<Map<String, Object>> getUsageHistory(String eqpid) {

        List<Map<String, Object>> list = new ArrayList<>();

        String sql =
            "SELECT ev.eventdate, ee.qtyinuse " +
            "FROM eventequipment ee " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "WHERE ee.eqpid = ? " +
            "ORDER BY ev.eventdate";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eqpid);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("date", rs.getDate(1));
                    m.put("qty", rs.getInt(2));
                    list.add(m);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
