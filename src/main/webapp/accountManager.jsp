<%@ page import="cems.staffBean"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
staffBean staff = (staffBean) session.getAttribute("staff");

// Check if logged in AND if the role is correct
if (staff == null || !"MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
	// If they aren't a manager, force them out
	session.invalidate();
	response.sendRedirect("login.jsp?error=unauthorized");
	return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager - Account</title>
<link rel="stylesheet" href="style.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
</style>
<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
	<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
</head>
<body>
	<div class="layout">
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>
			<nav class="nav-menu">
				<a href="EventController?action=dashboard" class="nav-item"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>
					
				</a> <a href="EquipmentController?action=list" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
					
				</a> <a href="EventController?action=list" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
					
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
					
				</a> <a href="staffServlet?action=listCoordinators" class="nav-item"> <img
					src="icon/coordinator.png" class="nav-icon"> <span
					class="link-text">Coordinator</span>
				</a> <a href="generateReport.jsp" class="nav-item"> <img
					src="icon/report.png" class="nav-icon"> <span
					class="link-text">Report</span>
				</a>
			</nav>

			<div class="logout-section">
				<a href="javascript:void(0)" onclick="showLogoutModal()"
					class="nav-icon-logout"> <img src="icon/logout.png"> <span
					class="link-text">Log Out</span>
				</a>
			</div>
		</div>

		<div class="header">
			<h2 class="welcome-text">Account Settings</h2>
			<div class="user-profile">
				<div class="user-info">
					<span class="user-name"><%=staff.getStaffName()%></span> <span
						class="user-role"><%=staff.getStaffRole()%></span>
				</div>
				<a href="accountManager.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png"
						alt="profile_image">
				</span>
				</a>
			</div>
		</div>

		<main class="main">
			<div class="profile-box">
				<div class="profile-card">
				<button class="back-btn"
						onclick="window.location.href='EventController?action=dashboard'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
					<div id="view-profile" class="view">
						<header class="profile-header">
							<div class="avatar-wrapper">
								<img src="icon/user.png" alt="Profile">
							</div>
							<div class="header-text">
								<h2><%=staff.getStaffName()%></h2>
								<p><%=staff.getStaffRole()%></p>
							</div>
						</header>
						<div class="settings-grid">
							<div class="field-row">
								<div class="field-info">
									<label>Email Address</label><span class="value"><%=staff.getStaffEmail()%></span>
								</div>
							</div>
							<hr class="divider">
							<div class="field-row">
								<div class="field-info">
									<label>Phone Number</label><span class="value"><%=staff.getStaffPhoneNum()%></span>
								</div>
								<button class="text-edit-btn" onclick="showView('view-phone')">Update</button>
							</div>
							<hr class="divider">
							<div class="field-row">
								<div class="field-info">
									<label>Password</label>
									<div class="password-wrapper">
										<span class="value" id="passwordValue">•••••••• <i
											class="fa-solid fa-eye" id="togglePassword"
											onclick="togglePasswordVisibility('<%=staff.getStaffPassword()%>')"
											style="cursor: pointer; margin-left: 10px; color: #666;"></i></span>
									</div>
								</div>
								<button class="text-edit-btn"
									onclick="showView('view-password')">Update</button>
							</div>
						</div>
					</div>
					<div id="view-phone" class="view" style="display: none;">
						<h2 class="view-title">Update Phone</h2>
						<%
						String phoneError = (String) session.getAttribute("phoneError");
						if (phoneError != null) {
						%>
						<div class="error-container">
							<i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
							<span class="error-text"
								style="color: #b80000; font-weight: 600;"><%=phoneError%></span>
						</div>
						<script>document.addEventListener("DOMContentLoaded", function() { showView('view-phone'); });</script>
						<%
						session.removeAttribute("phoneError");
						}
						%>
						<form class="static-form" action="staffServlet" method="post">
							<input type="hidden" name="action" value="updateStaffPhoneNum">
							<div class="input-block">
								<label>New Phone Number</label> <input type="number"
									name="staffPhoneNum" id="phone" placeholder="Phone Number"
									class="minimal-input"
									oninput="if(this.value.length > 12) this.value = this.value.slice(0, 12);"
									required>
								<button type="submit" class="update-btn">Update</button>
							</div>
						</form>
					</div>

					<div id="view-password" class="view" style="display: none;">
						<h2 class="view-title">Change Password</h2>
						<%
						String passError = (String) session.getAttribute("passError");
						if (passError != null) {
						%>
						<div class="error-container">
							<i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
							<span class="error-text"
								style="color: #b80000; font-weight: 600;"><%=passError%></span>
						</div>
						<script>document.addEventListener("DOMContentLoaded", function() { showView('view-password'); });</script>
						<%
						session.removeAttribute("passError");
						}
						%>
						<form class="static-form" action="staffServlet" method="post">
							<input type="hidden" name="action" value="updateStaffPassword">

							<div class="input-block">
								<label>Old Password</label> <input type="password"
									id="input-old-pass" name="oldPass" class="minimal-input"
									maxlength="8" required>
							</div>
							<div class="input-block">
								<label>New Password</label> <input type="password"
									id="input-new-pass" name="staffPassword" class="minimal-input"
									maxlength="8" required>
							</div>
							<div class="input-block">
								<label>Confirm Password</label> <input type="password"
									id="input-confirm-pass" name="confirmPass"
									class="minimal-input" maxlength="8" required>
								<button type="submit" class="btn-update">Update</button>
							</div>
						</form>
					</div>

					<div id="confirmModal" class="modal-overlay" style="display: none;">
						<div class="modal-content confirm-modal">
							<p id="confirmMessage">You have unsaved changes. Are you sure
								you want to cancel?</p>
							<div class="modal-footer-confirm">
								<button type="button" class="modal-cancel-btn"
									onclick="closeConfirm(false)">No</button>
								<button type="button" class="modal-ok-btn"
									onclick="closeConfirm(true)">Yes, Discard</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</main>
	</div>
	<div id="successModal" class="custom-modal">
		<div class="modal-content">
			<div class="modal-icon-check-circle">
				<i class="fas fa-check"></i>
			</div>
			<div class="modal-title-orange">Updated!</div>
			<div id="successModalMessage" class="modal-message-white">Details
				Successfully Updated.</div>
			<button class="btn-orange-glow" onclick="closeAccountModal()">Go
				to Profile</button>
		</div>
	</div>
<div id="logoutModal" class="modal-overlay" style="display: none;">
		<div class="modal-content">
			
			<h3>Confirmation</h3>
			<p class="modal-text" style="color: white; margin-bottom: 30px;">Are
				you sure to log out?</p>
			<div class="modal-buttons"
				style="display: flex; justify-content: center; gap: 15px;">
				<button class="btn-cancel" onclick="closeLogoutModal()"
					style="padding: 10px 30px; border-radius: 50px; border: none; font-weight: 600; cursor: pointer;">
					Cancel</button>
				<a href="staffServlet?action=logout" style="text-decoration: none;">
					<button class="btn-logout"
						style="background: linear-gradient(to right, #ff8c00, #ff4500); color: white; padding: 10px 30px; border-radius: 50px; border: none; font-weight: 600; cursor: pointer;">
						Log Out</button>
				</a>
			</div>
		</div>
	</div>
	<script>
    function toggleSidebar() {
        document.getElementById("sidebar").classList.toggle("collapsed");
        document.querySelector(".layout").classList.toggle("collapsed");
    }
    
    let currentViewId = 'view-profile';

    function showView(viewId) {
        // Hide all views
        document.querySelectorAll('.view').forEach(v => v.style.display = 'none');
        // Show target view
        document.getElementById(viewId).style.display = 'block';
        currentViewId = viewId;
    }

	function closeAccountModal() {
        document.getElementById('successModal').style.display = 'none';
        showView('view-profile'); // Return to profile view
    }

    window.onload = function() {
        <%String updateType = (String) session.getAttribute("accountUpdateSuccess");
if (updateType != null) {
	session.removeAttribute("accountUpdateSuccess");%>
            const modal = document.getElementById('successModal');
            const msg = document.getElementById('successModalMessage');
            
            <%if ("phone".equals(updateType)) {%>
                msg.innerText = "Phone Number Successfully Updated.";
            <%} else if ("password".equals(updateType)) {%>
                msg.innerText = "Password Successfully Updated.";
            <%}%>
            
            modal.style.display = 'flex';
        <%}%>
    };

    function handleBack() {
        // FIX: Wrapped selector in backticks
         const errorSpan = document.getElementById('phone-error');
        const inputs = document.querySelectorAll(`#\${currentViewId} input`);
        let hasContent = false;

        inputs.forEach(input => {
            if (input.value.trim().length > 0) hasContent = true;
        });

        if (hasContent) {
            const confirmCancel = confirm("You have unsaved changes. Are you sure you want to cancel?");
            if (!confirmCancel) return; 
        }

        if (errorSpan) {
            errorSpan.style.display = 'none';
        }
        // Clear inputs and go back
        inputs.forEach(input => input.value = "");
        showView('view-profile');
        
    }

    function showSuccessState() {
        // Clear any input data before moving to success
        const inputs = document.querySelectorAll(`#\${currentViewId} input`);
        inputs.forEach(input => input.value = "");
        showView('view-success');
    }

	    let isPasswordVisible = false;
	
	    function togglePasswordVisibility(realPassword) {
	        const passwordSpan = document.getElementById("passwordValue");
	        const icon = document.getElementById("togglePassword");
	
	     // 1. Ensure the base class is ALWAYS there
	        icon.classList.add("fa-solid");

	        if (!isPasswordVisible) {
	            passwordSpan.innerText = realPassword;
	            // 2. Remove old, add new
	            icon.classList.remove("fa-eye");
	            icon.classList.add("fa-eye-slash");
	        } else {
	            passwordSpan.innerText = "••••••••";
	            // 2. Remove old, add new
	            icon.classList.remove("fa-eye-slash");
	            icon.classList.add("fa-eye");
	        }
	        isPasswordVisible = !isPasswordVisible;
	    }
	    function showLogoutModal() {
		    document.getElementById("logoutModal").style.display = "flex";
		}

		function closeLogoutModal() {
		    document.getElementById("logoutModal").style.display = "none";
		}
    </script>
</body>
</html>