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

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		// response.getWriter().append("Served at: ").append(request.getContextPath());
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

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 * 
	 *      protected void doPost(HttpServletRequest request, HttpServletResponse
	 *      response) throws ServletException, IOException { // TODO Auto-generated
	 *      method stub //doGet(request, response); String packID =
	 *      request.getParameter("packID"); try { if(packID!=null)
	 *      updatePackage(request, response);
	 * 
	 *      } catch (SQLException e) { e.printStackTrace(); } }
	 */

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

			// Case 2: Updating the Package Name/Pax (If you build a separate 'Edit Details'
			// page later)
			case "updateDetails":
				updatePackage(request, response);
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
		List<PackageCatering> packageList = PackageDAO.getAllPackages();
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

		request.setAttribute("packageCatering", packageCatering);
		request.setAttribute("contentList", list);

		RequestDispatcher dispatcher = request.getRequestDispatcher("viewPackageDetails.jsp");
		dispatcher.forward(request, response);
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
	        // Loop through the arrays and update each item
	        for (int i = 0; i < eqpIDs.length; i++) {
	            String eqpID = eqpIDs[i];
	            int qty = Integer.parseInt(quantities[i]);
	            
	            // Update individual row
	            PackageDAO.updateContentQty(packID, eqpID, qty);
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
		char companyAvailability = request.getParameter("companyAvailability").charAt(0);

		PackageCatering packageCatering = new PackageCatering();

		packageCatering.setPackID(packID);
		packageCatering.setPackName(packName);
		packageCatering.setLowPackPax(lowPackPax);
		packageCatering.setHighPackPax(highPackPax);
		packageCatering.setPackAvailability(packAvailability);
		packageCatering.setCompanyAvailability(companyAvailability);

		PackageDAO.updatePackage(packageCatering);

		System.out.println("Package updated successfully.");
		response.sendRedirect("PackageController?action=view&packID=" + packID);

		// response.sendRedirect("PackageController?action=list");
	}

}
