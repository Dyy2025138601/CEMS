package cems;

import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

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
	    HttpSession session = request.getSession();

	    if ("listCoordinators".equals(action)) {
	        List<staffBean> list = dao.getAllCoordinators();
	        request.setAttribute("coordinatorList", list);
	        request.getRequestDispatcher("coordinatorList.jsp").forward(request, response);
	        
	    } else if ("viewCoordinator".equals(action)) { 
	        String id = request.getParameter("staffID");
	        
	        if (id != null && !id.isEmpty()) {
	            // 1. Get the Profile
	            staffBean coordinator = dao.getStaffById(id);
	            
	            // 2. Get Events managed by this Coordinator
	            // (You need to ensure your EventDAO has a method for this)
	            EventDAO eventDao = new EventDAO(); 
	            List<EventBean> eventList = eventDao.getEventsByStaffId(id); 

	            // 3. Get Equipment Issues (Lost/Damaged) for this Coordinator
	            // (Ensure your DAO has a method for this, see SQL below)
	            List<Map<String, Object>> equipmentIssues = eventDao.getIssuesByStaffId(id);

	            // 4. Calculate Totals for the Cards
	            int damageCount = 0;
	            int lostCount = 0;
	            if (equipmentIssues != null) {
	                for (Map<String, Object> issue : equipmentIssues) {
	                    // Safely parse objects to integers
	                    Object dmg = issue.get("qtyDamage");
	                    Object lst = issue.get("qtyLost");
	                    if (dmg instanceof Number) damageCount += ((Number) dmg).intValue();
	                    if (lst instanceof Number) lostCount += ((Number) lst).intValue();
	                }
	            }

	            if (coordinator != null) {
	                request.setAttribute("coordinator", coordinator); // The target staff profile
	                request.setAttribute("eventList", eventList);     // Their events
	                request.setAttribute("equipmentIssues", equipmentIssues); // Their issues
	                request.setAttribute("damageCount", damageCount);
	                request.setAttribute("lostCount", lostCount);

	                request.getRequestDispatcher("viewCoordinatorDetails.jsp").forward(request, response);
	            } else {
	                response.sendRedirect("staffServlet?action=listCoordinators");
	            }
	        } else {
	            response.sendRedirect("staffServlet?action=listCoordinators");
	        }
	    }else if ("logout".equals(action)) {
            // ... (rest of your existing code)
	        request.getSession().invalidate();
	        response.sendRedirect("login.jsp");
	    } else if ("resend".equals(action)) {
            // ... (rest of your existing code)
            // [Keep the rest of your existing blocks here]
        }else if ("resend".equals(action)) {
	        // 1. Check if there is a pending registration
	        staffBean pendingStaff = (staffBean) session.getAttribute("pendingStaff");
	        
	        if (pendingStaff != null) {
	            // 2. Generate a new 4-digit OTP
	            String newOtp = String.valueOf((int)(Math.random() * 9000) + 1000);
	            
	            // 3. Update the session with the new OTP
	            session.setAttribute("generatedOtp", newOtp);
	            
	            // 4. (Optional) Log it to console for testing
	            System.out.println("NEW Resent OTP for " + pendingStaff.getStaffEmail() + " is: " + newOtp);
	            
	            // 5. Redirect back with a success message
	            response.sendRedirect("verify.jsp?status=resent");
	        } else {
	            // If session expired or no pending staff, send back to register
	            response.sendRedirect("register.jsp?error=expired");
	        }
	    }else if ("resendResetOtp".equals(action)) {
	        String email = (String) session.getAttribute("resetEmail");

	        if (email != null) {
	            // 1. Generate a new 4-digit OTP
	            String newOtp = String.valueOf((int)(Math.random() * 9000) + 1000);
	            
	            // 2. Update the session with the new OTP
	            session.setAttribute("resetOtp", newOtp);
	            
	            // 3. Log it for testing (In production, you'd trigger an email here)
	            System.out.println("NEW Reset OTP for " + email + " is: " + newOtp);
	            
	            // 4. Redirect back to Step 2 with a success status
	            response.sendRedirect("forgotPass.jsp?step=2&status=resent");
	        } else {
	            // If session expired, send them back to start
	            response.sendRedirect("forgotPass.jsp?step=1&error=expired");
	        }
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
	        // 1. Get input from the request
	        String email = request.getParameter("staffEmail");
	        String password = request.getParameter("staffPassword");
	        String confirmPassword = request.getParameter("confirmPassword");

	        // 2. SERVER-SIDE CHECK: Does the email already exist?
	        if (dao.isEmailExists(email)) {
	            session.setAttribute("regError", "This email is already registered. Please login.");
	            response.sendRedirect("register.jsp");
	            return; 
	        }

	        // 3. VALIDATION: Password Length
	        // FIX: Changed condition to match your error message (Max 6)
	        if (password != null && password.length() > 8) {
	            session.setAttribute("regError", "Password must not exceed 8 characters.");
	            response.sendRedirect("register.jsp");
	            return; 
	        }

	        // 4. Validation: Matching Passwords
	        if (password != null && !password.equals(confirmPassword)) {
	            session.setAttribute("regError", "Passwords do not match.");
	            response.sendRedirect("register.jsp");
	            return; 
	        }

	        // --- STEP 5 (NEW): AUTO-GENERATE STAFF ID ---
	        // Default ID if the database is empty
	        String newStaffId = "S001"; 
	        
	        // Call the new DAO method we created
	        String lastId = dao.getLastStaffId(); 

	        if (lastId != null) {
	            try {
	                // 1. Extract the number part (remove the 'S' at index 0)
	                // e.g., "S005" becomes 5
	                int idNum = Integer.parseInt(lastId.substring(1));
	                
	                // 2. Increment the number
	                idNum++;
	                
	                // 3. Format back to String with padding (e.g., 6 becomes "S006")
	                newStaffId = String.format("S%03d", idNum);
	            } catch (NumberFormatException e) {
	                // Fallback in case existing IDs in DB are not in "S000" format
	                System.out.println("Error parsing ID: " + lastId);
	            }
	        }

	        // --- STEP 6: INITIAL REGISTRATION BEAN ---
	        staffBean pendingStaff = new staffBean();
	        
	        // IMPORTANT: Set the auto-generated ID here
	        pendingStaff.setStaffID(newStaffId);
	        
	        pendingStaff.setStaffName(request.getParameter("staffName"));
	        pendingStaff.setStaffEmail(request.getParameter("staffEmail"));
	        pendingStaff.setStaffPhoneNum(request.getParameter("staffPhoneNum"));
	        pendingStaff.setStaffPassword(request.getParameter("staffPassword"));
	        pendingStaff.setStaffRole("COORDINATOR");

	        // Generate 4-digit OTP
	        String generatedOtp = String.valueOf((int)(Math.random() * 9000) + 1000);
	        
	        // Save to session (DB insertion happens only after OTP verification)
	        session.setAttribute("pendingStaff", pendingStaff);
	        session.setAttribute("generatedOtp", generatedOtp);
	        session.setAttribute("staffEmail", pendingStaff.getStaffEmail());

	        // Debugging print
	        System.out.println("New ID Generated: " + newStaffId);
	        System.out.println("OTP for " + pendingStaff.getStaffEmail() + " is: " + generatedOtp);
	        
	        response.sendRedirect("verify.jsp");
	    } else if ("verify".equals(action)) {
	        // --- STEP 2: OTP VERIFICATION --- (register)
	        String otp1 = request.getParameter("otp1");
	        String otp2 = request.getParameter("otp2");
	        String otp3 = request.getParameter("otp3");
	        String otp4 = request.getParameter("otp4");

	        // Concatenate OTP inputs
	        String userInputOtp = (otp1 != null ? otp1 : "") + 
	                             (otp2 != null ? otp2 : "") + 
	                             (otp3 != null ? otp3 : "") + 
	                             (otp4 != null ? otp4 : "");
	        
	        String secretOtp = (String) session.getAttribute("generatedOtp");
	        Long expiryTime = (Long) session.getAttribute("otpExpiry"); // Assuming you store this when sending mail
	        staffBean staffToSave = (staffBean) session.getAttribute("pendingStaff");

	        if (userInputOtp.length() < 4) {
	            session.setAttribute("otpError", "Please enter the full 4-digit code.");
	            response.sendRedirect("verify.jsp");
	        } else if (secretOtp != null && userInputOtp.equals(secretOtp)) {
	            // Optional: Check Expiry (if you have implemented it)
	            if (expiryTime != null && System.currentTimeMillis() > expiryTime) {
	                session.setAttribute("otpError", "OTP has expired. Please click Resend.");
	                response.sendRedirect("verify.jsp");
	            } else {
	                // 1. CALL DAO (Now returns boolean, NOT int)
	                boolean isSuccess = dao.addStaff(staffToSave);

	                // 2. CHECK STATUS
	                if (isSuccess) {
	                    // 3. GET ID FROM BEAN (Because we generated it in the "register" step)
	                    String newStaffId = staffToSave.getStaffID();

	                    System.out.println("New Staff Registered with ID: " + newStaffId);
	                    
	                    // Update session with the correct ID (String)
	                    session.setAttribute("loggedInUserId", newStaffId);
	                    session.setAttribute("showSuccess", true);
	                    
	                    // CLEANUP session
	                    session.removeAttribute("pendingStaff");
	                    session.removeAttribute("generatedOtp");
	                    session.removeAttribute("otpExpiry");

	                    response.sendRedirect("verify.jsp");
	                } else {
	                    // Database insertion failed
	                    session.setAttribute("otpError", "Database error. Registration failed.");
	                    response.sendRedirect("verify.jsp");
	                }
	            }
	        } else {
	            // Fail: Set error message in session
	            session.setAttribute("otpError", "Invalid OTP. Please check your email and try again.");
	            response.sendRedirect("verify.jsp");
	        }
	    } else if ("login".equals(action)) {
	        String email = request.getParameter("staffEmail");
	        String pass = request.getParameter("staffPassword");
	        String role = request.getParameter("staffRole");

	        staffBean staff = dao.loginStaff(email, pass, role);

	        if (staff != null) {
	            session.setAttribute("staff", staff);
	            if ("MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
	                response.sendRedirect("EventController?action=dashboard");
	            } else {
	                response.sendRedirect("EventController?action=dashboardCoordinator");
	            }
	        } else {
	            // 1. Set the error message in the session instead of the URL
	            session.setAttribute("loginError", "Invalid email, password, or role.");
	            
	            // 2. Redirect to the clean URL (no ?error=invalid)
	            response.sendRedirect("login.jsp");
	        }
	    }else if ("forgotPass".equals(action)) {
	        String step = request.getParameter("step");

	        if ("1".equals(step)) {
	            String email = request.getParameter("email");
	            if (dao.isEmailExists(email)) {
	                String otp = String.valueOf((int)(Math.random() * 9000) + 1000);
	                session.setAttribute("resetEmail", email);
	                session.setAttribute("resetOtp", otp);
	                System.out.println("Reset OTP for " + email + " is: " + otp);
	                response.sendRedirect("forgotPass.jsp?step=2");
	            } else {
	            	session.setAttribute("otpErrorFP", "Email not found.");
	                response.sendRedirect("forgotPass.jsp?step=1");
	            }
	        } 
	        else if ("2".equals(step)) {
	            // Combine the 4 boxes into one string
	            String userOtp = request.getParameter("otp1") + 
	                             request.getParameter("otp2") + 
	                             request.getParameter("otp3") + 
	                             request.getParameter("otp4");
	                             
	            String secretOtp = (String) session.getAttribute("resetOtp");
	            Long expiryTime = (Long) session.getAttribute("otpExpiry");
	            
	            if (userOtp.length() < 4) {
		            session.setAttribute("otpErrorFP", "Please enter the full 4-digit code.");
		            response.sendRedirect("forgotPass.jsp?step=2&error=notfound");
		        } else if (secretOtp != null && userOtp.equals(secretOtp)) {
		            // Optional: Check Expiry (if you have implemented it)
		            if (expiryTime != null && System.currentTimeMillis() > expiryTime) {
		                session.setAttribute("otpErrorFP", "OTP has expired.");
		                response.sendRedirect("forgotPass.jsp?step=2");
		            } else {
		                response.sendRedirect("forgotPass.jsp?step=3");
		            }
		        } else {
		            // Fail: Set error message in session
		            session.setAttribute("otpErrorFP", "Invalid OTP.");
		            response.sendRedirect("forgotPass.jsp?step=2");
		        }
	        }
	        else if ("3".equals(step)) {
	            String newPass = request.getParameter("newPass");
	            String confirmPass = request.getParameter("confirmPass");
	            String email = (String) session.getAttribute("resetEmail");

	            if (newPass != null && newPass.equals(confirmPass) && newPass.length() == 8) {
	                staffBean staff = new staffBean();
	                staff.setStaffEmail(email);
	                // CRITICAL: Encrypt the password before sending to DAO
	                staff.setStaffPassword(EncryptionUtil.encrypt(newPass)); 
	                
	                dao.updateStaffPasswordByEmail(staff); 
	                
	                session.removeAttribute("resetEmail");
	                session.removeAttribute("resetOtp");
	                session.setAttribute("resetSuccess", true);
	                response.sendRedirect("forgotPass.jsp?step=3");
	            } else {
	            	session.setAttribute("otpErrorFP", "Passwords must match and be 8 characters.");
	                response.sendRedirect("forgotPass.jsp?step=3");
	            }
	        }
	    } else if ("updateStaffPhoneNum".equals(action)) {
	        staffBean currentStaff = (staffBean) session.getAttribute("staff");

	        if (currentStaff != null) {
	            String newPhone = request.getParameter("staffPhoneNum");
	            String currentId = currentStaff.getStaffID();
	            String role = currentStaff.getStaffRole();
	            String redirectPage = "Manager".equalsIgnoreCase(role) ? "accountManager.jsp" : "accountCoord.jsp";

	            if (dao.isPhoneExists(newPhone, currentId)) {
	                session.setAttribute("phoneError", "This phone number is already registered.");
	                response.sendRedirect(redirectPage);
	                return; 
	            }

	            if (newPhone != null && !newPhone.isEmpty()) {
	                currentStaff.setStaffPhoneNum(newPhone);
	                boolean success = dao.updateStaffPhoneNum(currentStaff); 
	                
	                if (success) {
	                    session.setAttribute("staff", currentStaff); 
	                    session.setAttribute("accountUpdateSuccess", "phone");
	                    // ADDED REDIRECT HERE
	                    response.sendRedirect(redirectPage);
	                } else {
	                    session.setAttribute("phoneError", "Database error. Please try again.");
	                    response.sendRedirect(redirectPage);
	                }
	            }
	        }
	    } else if ("updateStaffPassword".equals(action)) {
	        staffBean currentStaff = (staffBean) session.getAttribute("staff");

	        if (currentStaff != null) {
	            String oldPassInput = request.getParameter("oldPass");
	            String newPass = request.getParameter("staffPassword");
	            String confirmPass = request.getParameter("confirmPass");
	            
	            String role = currentStaff.getStaffRole();
	            String redirectPage = "Manager".equalsIgnoreCase(role) ? "accountManager.jsp" : "accountCoord.jsp";

	            if (!currentStaff.getStaffPassword().equals(oldPassInput)) {
	                session.setAttribute("passError", "The old password you entered is incorrect.");
	                response.sendRedirect(redirectPage);
	                return;
	            }

	            if (currentStaff.getStaffPassword().equals(newPass)) {
	                session.setAttribute("passError", "New password cannot be the same as the old password.");
	                response.sendRedirect(redirectPage);
	                return;
	            }

	            if (newPass == null || !newPass.equals(confirmPass)) {
	                session.setAttribute("passError", "New password and confirmation do not match.");
	                response.sendRedirect(redirectPage);
	                return;
	            }

	            if (newPass.length() != 8) {
	                session.setAttribute("passError", "Password must be exactly 8 characters.");
	                response.sendRedirect(redirectPage);
	                return;
	            }

	            currentStaff.setStaffPassword(newPass); 
	            staffBean updateBean = new staffBean();
	            updateBean.setStaffID(currentStaff.getStaffID());
	            updateBean.setStaffPassword(EncryptionUtil.encrypt(newPass));
	            
	            if (dao.updateStaffPassword(updateBean)) {
	                session.setAttribute("staff", currentStaff);
	                session.setAttribute("accountUpdateSuccess", "password");
	                // ADDED REDIRECT HERE
	                response.sendRedirect(redirectPage);
	            } else {
	                session.setAttribute("passError", "Database error occurred.");
	                response.sendRedirect(redirectPage);
	            }
	        }
	    }
	}
	

}
