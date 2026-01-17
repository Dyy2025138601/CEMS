package cems;

import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet implementation class staffServlet
 */
@WebServlet("/staffServlet")
public class staffServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public staffServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String action = request.getParameter("action");
	    staffDAO dao = new staffDAO();

	    if ("listCoordinators".equals(action)) {
	        List<staffBean> list = dao.getAllCoordinators();
	        request.setAttribute("coordinatorList", list);
	        request.getRequestDispatcher("ecList.jsp").forward(request, response);
	        
	    } else if ("logout".equals(action)) {
	        request.getSession().invalidate();
	        response.sendRedirect("login.jsp");
	    }
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	
		HttpSession session = request.getSession();
	    String action = request.getParameter("action"); // Add a hidden input in your JSPs for this

	    staffDAO dao = new staffDAO();
	    
	    if ("register".equals(action)) {
	    	//1. Get password and confirmation from the request
	    	String email = request.getParameter("staffEmail");
	        String password = request.getParameter("staffPassword");
	        String confirmPassword = request.getParameter("confirmPassword");

	        // 2. SERVER-SIDE CHECK: Does the email already exist?
	        if (dao.isEmailExists(email)) {
	            session.setAttribute("regError", "This email is already registered. Please login.");
	            response.sendRedirect("register.jsp");
	            return; // Stop execution
	        }

	        // 3. VALIDATION: Maximum length of 6 characters
	        if (password != null && password.length() > 6) {
	            session.setAttribute("regError", "Password must not exceed 6 characters.");
	            response.sendRedirect("register.jsp");
	            return; // Stop further execution
	        }

	        // 4. Validation: Matching Passwords
	        if (password != null && !password.equals(confirmPassword)) {
	            session.setAttribute("regError", "Passwords do not match.");
	            response.sendRedirect("register.jsp");
	            return; // Stop further execution
	        }
	        // --- STEP 1: INITIAL REGISTRATION ---
	        staffBean pendingStaff = new staffBean();
	        pendingStaff.setStaffName(request.getParameter("staffName"));
	        pendingStaff.setStaffEmail(request.getParameter("staffEmail"));
	        pendingStaff.setStaffPhoneNum(request.getParameter("staffPhoneNum"));
	        pendingStaff.setStaffPassword(request.getParameter("staffPassword"));
	        pendingStaff.setStaffRole(request.getParameter("staffRole"));

	        // Generate 4-digit OTP
	        String generatedOtp = String.valueOf((int)(Math.random() * 9000) + 1000);
	        
	        // Save both to session (don't save to DB yet!)
	        session.setAttribute("pendingStaff", pendingStaff);
	        session.setAttribute("generatedOtp", generatedOtp);
	        session.setAttribute("staffEmail", pendingStaff.getStaffEmail());

	        System.out.println("OTP for " + pendingStaff.getStaffEmail() + " is: " + generatedOtp);
	        response.sendRedirect("verify.jsp");

	    } else if ("verify".equals(action)) {
	        // --- STEP 2: OTP VERIFICATION ---
	        String userInputOtp = request.getParameter("otp1") + 
	                             request.getParameter("otp2") + 
	                             request.getParameter("otp3") + 
	                             request.getParameter("otp4");
	        
	        String secretOtp = (String) session.getAttribute("generatedOtp");
	        staffBean staffToSave = (staffBean) session.getAttribute("pendingStaff");

	        if (userInputOtp != null && userInputOtp.equals(secretOtp)) {
	            // Success! Save to Database
	            staffDAO.addStaff(staffToSave);
	            
	            session.invalidate(); // Clear session
	            response.sendRedirect("login.jsp?status=verified");
	        } else {
	            // Fail
	            response.sendRedirect("verify.jsp?error=wrong_otp");
	        }
	    } else if ("login".equals(action)) {
	        String email = request.getParameter("staffEmail");
	        String pass = request.getParameter("staffPassword");
	        String role = request.getParameter("staffRole");

	        staffBean staff = dao.loginStaff(email, pass, role);

	        if (staff != null) {
	            session.setAttribute("staff", staff);
	            if ("MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
	                response.sendRedirect("dashboardManager.jsp");
	            } else {
	                response.sendRedirect("dashboardCoordinator.jsp");
	            }
	        } else {
	            // 1. Set the error message in the session instead of the URL
	            session.setAttribute("loginError", "Invalid email, password, or role.");
	            
	            // 2. Redirect to the clean URL (no ?error=invalid)
	            response.sendRedirect("login.jsp");
	        }
	    }else if ("updateStaffPhoneNum".equals(action)) {
	        staffBean staff = (staffBean) session.getAttribute("staff");

	        if (staff != null) {
	            String newPhone = request.getParameter("staffPhoneNum");

	            if (newPhone != null && !newPhone.isEmpty()) {
	                staff.setStaffPhoneNum(newPhone);
	                staffDAO.updateStaffPhoneNum(staff); 
	            }
	            
	            session.setAttribute("staff", staff);
	            
	            // Role-based redirection
	            if ("MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
	                response.sendRedirect("account.jsp?update=success");
	            } else {
	                response.sendRedirect("accountCoord.jsp?update=success");
	            }
	        }
	    }else if ("updateStaffPassword".equals(action)) {
	        staffBean staff = (staffBean) session.getAttribute("staff");

	        if (staff != null) {
	            String oldPassInput = request.getParameter("oldPass");
	            String newPass = request.getParameter("staffPassword");
	            String confirmPass = request.getParameter("confirmPass");

	            // 1. Check if Old Password matches database (stored in session object)
	            if (!staff.getStaffPassword().equals(oldPassInput)) {
	                response.sendRedirect("accountCoord.jsp?error=wrongOldPass");
	                return;
	            }

	            // 2. Check if New Password is the same as the Old Password
	            if (staff.getStaffPassword().equals(newPass)) {
	                response.sendRedirect("accountCoord.jsp?error=sameAsOld");
	                return;
	            }

	            // 3. Check if New Password matches Confirm Password
	            if (newPass != null && newPass.equals(confirmPass) && !newPass.isEmpty()) {
	                staff.setStaffPassword(newPass); 
	                staffDAO.updateStaffPassword(staff); 
	                
	                session.setAttribute("staff", staff);

	                // Role-based redirection
	                String target = "MANAGER".equalsIgnoreCase(staff.getStaffRole()) ? "account.jsp" : "accountCoord.jsp";
	                response.sendRedirect(target + "?update=success");
	            } else {
	                // Passwords don't match
	                response.sendRedirect("accountCoord.jsp?error=matchFail");
	            }
	        }
	    }
	}

}
