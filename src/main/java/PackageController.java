package cems;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet implementation class PackageController
 */
@WebServlet("/PackageController")
public class PackageController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public PackageController() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String action = request.getParameter("action");

		try {
			switch (action) {
			case "list":
				listPackage(request, response);
				break;
			case "view":
				viewPackage(request, response);
				break;
			case "edit":
				showEditForm(request, response);
				break;
			case "updateQty":
				updateContentQty(request, response);
				break;
			default:
				listPackage(request, response);
				break;
			}
		} catch (SQLException ex) {
			throw new ServletException(ex);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String action = request.getParameter("action");

		// Safety check: if action is null, check if it's the old update form or just
		// redirect
		if (action == null) {
			response.sendRedirect("PackageController?action=list");
			return;
		}

		try {
			switch (action) {
			// Case 1: Updating the Quantities in the Table (The form you just built)
			case "updateQty":
				updateContentQty(request, response);
				break;
			case "updateDetails":
				updatePackage(request, response);
				break;
			case "addContent":
	            addPackageContent(request, response);
	            break;
			default:
				listPackage(request, response);
				break;
			}
		} catch (SQLException ex) {
			throw new ServletException(ex);
		}
	}

	// 1. list package
	private void listPackage(HttpServletRequest request, HttpServletResponse response)
	        throws SQLException, ServletException, IOException {
	    
	    String dateFilter = request.getParameter("filterDate");
	    List<PackageCatering> packageList;

	    if (dateFilter != null && !dateFilter.isEmpty()) {
	        // If user selected a date, use the smart logic
	        packageList = PackageDAO.getPackagesByDateAvailability(dateFilter);
	        request.setAttribute("selectedDate", dateFilter); // Send back to keep input filled
	    } else {
	        // Default: Show general list (Availability based on generic status)
	        packageList = PackageDAO.getAllPackages();
	        // Manually set 'Available' text for display consistency if needed
	        for(PackageCatering p : packageList) {
	             p.setAvailabilityOnDate(p.getPackAvailability() == 'Y' ? "Available" : "Unavailable");
	        }
	    }

	    request.setAttribute("packages", packageList);
	    RequestDispatcher dispatcher = request.getRequestDispatcher("viewPackageList.jsp");
	    dispatcher.forward(request, response);
	}

	// Package Details
	private void viewPackage(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, ServletException, IOException {

		String packID = request.getParameter("packID");

		PackageCatering packageCatering = PackageDAO.getPackageById(packID);

		// list equipment
		List<EquipmentPackage> list = PackageDAO.getPackageContents(packID);
		
		//list equipment that can be added
		List<EquipmentPackage> availableList = PackageDAO.getAvailableEquipmentForPackage(packID);

		request.setAttribute("packageCatering", packageCatering);
		request.setAttribute("contentList", list);
		
		request.setAttribute("availableEquipmentList", availableList);

		RequestDispatcher dispatcher = request.getRequestDispatcher("viewPackageDetails.jsp");
		dispatcher.forward(request, response);
	}
	
	//add new equipment
	private void addPackageContent(HttpServletRequest request, HttpServletResponse response) 
	        throws SQLException, IOException {

	    String packID = request.getParameter("packID"); 
	    String eqpID = request.getParameter("eqpID");
	    
	    int qty = 0;
	    try {
	        qty = Integer.parseInt(request.getParameter("qtyRequired"));
	    } catch (NumberFormatException e) {
	        qty = 1; 
	    }
	    
	    // --- CHANGE THIS LINE ---
	    String checkBoxVal = request.getParameter("isPaxDepend");
	    // Change (checkBoxVal != null) to the comparison below:
	    char is_paxDepend = "true".equalsIgnoreCase(checkBoxVal) ? 'Y' : 'N';
	    // ------------------------

	    PackageDAO.addPackageContent(packID, eqpID, qty, is_paxDepend);

	    response.sendRedirect("PackageController?action=view&packID=" + packID);
	}

	// 2. SHOW edit form
	private void showEditForm(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, ServletException, IOException {

		String packID = request.getParameter("packID");
		PackageCatering existingPackage = PackageDAO.getPackageById(packID);
		PackageCatering packageCatering = PackageDAO.getPackageById(packID);

		List<EquipmentPackage> list = PackageDAO.getPackageContents(packID);

		request.setAttribute("packageCatering", packageCatering);
		request.setAttribute("contentList", list);

		request.setAttribute("package", existingPackage);
		RequestDispatcher dispatcher = request.getRequestDispatcher("updatePackage.jsp");
		dispatcher.forward(request, response);
	}

	// 3. Update Quantity Logic
	private void updateContentQty(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
	    String packID = request.getParameter("packID");
	    
	    // Get Arrays of IDs and Quantities (String[] because there are multiple rows)
	    String[] eqpIDs = request.getParameterValues("eqpID");
	    String[] quantities = request.getParameterValues("qtyRequired");
	    if (eqpIDs != null && quantities != null) {
            for (int i = 0; i < eqpIDs.length; i++) {
                String eqpID = eqpIDs[i];
                int qty = Integer.parseInt(quantities[i]);
                
                String paramName = "is_paxDepend_" + eqpID; 
                String val = request.getParameter(paramName);
                char is_paxDepend = (val != null) ? 'Y' : 'N';
                
                // Call DAO
                PackageDAO.updateContentQty(packID, eqpID, qty, is_paxDepend);
            }
        }

	    // Redirect with success flag so the Modal opens
	    response.sendRedirect("PackageController?action=view&packID=" + packID + "&success=true");
	}

	// 3. UPDATE
	private void updatePackage(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, IOException {
		String packID = request.getParameter("packID");
		String packName = request.getParameter("packName");
		int lowPackPax = Integer.parseInt(request.getParameter("lowPackPax"));
		int highPackPax = Integer.parseInt(request.getParameter("highPackPax"));
		char packAvailability = request.getParameter("packAvailability").charAt(0);

		PackageCatering packageCatering = new PackageCatering();

		packageCatering.setPackID(packID);
		packageCatering.setPackName(packName);
		packageCatering.setLowPackPax(lowPackPax);
		packageCatering.setHighPackPax(highPackPax);
		packageCatering.setPackAvailability(packAvailability);

		PackageDAO.updatePackage(packageCatering);

		System.out.println("Package updated successfully.");
		response.sendRedirect("PackageController?action=view&packID=" + packID);

		// response.sendRedirect("PackageController?action=list");
	}

}
