package cems;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PackageDAO {
	private static Connection connection = null;

	// CREATE - Insert new package
	public static void addPackage(PackageCatering packageCatering) throws SQLException {
		try {
			String query = "INSERT INTO packageCatering (packID, packName, lowPackPax, highPackPax, packAvailability) VALUES (?, ?, ?, ?, ?)";
			connection = ConnectionManager.getConnection();
			PreparedStatement ps = connection.prepareStatement(query);

			ps.setString(1, packageCatering.getPackID());
			ps.setString(2, packageCatering.getPackName());
			ps.setInt(3, packageCatering.getLowPackPax());
			ps.setInt(4, packageCatering.getHighPackPax());
			ps.setString(5, String.valueOf(packageCatering.getPackAvailability()));

			ps.executeUpdate();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	// SELECT - get all package
	public static List<PackageCatering> getAllPackages() throws SQLException {
		List<PackageCatering> packages = new ArrayList<>();

		try {
			String query = "SELECT * FROM packageCatering";
			connection = ConnectionManager.getConnection();
			PreparedStatement ps = connection.prepareStatement(query);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				PackageCatering packageCatering = new PackageCatering();

				packageCatering.setPackID(rs.getString("packID"));
				packageCatering.setPackName(rs.getString("packName"));
				packageCatering.setLowPackPax(rs.getInt("lowPackPax"));
				packageCatering.setHighPackPax(rs.getInt("highPackPax"));
				packageCatering.setPackAvailability(rs.getString("packAvailability").charAt(0));

				packages.add(packageCatering);

			}

			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return packages;
	}

	// READ - Get a package by ID
	public static PackageCatering getPackageById(String packID) throws SQLException {
		PackageCatering packageCatering = null;

		try {
			String query = "SELECT * FROM packageCatering WHERE packID = ?";
			connection = ConnectionManager.getConnection();
			PreparedStatement ps = connection.prepareStatement(query);
			ps.setString(1, packID);
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				packageCatering = new PackageCatering();
				packageCatering.setPackID(rs.getString("packID"));
				packageCatering.setPackName(rs.getString("packName"));
				packageCatering.setLowPackPax(rs.getInt("lowPackPax"));
				packageCatering.setHighPackPax(rs.getInt("highPackPax"));
				packageCatering.setPackAvailability(rs.getString("packAvailability").charAt(0));

			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return packageCatering;
	}

	// UPDATE - Modify an existing package
	public static void updatePackage(PackageCatering packageCatering) throws SQLException {
		try {
			String query = "UPDATE packageCatering SET packName=?, lowPackPax=?, highPackPax=?, packAvailability=? WHERE packID=?";
			connection = ConnectionManager.getConnection();
			PreparedStatement ps = connection.prepareStatement(query);

			ps.setString(1, packageCatering.getPackName());
			ps.setInt(2, packageCatering.getLowPackPax());
			ps.setInt(3, packageCatering.getHighPackPax());
			ps.setString(4, String.valueOf(packageCatering.getPackAvailability()));
			ps.setString(6, packageCatering.getPackID());

			ps.executeUpdate();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	// LIST EQUIPMENT
	public static List<EquipmentPackage> getPackageContents(String packID) {
		List<EquipmentPackage> list = new ArrayList<>();
		try {
			String query = "SELECT ep.packID, ep.eqpID, ep.qtyRequired, ep.is_paxDepend, "
					+ "e.eqpName, s.serviceSet, p.eqpFunction " + "FROM equipmentPackage ep "
					+ "JOIN equipment e ON ep.eqpID = e.eqpID " + "LEFT JOIN serviceEquipment s ON e.eqpID = s.eqpID "
					+ "LEFT JOIN supportEquipment p ON e.eqpID = p.eqpID " + "WHERE ep.packID = ? "
					+ "ORDER BY ep.eqpID DESC";

			connection = ConnectionManager.getConnection();
			PreparedStatement ps = connection.prepareStatement(query);
			ps.setString(1, packID);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				EquipmentPackage item = new EquipmentPackage();
				item.setPackID(rs.getString("packID"));
				item.setEqpID(rs.getString("eqpID"));
				item.setQtyRequired(rs.getInt("qtyRequired"));

				String dbValue = rs.getString("is_paxDepend");

				// 2. Convert to char (handle nulls safely)
				if (dbValue != null && !dbValue.isEmpty()) {
					item.setIs_paxDepend(dbValue.charAt(0));
				} else {
					item.setIs_paxDepend('N');
				}

				item.setEqpName(rs.getString("eqpName"));
				item.setServiceSet(rs.getString("serviceSet"));
				item.setEqpFunction(rs.getString("eqpFunction"));

				list.add(item);
			}
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}
	/*
	 * public static List<EquipmentPackage> getPackageContents(String packID) {
	 * List<EquipmentPackage> list = new ArrayList<>(); try { String query =
	 * "SELECT ep.packID, ep.eqpID, ep.qtyRequired, e.eqpName, " +
	 * "s.serviceSet, p.eqpFunction " + "FROM equipmentPackage ep " +
	 * "JOIN equipment e ON ep.eqpID = e.eqpID " +
	 * "LEFT JOIN serviceEquipment s ON e.eqpID = s.eqpID " +
	 * "LEFT JOIN supportEquipment p ON e.eqpID = p.eqpID " + "WHERE ep.packID = ? "
	 * + "ORDER BY ep.eqpID DESC";
	 * 
	 * connection = ConnectionManager.getConnection(); PreparedStatement ps =
	 * connection.prepareStatement(query); ps.setString(1, packID); ResultSet rs =
	 * ps.executeQuery();
	 * 
	 * while (rs.next()) { EquipmentPackage item = new EquipmentPackage();
	 * item.setPackID(rs.getString("packID")); item.setEqpID(rs.getString("eqpID"));
	 * item.setQtyRequired(rs.getInt("qtyRequired"));
	 * item.setEqpName(rs.getString("eqpName")); // Name from JOIN
	 * 
	 * item.setServiceSet(rs.getString("serviceSet"));
	 * item.setEqpFunction(rs.getString("eqpFunction"));
	 * 
	 * list.add(item); } ps.close(); } catch (SQLException e) { e.printStackTrace();
	 * } return list; }
	 */

	// Get All Packages AND their Equipment List
	// Used by EventController (showCreateForm)
	public static List<PackageCatering> getAllPackagesWithEquipment() {
		List<PackageCatering> fullList = new ArrayList<>();

		try {
			fullList = getAllPackages();

			// 2. Loop through each package and fetch its equipment
			for (PackageCatering pkg : fullList) {

				List<EquipmentPackage> eqList = getPackageContents(pkg.getPackID());

				// Attach the list to the package object
				pkg.setEquipmentList(eqList);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return fullList;
	}

	// Update ONLY the quantity of equipment inside a package
	public static void updateContentQty(String packID, String eqpID, int newQty, char is_paxDepend)
			throws SQLException {

		String query = "UPDATE equipmentPackage SET qtyRequired=?, is_paxDepend=? WHERE packID=? AND eqpID=?";

		try (Connection connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query)) {

			ps.setInt(1, newQty);
			ps.setString(2, String.valueOf(is_paxDepend));
			ps.setString(3, packID);
			ps.setString(4, eqpID);

			ps.executeUpdate();
		}
	}

	// GET AVAILABLE EQUIPMENT (Exclude equipmennts already in the package)
	public static List<EquipmentPackage> getAvailableEquipmentForPackage(String packID) {
		List<EquipmentPackage> availableList = new ArrayList<>();

		// Logic: Select all Equipment EXCEPT those present in the join table for this
		// packID
		String query = "SELECT e.eqpID, e.eqpName " + "FROM equipment e " + "WHERE e.eqpID NOT IN ("
				+ "    SELECT ep.eqpID " + "    FROM equipmentPackage ep " + "    WHERE ep.packID = ?" + ")";

		try (Connection connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query)) {

			ps.setString(1, packID);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				// Using EquipmentPackage as a container for the dropdown data
				EquipmentPackage item = new EquipmentPackage();
				item.setEqpID(rs.getString("eqpID"));
				item.setEqpName(rs.getString("eqpName"));

				availableList.add(item);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return availableList;
	}

	// INSERT NEW EQUIPMENT INTO PACKAGE
	public static boolean addPackageContent(String packID, String eqpID, int qty, char is_paxDepend) {

		String query = "INSERT INTO equipmentPackage (packID, eqpID, qtyRequired, is_paxDepend) VALUES (?, ?, ?, ?)";

		try (Connection connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query)) {

			ps.setString(1, packID);
			ps.setString(2, eqpID);
			ps.setInt(3, qty);

			// ADDED: Set the value ("Y" or "N")
			ps.setString(4, String.valueOf(is_paxDepend));

			int rowsAffected = ps.executeUpdate();
			return rowsAffected > 0;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public static List<PackageCatering> getPackagesByDateAvailability(String dateToCheck) {
	    List<PackageCatering> list = new ArrayList<>();
	    
	    // SQL LOGIC:
	    // 1. Calculate 'USED_ON_DATE' for every item.
	    // 2. Compare (Total - Used) vs (Package Requirement * LowPax).
	    // 3. If ANY item in the package is short, the whole package is 'Unavailable'.
	    
	    String sql = "SELECT p.*, " +
	                 "CASE WHEN EXISTS ( " +
	                 "    SELECT 1 " +
	                 "    FROM EquipmentPackage ep " +
	                 "    JOIN Equipment e ON ep.eqpID = e.eqpID " +
	                 "    LEFT JOIN ( " +
	                 "        SELECT ee.eqpID, SUM(ee.qtyInUse) as total_used " +
	                 "        FROM EventEquipment ee " +
	                 "        JOIN Event ev ON ee.eventID = ev.eventID " +
	                 "        WHERE ev.eventDate = ? " +
	                 "        GROUP BY ee.eqpID " +
	                 "    ) usage ON ep.eqpID = usage.eqpID " +
	                 "    WHERE ep.packID = p.packID " +
	                 "    AND ( " +
	                 "       e.eqpQty - COALESCE(usage.total_used, 0) < " +
	                 "       (CASE WHEN ep.is_paxDepend = 'Y' THEN (ep.qtyRequired * p.lowPackPax) ELSE ep.qtyRequired END) " +
	                 "    ) " +
	                 ") THEN 'Unavailable' ELSE 'Available' END AS date_status " +
	                 "FROM PackageCatering p";

	    try (Connection conn = ConnectionManager.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        
	        // Use java.sql.Date to ensure format matches DB
	        ps.setDate(1, java.sql.Date.valueOf(dateToCheck));
	        
	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                PackageCatering p = new PackageCatering();
	                p.setPackID(rs.getString("packID"));
	                p.setPackName(rs.getString("packName"));
	                p.setLowPackPax(rs.getInt("lowPackPax"));
	                p.setHighPackPax(rs.getInt("highPackPax"));
	                p.setPackAvailability(rs.getString("packAvailability").charAt(0));
	                
	                // Set the calculated status
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
