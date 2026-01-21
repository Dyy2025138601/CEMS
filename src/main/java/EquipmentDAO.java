package cems;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EquipmentDAO {

    // =============================
    // Generate Next ID (E001, E002)
    // =============================
    private static String generateNextId(Connection conn) throws SQLException {

        String sql =
            "SELECT eqpid FROM equipment " +
            "ORDER BY LENGTH(eqpid) DESC, eqpid DESC " +
            "LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                String lastId = rs.getString("eqpid");
                int num = Integer.parseInt(lastId.replaceAll("[^0-9]", ""));
                return String.format("E%03d", num + 1);
            }
            return "E001";
        }
    }

    // =============================
    // CREATE
    // =============================
    public static boolean addEquipment(Equipment eqp) {

        String sqlParent =
            "INSERT INTO equipment " +
            "(eqpid, eqpname, eqpqty, eqpimage, totqtyavailable, eqptotqty, totqtyinuse, eqptotdamage, eqptotlost) " +
            "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0)";

        Connection conn = null;

        try {
            conn = ConnectionManager.getConnection();
            conn.setAutoCommit(false);

            String nextId = generateNextId(conn);

            try (PreparedStatement ps = conn.prepareStatement(sqlParent)) {

                ps.setString(1, nextId);
                ps.setString(2, eqp.getEqpName());
                ps.setInt(3, eqp.getEqpQty());
                ps.setString(4, eqp.getEqpImage());
                ps.setInt(5, eqp.getEqpQty());
                ps.setInt(6, eqp.getEqpQty());

                ps.executeUpdate();
            }

            if (eqp instanceof ServiceEquipment) {
                String sql =
                    "INSERT INTO serviceequipment (eqpid, serviceset) VALUES (?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, nextId);
                    ps.setString(2,
                        ((ServiceEquipment) eqp).getServiceSet() == null
                            ? "GUEST"
                            : ((ServiceEquipment) eqp).getServiceSet());
                    ps.executeUpdate();
                }

            } else if (eqp instanceof SupportEquipment) {
                String sql =
                    "INSERT INTO supportequipment (eqpid, eqpfunction) VALUES (?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, nextId);
                    ps.setString(2,
                        ((SupportEquipment) eqp).getEqpFunction() == null
                            ? "STORAGE"
                            : ((SupportEquipment) eqp).getEqpFunction());
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ignored) {}
            e.printStackTrace();
            return false;

        } finally {
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }

    // =============================
    // READ ALL EQUIPMENT
    // =============================
    public List<Equipment> getAllEquipment() {

        List<Equipment> list = new ArrayList<>();

        String sql =
            "SELECT e.*, s.serviceset, su.eqpfunction, " +
            " (SELECT COALESCE(SUM(ee.qtyinuse),0) " +
            "  FROM eventequipment ee " +
            "  JOIN event ev ON ee.eventid = ev.eventid " +
            "  WHERE ee.eqpid = e.eqpid " +
            "  AND DATE(ev.eventdate) = CURRENT_DATE " +
            "  AND ee.returnstatus = 'N') AS day_qty_in_use " +
            "FROM equipment e " +
            "LEFT JOIN serviceequipment s ON e.eqpid = s.eqpid " +
            "LEFT JOIN supportequipment su ON e.eqpid = su.eqpid " +
            "ORDER BY e.eqpid";

        try (Connection conn = ConnectionManager.getConnection();
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

                eqp.setTotQtyInUse(rs.getInt("day_qty_in_use"));
                eqp.setTotQtyAvailable(rs.getInt("totqtyavailable"));
                eqp.setEqpTotQty(rs.getInt("eqptotqty"));
                eqp.setEqpTotDamage(rs.getInt("eqptotdamage"));
                eqp.setEqpTotLost(rs.getInt("eqptotlost"));

                list.add(eqp);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // =============================
    // DATE RANGE SUMMARY
    // =============================
    public java.util.Map<String, Object> getEquipmentIssueSummary(String start, String end)
            throws SQLException {

        java.util.Map<String, Object> summary = new java.util.HashMap<>();
        List<java.util.Map<String, Object>> details = new ArrayList<>();

        String sql =
            "SELECT e.eqpid, e.eqpname, e.totqtyinuse, " +
            "ee.qtydamage, ee.qtylost, " +
            "COALESCE(s.serviceset, su.eqpfunction, '-') AS eqp_type " +
            "FROM equipment e " +
            "JOIN eventequipment ee ON e.eqpid = ee.eqpid " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "LEFT JOIN serviceequipment s ON e.eqpid = s.eqpid " +
            "LEFT JOIN supportequipment su ON e.eqpid = su.eqpid " +
            "WHERE ev.eventdate BETWEEN ? AND ? " +
            "AND (ee.qtydamage > 0 OR ee.qtylost > 0)";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));

            long totalInUse = 0, totalDamage = 0, totalLost = 0;

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {

                    int inUse = rs.getInt("totqtyinuse");
                    int damage = rs.getInt("qtydamage");
                    int lost = rs.getInt("qtylost");

                    totalInUse += inUse;
                    totalDamage += damage;
                    totalLost += lost;

                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("id", rs.getString("eqpid"));
                    row.put("name", rs.getString("eqpname"));
                    row.put("type", rs.getString("eqp_type"));
                    row.put("totalInUse", inUse);
                    row.put("damaged", damage);
                    row.put("lost", lost);

                    details.add(row);
                }
            }

            summary.put("details", details);
            summary.put("totalAssigned", totalInUse);
            summary.put("totalDamaged", totalDamage);
            summary.put("totalLost", totalLost);
        }

        return summary;
    }
}
