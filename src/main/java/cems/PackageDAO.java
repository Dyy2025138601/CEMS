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
				String query = "INSERT INTO packageCatering (packID, packName, lowPackPax, highPackPax, packAvailability, companyAvailability) VALUES (?, ?, ?, ?, ?, ?)";
				connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query);

				ps.setString(1, packageCatering.getPackID());
				ps.setString(2, packageCatering.getPackName());
				ps.setInt(3, packageCatering.getLowPackPax());
				ps.setInt(4, packageCatering.getHighPackPax());
				ps.setString(5, String.valueOf(packageCatering.getPackAvailability()));
				ps.setString(6, String.valueOf(packageCatering.getCompanyAvailability()));
			
				ps.executeUpdate();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		//SELECT - get all package
		public static List<PackageCatering> getAllPackages() throws SQLException {
			List<PackageCatering> packages = new ArrayList<>();

			try{
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
					packageCatering.setCompanyAvailability(rs.getString("companyAvailability").charAt(0));

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
					packageCatering.setCompanyAvailability(rs.getString("companyAvailability").charAt(0));
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
				String query = "UPDATE packageCatering SET packName=?, lowPackPax=?, highPackPax=?, packAvailability=?, companyAvailability=? WHERE packID=?";
				connection = ConnectionManager.getConnection();
				PreparedStatement ps = connection.prepareStatement(query);

				ps.setString(1, packageCatering.getPackName());
				ps.setInt(2, packageCatering.getLowPackPax());
				ps.setInt(3, packageCatering.getHighPackPax());
				ps.setString(4, String.valueOf(packageCatering.getPackAvailability()));
				ps.setString(5, String.valueOf(packageCatering.getCompanyAvailability()));
				ps.setString(6, packageCatering.getPackID());

				ps.executeUpdate();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		//LIST EQUIPMENT
		public static List<EquipmentPackage> getPackageContents(String packID) {
	        List<EquipmentPackage> list = new ArrayList<>();
	        try {
	            String query = "SELECT ep.packID, ep.eqpID, ep.qtyRequired, e.eqpName, " +
	                       "s.serviceSet, p.eqpFunction " +
	                       "FROM equipmentPackage ep " +
	                       "JOIN equipment e ON ep.eqpID = e.eqpID " +
	                       "LEFT JOIN serviceEquipment s ON e.eqpID = s.eqpID " +
	                       "LEFT JOIN supportEquipment p ON e.eqpID = p.eqpID " +
	                       "WHERE ep.packID = ? " +
	                       "ORDER BY ep.eqpID DESC";
	                           
	            connection = ConnectionManager.getConnection();
	            PreparedStatement ps = connection.prepareStatement(query);
	            ps.setString(1, packID);
	            ResultSet rs = ps.executeQuery();

	            while (rs.next()) {
	                EquipmentPackage item = new EquipmentPackage();
	                item.setPackID(rs.getString("packID"));
	                item.setEqpID(rs.getString("eqpID"));
	                item.setQtyRequired(rs.getInt("qtyRequired"));
	                item.setEqpName(rs.getString("eqpName")); // Name from JOIN
	                
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
		
		//Get All Packages AND their Equipment List
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
		public static void updateContentQty(String packID, String eqpID, int newQty) throws SQLException {
		    String query = "UPDATE equipmentPackage SET qtyRequired=? WHERE packID=? AND eqpID=?";
		    
		    try (Connection connection = ConnectionManager.getConnection();
		         PreparedStatement ps = connection.prepareStatement(query)) {
		        
		        ps.setInt(1, newQty);
		        ps.setString(2, packID);
		        ps.setString(3, eqpID);
		        
		        ps.executeUpdate();
		    }
		}
}
