<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Reset Password</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>
<div class="login-page">
    <div class="login-card">
        <div class="login-left">
            <div class="logo-wrapper">
                <div class="logo-circle"><img src="icon/logo.png" alt="Logo"></div>
            </div>
            <h1 class="system-title">Catering Equipment<br>Management System</h1>
        </div>
        <div class="login-right">
        <div class="detail-header-stack">
                    <button class="back-link" onclick="handleBack()">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                </div>
            <h2 class="login-title">Reset Password</h2>
            
            <% 
                String otpErrorFP = (String) session.getAttribute("otpErrorFP");
                if (otpErrorFP != null) { 
            %>
                <div class="error-container">
                    <i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
                    <span class="error-text"><%= otpErrorFP %></span>
                </div>
            <% session.removeAttribute("otpErrorFP"); } %>
            
            <% String step = (request.getParameter("step") == null) ? "1" : request.getParameter("step"); %>

            <form action="staffServlet" method="post" class="form-register">
			    <input type="hidden" name="action" value="forgotPass">
			    <input type="hidden" name="step" value="<%= step %>">
			
			    <% if(step.equals("1")) { %>
			        <p class="register-text" style="margin-bottom:15px;">Enter email to receive OTP</p>
			        <input type="email" name="email" placeholder="Registered Email" class="forget-input" required>
			    <% } else if(step.equals("2")) { %>
			        <p class="register-text" style="margin-bottom:15px;">Enter 4-digit OTP</p>
			        <div class="email-otp-container">
			            <input type="text" name="otp1" maxlength="1" class="email-otp-box" oninput="moveNext(this, 'otp2')" id="otp1" required>
			            <input type="text" name="otp2" maxlength="1" class="email-otp-box" oninput="moveNext(this, 'otp3')" id="otp2" required>
			            <input type="text" name="otp3" maxlength="1" class="email-otp-box" oninput="moveNext(this, 'otp4')" id="otp3" required>
			            <input type="text" name="otp4" maxlength="1" class="email-otp-box" id="otp4" required>
			        </div>
			        <a href="staffServlet?action=resendResetOtp" class="resend-link">Resend Code</a>
			    <% } else if(step.equals("3")) { %>
			        <input type="password" name="newPass" placeholder="New Password" class="forget-input" maxlength="8" required>
			        <input type="password" name="confirmPass" placeholder="Confirm Password" class="forget-input" maxlength="8" required>
			    <% } %>
			
			    <div class="form-actions">
			        <button type="submit" class="next-btn">
			            <%= step.equals("3") ? "Update" : "Next" %>
			        </button>
			    </div>
			</form>
        </div>
    </div>
</div>
<div class="modal-overlay" id="successModal" style="display: none;">
    <div class="update-modal-dark">
        <div class="modal-content-area">
            <div class="modal-icon-check-circle">
                <i class="fas fa-check"></i>
            </div>
            <h2 class="modal-title-orange">Reset!</h2>
            <p class="modal-message-white">Password Successfully Reset.</p>

            <button class="btn-orange-glow" onclick="goToLogin()">
                Proceed to Login
            </button>
        </div>
    </div>
</div>
<script>
    function moveNext(current, nextId) {
        if (current.value.length >= 1) {
            document.getElementById(nextId).focus();
        }
    }
    
    function goToLogin() {
        window.location.href = "login.jsp";
    }
    
    window.onload = function() {
        <% 
            Boolean resetSuccess = (Boolean) session.getAttribute("resetSuccess");
            if (resetSuccess != null && resetSuccess) {
                session.removeAttribute("resetSuccess");
                session.removeAttribute("resetEmail"); 
                session.removeAttribute("resetOtp");
        %>
            // Guna 'flex' untuk memastikan modal center ikut style.css
            document.getElementById('successModal').style.display = 'flex';
        <% } %>
    };
    
    function handleBack() {
        // Check if there is any input in the form fields
        const inputs = document.querySelectorAll('.login-right input');
        let hasContent = false;

        inputs.forEach(input => {
            if (input.type !== "hidden" && input.value.trim().length > 0) {
                hasContent = true;
            }
        });

        // If user has typed something, ask for confirmation
        if (hasContent) {
            const confirmCancel = confirm("You have unsaved changes. Are you sure you want to go back to login?");
            if (!confirmCancel) return; 
        }

        // Redirect to login page
        window.location.href = "login.jsp";
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