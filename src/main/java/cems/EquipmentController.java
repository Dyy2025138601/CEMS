package cems;

import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.util.List;

@WebServlet("/EquipmentController")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 15    // 15MB
)
public class EquipmentController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public EquipmentController() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	String action = request.getParameter("action");
        // Retrieve the ID here so both if-statements can access it
        String id = request.getParameter("id"); 
        
        EquipmentDAO dao = new EquipmentDAO();

        if ("list".equals(action) || action == null) {
            List<Equipment> eqpList = dao.getAllEquipment();
            request.setAttribute("eqpList", eqpList);
            request.getRequestDispatcher("equipmentList.jsp").forward(request, response);
        }
        // Use else if to avoid running multiple checks once a match is found
        else if ("view".equals(action)) {
            // Now 'id' is defined and won't cause an error
            Equipment eqp = dao.getEquipmentById(id);
            request.setAttribute("equipment", eqp);
            request.getRequestDispatcher("viewEquipmentDetail.jsp").forward(request, response);
        }else if ("edit".equals(action)) {
        	    Equipment eqp = dao.getEquipmentById(id); // Use the method we created earlier
        	    request.setAttribute("equipment", eqp);
        	    request.getRequestDispatcher("updateEquipment.jsp").forward(request, response);
        	}
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
    	
    	HttpSession session = request.getSession();
        String action = request.getParameter("action");
        if ("insert".equals(action)) {
            try {
                // 1. Collect Form Data
                String name = request.getParameter("eqpName");
                int qty = Integer.parseInt(request.getParameter("eqpQty"));
                String type = request.getParameter("equipmentType");
                
                // Get Staff info from session
                staffBean staff = (staffBean) session.getAttribute("staff");
                String staffID = (staff != null) ? staff.getStaffID() : "Unknown";

                // 2. Handle Image Upload
                Part filePart = request.getPart("equipmentImage");
                String fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
                
                // Save image to 'uploads' folder in the webapp directory
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                
                filePart.write(uploadPath + File.separator + fileName);
                String dbImagePath = "uploads/" + fileName;

                System.out.println("Equipment Type: " + type);
                System.out.println("Service Value: " + request.getParameter("service"));
                System.out.println("Support Value: " + request.getParameter("support"));
                
                Equipment eqp;

                if ("service".equalsIgnoreCase(type)) {
                    ServiceEquipment s = new ServiceEquipment();
                    String serviceVal = request.getParameter("service"); 
                    s.setServiceSet(serviceVal); 
                    eqp = s;
                } else {
                    SupportEquipment su = new SupportEquipment();
                    String supportVal = request.getParameter("support");
                    su.setEqpFunction(supportVal);
                    eqp = su;
                }

                // Set common attributes
                eqp.setEqpName(name);
                eqp.setEqpQty(qty);
                eqp.setEqpImage(dbImagePath);
                eqp.setStaffID(staffID);

                // 4. Call DAO to save
                if (EquipmentDAO.addEquipment(eqp)) {
                    // Jangan guna sendRedirect!
                    response.setStatus(HttpServletResponse.SC_OK); 
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("createEquipment.jsp?error=exception");
            }
        } else if ("update".equals(action)) {
            try {
                // 1. Ambil data dari form updateEquipment.jsp
                String id = request.getParameter("eqpID"); 
                String qtyStr = request.getParameter("eqpQty");

                if (id != null && qtyStr != null) {
                    int qty = Integer.parseInt(qtyStr);

                    // 2. Panggil DAO yang KHAS untuk update Qty sahaja (Macam controller lama hang)
                    if (EquipmentDAO.updateEquipmentQty(id, qty)) {
                        // Berjaya: Hantar status 200 supaya Modal Success oren keluar
                        response.setStatus(HttpServletResponse.SC_OK);
                        System.out.println("DEBUG: Update Qty Berjaya untuk ID: " + id);
                    } else {
                        // Gagal di peringkat database
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }
}