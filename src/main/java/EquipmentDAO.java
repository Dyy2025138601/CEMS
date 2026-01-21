package cems;

import java.sql.*;
import java.util.*;

public class EquipmentDAO {

    /* ================= CONNECTION ================= */

    private static Connection getConnection() throws SQLException {
        return ConnectionManager.getConnection();
    }

    /* ================= SYNC TOTALS ================= */

    public static void syncEquipmentTotals(String eqpId) {

        String sql =
            "UPDATE equipment SET " +
            "totqtyinuse = COALESCE((SELECT SUM(qtyinuse) FROM eventequipment WHERE eqpid = ? AND returnstatus = 'N'),0), " +
            "totqtyavailable = eqptotqty - COALESCE((SELECT SUM(qtyinuse) FROM eventequipment WHERE eqpid = ? AND returnstatus = 'N'),0) " +
            "WHERE eqpid = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, eqpId);
            ps.setString(2, eqpId);
            ps.setString(3, eqpId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* ================= ADD EQUIPMENT ================= */

    public static boolean addEquipment(Equipment eqp) {
        try (Connection c = getConnection()) {

            String sql =
                "INSERT INTO equipment(eqpid, eqpname, eqpqty, totqtyavailable, eqptotqty) " +
                "VALUES (?, ?, ?, ?, ?)";

            PreparedStatement ps = c.prepareStatement(sql);
            ps.setString(1, eqp.getEqpID());
            ps.setString(2, eqp.getEqpName());
            ps.setInt(3, eqp.getEqpQty());
            ps.setInt(4, eqp.getEqpQty());
            ps.setInt(5, eqp.getEqpQty());
            ps.executeUpdate();

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ================= UPDATE QTY ================= */

    public static boolean updateEquipmentQty(String id, int qty) {

        String sql =
            "UPDATE equipment SET eqpqty = ?, totqtyavailable = ? WHERE eqpid = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, qty);
            ps.setInt(2, qty);
            ps.setString(3, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ================= GET EQUIPMENT ================= */

    public static Equipment getEquipmentById(String id) {

        String sql = "SELECT * FROM equipment WHERE eqpid = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Equipment e = new Equipment();
                e.setEqpID(rs.getString("eqpid"));
                e.setEqpName(rs.getString("eqpname"));
                e.setEqpQty(rs.getInt("eqpqty"));
                return e;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /* ================= ISSUE SUMMARY ================= */

    public static Map<String, Object> getEquipmentIssueSummary(String from, String to) {

        Map<String, Object> map = new HashMap<>();

        String sql =
            "SELECT condition, COUNT(*) FROM eventequipment ee " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "WHERE ev.eventdate BETWEEN ?::date AND ?::date " +
            "GROUP BY condition";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, from);
            ps.setString(2, to);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                map.put(rs.getString(1), rs.getInt(2));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    /* ================= DASHBOARD ================= */

    public static int getTotalEquipmentCount() {
        try (Connection c = getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM equipment")) {
            rs.next();
            return rs.getInt(1);
        } catch (Exception e) {
            return 0;
        }
    }

    public static double getEquipmentLossRate() {
        try (Connection c = getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(
                 "SELECT COALESCE(SUM(eqptotlost)::float / NULLIF(SUM(eqptotqty),0),0) FROM equipment")) {
            rs.next();
            return rs.getDouble(1);
        } catch (Exception e) {
            return 0;
        }
    }

    public static Map<String, Integer> getCategorizedConditionStats() {

        Map<String, Integer> map = new HashMap<>();

        String sql =
            "SELECT condition, COUNT(*) FROM eventequipment GROUP BY condition";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                map.put(rs.getString(1), rs.getInt(2));
            }

        } catch (Exception ignored) {}

        return map;
    }

    public static int getEquipmentStock(String eqpid) {

        String sql = "SELECT totqtyavailable FROM equipment WHERE eqpid = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, eqpid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception ignored) {}

        return 0;
    }

    public static int getBookedQtyOnDate(String eqpid, String date) {

        String sql =
            "SELECT COALESCE(SUM(qtyinuse),0) FROM eventequipment ee " +
            "JOIN event ev ON ee.eventid = ev.eventid " +
            "WHERE ee.eqpid = ? AND ev.eventdate = ?::date";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, eqpid);
            ps.setString(2, date);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception ignored) {}

        return 0;
    }
}
