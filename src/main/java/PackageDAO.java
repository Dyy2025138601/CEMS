package cems;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PackageDAO {

    // CREATE - Insert new package
    public static void addPackage(PackageCatering packageCatering) throws SQLException {
        String query = "INSERT INTO PACKAGECATERING (packID, packName, lowPackPax, highPackPax, packAvailability) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {

            ps.setString(1, packageCatering.getPackID());
            ps.setString(2, packageCatering.getPackName());
            ps.setInt(3, packageCatering.getLowPackPax());
            ps.setInt(4, packageCatering.getHighPackPax());
            ps.setString(5, String.valueOf(packageCatering.getPackAvailability()));

            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw e; 
        }
    }

    // SELECT - get all package
    public static List<PackageCatering> getAllPackages() throws SQLException {
        List<PackageCatering> packages = new ArrayList<>();
        String query = "SELECT * FROM PACKAGECATERING";
        
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                PackageCatering packageCatering = new PackageCatering();
                packageCatering.setPackID(rs.getString("packID"));
                packageCatering.setPackName(rs.getString("packName"));
                packageCatering.setLowPackPax(rs.getInt("lowPackPax"));
                packageCatering.setHighPackPax(rs.getInt("highPackPax"));
                packageCatering.setPackAvailability(rs.getString("packAvailability").charAt(0));
                packages.add(packageCatering);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return packages;
    }

    // READ - Get a package by ID
    public static PackageCatering getPackageById(String packID) throws SQLException {
        PackageCatering packageCatering = null;
        String query = "SELECT * FROM PACKAGECATERING WHERE packID = ?";
        
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, packID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    packageCatering = new PackageCatering();
                    packageCatering.setPackID(rs.getString("packID"));
                    packageCatering.setPackName(rs.getString("packName"));
                    packageCatering.setLowPackPax(rs.getInt("lowPackPax"));
                    packageCatering.setHighPackPax(rs.getInt("highPackPax"));
                    packageCatering.setPackAvailability(rs.getString("packAvailability").charAt(0));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return packageCatering;
    }

    // UPDATE - Modify an existing package
    public static void updatePackage(PackageCatering packageCatering) throws SQLException {
        String query = "UPDATE PACKAGECATERING SET packName=?, lowPackPax=?, highPackPax=?, packAvailability=? WHERE packID=?";
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {

            ps.setString(1, packageCatering.getPackName());
            ps.setInt(2, packageCatering.getLowPackPax());
            ps.setInt(3, packageCatering.getHighPackPax());
            ps.setString(4, String.valueOf(packageCatering.getPackAvailability()));
            ps.setString(5, packageCatering.getPackID()); // Fixed index from 6 to 5

            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
    }

    // LIST EQUIPMENT
    public static List<EquipmentPackage> getPackageContents(String packID) {
        List<EquipmentPackage> list = new ArrayList<>();
        String query = "SELECT ep.packID, ep.eqpID, ep.qtyRequired, ep.is_paxDepend, "
                    + "e.eqpName, s.serviceSet, p.eqpFunction FROM EQUIPMENTPACKAGE ep "
                    + "JOIN EQUIPMENT e ON ep.eqpID = e.eqpID " 
                    + "LEFT JOIN SERVICEEQUIPMENT s ON e.eqpID = s.eqpID "
                    + "LEFT JOIN SUPPORTEQUIPMENT p ON e.eqpID = p.eqpID " 
                    + "WHERE ep.packID = ? ORDER BY ep.eqpID DESC";

        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, packID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EquipmentPackage item = new EquipmentPackage();
                    item.setPackID(rs.getString("packID"));
                    item.setEqpID(rs.getString("eqpID"));
                    item.setQtyRequired(rs.getInt("qtyRequired"));

                    String dbValue = rs.getString("is_paxDepend");
                    item.setIs_paxDepend((dbValue != null && !dbValue.isEmpty()) ? dbValue.charAt(0) : 'N');

                    item.setEqpName(rs.getString("eqpName"));
                    item.setServiceSet(rs.getString("serviceSet"));
                    item.setEqpFunction(rs.getString("eqpFunction"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Get All Packages AND their Equipment List
    public static List<PackageCatering> getAllPackagesWithEquipment() {
        List<PackageCatering> fullList = new ArrayList<>();
        try {
            fullList = getAllPackages();
            for (PackageCatering pkg : fullList) {
                pkg.setEquipmentList(getPackageContents(pkg.getPackID()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return fullList;
    }

    // Update ONLY the quantity of equipment inside a package
    public static void updateContentQty(String packID, String eqpID, int newQty, char is_paxDepend) throws SQLException {
        String query = "UPDATE EQUIPMENTPACKAGE SET qtyRequired=?, is_paxDepend=? WHERE packID=? AND eqpID=?";
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setInt(1, newQty);
            ps.setString(2, String.valueOf(is_paxDepend));
            ps.setString(3, packID);
            ps.setString(4, eqpID);
            ps.executeUpdate();
        }
    }

    // GET AVAILABLE EQUIPMENT
    public static List<EquipmentPackage> getAvailableEquipmentForPackage(String packID) {
        List<EquipmentPackage> availableList = new ArrayList<>();
        String query = "SELECT e.eqpID, e.eqpName FROM EQUIPMENT e " 
                     + "WHERE e.eqpID NOT IN (SELECT ep.eqpID FROM EQUIPMENTPACKAGE ep WHERE ep.packID = ?)";

        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, packID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EquipmentPackage item = new EquipmentPackage();
                    item.setEqpID(rs.getString("eqpID"));
                    item.setEqpName(rs.getString("eqpName"));
                    availableList.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return availableList;
    }

    // INSERT NEW EQUIPMENT INTO PACKAGE
    public static boolean addPackageContent(String packID, String eqpID, int qty, char is_paxDepend) {
        String query = "INSERT INTO EQUIPMENTPACKAGE (packID, eqpID, qtyRequired, is_paxDepend) VALUES (?, ?, ?, ?)";
        try (Connection connection = ConnectionManager.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, packID);
            ps.setString(2, eqpID);
            ps.setInt(3, qty);
            ps.setString(4, String.valueOf(is_paxDepend));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Check Availability by Date
    public static List<PackageCatering> getPackagesByDateAvailability(String dateToCheck) {
        List<PackageCatering> list = new ArrayList<>();
        String sql = "SELECT p.*, " +
                     "CASE WHEN EXISTS ( " +
                     "    SELECT 1 FROM EQUIPMENTPACKAGE ep " +
                     "    JOIN EQUIPMENT e ON ep.eqpID = e.eqpID " +
                     "    LEFT JOIN ( " +
                     "        SELECT ee.eqpID, SUM(ee.qtyInUse) as total_used " +
                     "        FROM EVENTEQUIPMENT ee " +
                     "        JOIN EVENT ev ON ee.eventID = ev.eventID " +
                     "        WHERE ev.eventDate::date = ?::date " + 
                     "        GROUP BY ee.eqpID " +
                     "    ) usage ON ep.eqpID = usage.eqpID " +
                     "    WHERE ep.packID = p.packID " +
                     "    AND ( " +
                     "       e.eqpQty - COALESCE(usage.total_used, 0) < " +
                     "       (CASE WHEN ep.is_paxDepend = 'Y' THEN (ep.qtyRequired * p.lowPackPax) ELSE ep.qtyRequired END) " +
                     "    ) " +
                     ") THEN 'Unavailable' ELSE 'Available' END AS date_status " +
                     "FROM PACKAGECATERING p";

        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dateToCheck);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PackageCatering p = new PackageCatering();
                    p.setPackID(rs.getString("packID"));
                    p.setPackName(rs.getString("packName"));
                    p.setLowPackPax(rs.getInt("lowPackPax"));
                    p.setHighPackPax(rs.getInt("highPackPax"));
                    p.setPackAvailability(rs.getString("packAvailability").charAt(0));
                    p.setAvailabilityOnDate(rs.getString("date_status"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}