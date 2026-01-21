package cems;

import java.sql.*;
import java.util.*;

public class EquipmentDAO {

    // ======================================================
    // Generate next Equipment ID (E001, E002...)
    // ======================================================
    private static String generateNextId(Connection conn) throws SQLException {

        String sql =
            "SELECT eqpid FROM equipment " +
            "ORDER BY LENGTH(eqpid) DESC, eqpid DESC LIMIT 1";

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

    // ======================================================
    // CREATE EQUIPMENT
    // ======================================================
    public static boolean addEquipment(Equipment eqp) {

        String sql =
            "INSERT INTO equipment " +
            "(eqpid, eqpname, eqpqty, eqpimage, totqtyavailable, eqptotqty, totqtyinuse, eqptotdamage, eqptotlost) " +
            "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0)";

        Connection conn = null;

        try {
            conn = ConnectionManager.getConnection();
            conn.setAutoCommit(false);

            String id = generateNextId(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                ps.setString(2, eqp.getEqpName());
                ps.setInt(3, eqp.getEqpQty());
                ps.setString(4, eqp.getEqpImage());
                ps.setInt(5, eqp.getEqpQty());
                ps.setInt(6, eqp.getEqpQty());
                ps.executeUpdate();
            }

            if (eqp instanceof ServiceEquipment) {
                String child =
                    "INSERT INTO serviceequipment (eqpid, serviceset) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(child)) {
                    ps.setString(1, id);
                    ps.setString(2,
                        ((ServiceEquipment) eqp).getServiceSet() == null
                            ? "GUEST"
                            : ((ServiceEquipment) eqp).getServiceSet());
                    ps.executeUpdate();
                }
            }

            if (eqp instanceof SupportEquipment) {
                String child =
                    "INSERT INTO supportequipment (eqpid, eqpfunction) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(child)) {
                    ps.setString(1, id);
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
            try { if (conn != null) conn.rollback(); } catch (Exception ignored) {}
            e.printStackTrace();
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }

    // ======================================================
    // READ ALL EQUIPMENT
    // ======================================================
    public List<Equipment> getAllEquipment() {

        List<Equipment> list = new ArrayList<>();

        String sql =
            "SELECT e.*, s.serviceset, su.eqpfunction, " +
            "(SELECT COALESCE(SUM(ee.qtyinuse),0) " +
            " FROM eventequipment ee " +
            " JOIN event ev ON ee.eventid = ev.eventid " +
            " WHERE ee.eqpid = e.eqpid " +
            " AND DATE(ev.eventdate) = CURRENT_DATE " +
            " AND ee.returnstatus = 'N') AS day_qty_in_use " +
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

    // ======================================================
    // GET EQUIPMENT BY ID
    // ======================================================
    public Equipment getEquipmentById(String id) {

        String sql =
            "SELECT e.*, s.serviceset, su.eqpfunction " +
            "FROM equipment e " +
            "LEFT JOIN serviceequipment s ON e.eqpid = s.eqpid " +
            "LEFT JOIN supportequipment su ON e.eqpid = su.eqpid " +
            "WHERE e.eqpid = ?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

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
                    eqp.setTotQtyInUse(rs.getInt("totqtyinuse"));
                    eqp.setTotQtyAvailable(rs.getInt("totqtyavailable"));
                    eqp.setEqpTotQty(rs.getInt("eqptotqty"));
                    eqp.setEqpTotDamage(rs.getInt("eqptotdamage"));
                    eqp.setEqpTotLost(rs.getInt("eqptotlost"));

                    return eqp;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // ======================================================
    // UPDATE QTY
    // ======================================================
    public static boolean updateEquipmentQty(String id, int qty) {

        String select = "SELECT eqpqty FROM equipment WHERE eqpid = ?";
        String update =
            "UPDATE equipment SET eqpqty = ?, " +
            "totqtyavailable = totqtyavailable + ?, " +
            "eqptotqty = eqptotqty + ? " +
            "WHERE eqpid = ?";

        try (Connection conn = ConnectionManager.getConnection()) {

            int oldQty = 0;

            try (PreparedStatement ps = conn.prepareStatement(select)) {
                ps.setString(1, id);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) oldQty = rs.getInt(1);
            }

            int diff = qty - oldQty;

            try (PreparedStatement ps = conn.prepareStatement(update)) {
                ps.setInt(1, qty);
                ps.setInt(2, diff);
                ps.setInt(3, diff);
                ps.setString(4, id);
                return ps.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ======================================================
    // DASHBOARD METRICS
    // ======================================================
    public static int getTotalEquipmentCount() {

        String sql = "SELECT COALESCE(SUM(eqptotqty),0) FROM equipment";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static double getEquipmentLossRate() {

        String sql =
            "SELECT (SUM(eqptotdamage + eqptotlost) * 100.0) / " +
            "NULLIF(SUM(eqptotqty), 0) FROM equipment";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getDouble(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public static String getCategorizedConditionStats() {

        String query =
            "SELECT category, SUM(totqtyavailable) good, " +
            "SUM(eqptotdamage) damage, SUM(eqptotlost) lost FROM (" +
            " SELECT s.serviceset category, e.* FROM equipment e JOIN serviceequipment s ON e.eqpid=s.eqpid " +
            " UNION ALL " +
            " SELECT p.eqpfunction category, e.* FROM equipment e JOIN supportequipment p ON e.eqpid=p.eqpid " +
            ") x GROUP BY category";

        StringBuilder labels = new StringBuilder();
        StringBuilder good = new StringBuilder();
        StringBuilder damage = new StringBuilder();
        StringBuilder lost = new StringBuilder();

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            boolean first = true;

            while (rs.next()) {
                if (!first) {
                    labels.append(",");
                    good.append(",");
                    damage.append(",");
                    lost.append(",");
                }

                labels.append("'").append(rs.getString("category")).append("'");
                good.append(rs.getInt("good"));
                damage.append(rs.getInt("damage"));
                lost.append(rs.getInt("lost"));

                first = false;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return labels + "|" + good + "|" + damage + "|" + lost;
    }

    // ======================================================
    // EXTRA FUNCTIONS
    // ======================================================
    public List<Map<String, Object>> getUsageHistory(String eqpID) {

        List<Map<String, Object>> list = new ArrayList<>();

        String sql =
            "SELECT s.staffname, ev.eventname, ev.eventdate, " +
            "ee.qtydamage, ee.qtylost " +
            "FROM eventequipment ee " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "LEFT JOIN staff s ON ev.staffid = s.staffid " +
            "WHERE ee.eqpid = ? AND (ee.qtydamage > 0 OR ee.qtylost > 0) " +
            "ORDER BY ev.eventdate DESC";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eqpID);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("staffName", rs.getString("staffname"));
                row.put("eventName", rs.getString("eventname"));
                row.put("eventDate", rs.getDate("eventdate"));
                row.put("qtyDamage", rs.getInt("qtydamage"));
                row.put("qtyLost", rs.getInt("qtylost"));
                list.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public void syncEquipmentTotals(String eqpID) {

        String sql =
            "UPDATE equipment SET " +
            "eqptotdamage = (SELECT COALESCE(SUM(qtydamage),0) FROM eventequipment WHERE eqpid=?), " +
            "eqptotlost   = (SELECT COALESCE(SUM(qtylost),0) FROM eventequipment WHERE eqpid=?) " +
            "WHERE eqpid=?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eqpID);
            ps.setString(2, eqpID);
            ps.setString(3, eqpID);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int getEquipmentStock(String eqpID) {

        String sql = "SELECT eqpqty FROM equipment WHERE eqpid=?";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eqpID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getBookedQtyOnDate(String eqpID, String date) {

        String sql =
            "SELECT COALESCE(SUM(ee.qtyinuse),0) " +
            "FROM eventequipment ee " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "WHERE ee.eqpid = ? " +
            "AND ev.eventdate = ? " +
            "AND ev.is_deleted = 0";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eqpID);
            ps.setDate(2, java.sql.Date.valueOf(date));

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
