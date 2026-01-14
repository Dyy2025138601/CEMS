<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register account</title>
    <link rel="icon" href="data:,">
	<link rel="stylesheet" href="register.css?v=1.2">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>

<div class="register-page">
    <div class="register-card">
        <div class="register-left">
            <div class="logo-wrapper">
                <div class="logo-circle">
                    <img src="icon/logo.png" alt="Logo">
                </div>
            </div>
            <h1 class="system-title">
                Catering Equipment<br>
                Management System
            </h1>
        </div>
        <div class="register-right">
            <h2 class="register-title">Create Your Account</h2>
			<% 
		        String regError = (String) session.getAttribute("regError");
		        if (regError != null) { 
		    %>
		        <div class="error-container">
		            <i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
		            <span class="error-text"><%= regError %></span>
		        </div>
		    <% 
		            session.removeAttribute("regError");
		        } 
		    %>
		    
		    <div class="error-container" id="clientError" style="display: none;">
		        <i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
		        <span class="error-text" id="clientErrorText"></span>
		    </div>
		    
            <form action="staffServlet" method="post" onsubmit="return validateRegister()">
                <input type="hidden" name="action" value="register">
                <div class="role-group">
                    <label class="role-option">
                        <input type="radio" name="staffRole" value="MANAGER" required>
                        <span>Manager</span>
                    </label>
                    <label class="role-option">
                        <input type="radio" name="staffRole" value="COORDINATOR" required>
                        <span>Coordinator</span>
                    </label>
                </div>

                <input type="text" name="staffName" placeholder="Username" class="register-input" required>
                <input type="email" name="staffEmail" placeholder="Email" class="register-input" required>
                <input type="password" name="staffPassword" placeholder="Password" id = "pass" class="register-input" required>
                <input type="password" name="confirmPassword" placeholder="Confirm Password" id="confirmPass" class="register-input" required>
                <input type="number" name="staffPhoneNum" placeholder="Phone Number" class="register-input" required>
                

                <button type="submit" class="register-btn" id="regBtn">
                    Register
                </button>
            </form>

            <p class="login-text">
                Already have an account?
                <a href="login.jsp">Log In</a>
            </p>
        </div>
    </div>
</div>
<script>
function validateRegister() {
    const pass = document.getElementById("pass").value;
    const confirmPass = document.getElementById("confirmPass").value;
    const errorBox = document.getElementById("clientError");
    const errorText = document.getElementById("clientErrorText");

    // 1. Password Length Validation (Maximum 6)
    if (pass.length > 6) {
        errorText.innerText = "Password must not exceed 6 characters.";
        errorBox.style.display = "flex";
        return false;
    }

    // 2. Password Matching Validation
    if (pass !== confirmPass) {
        errorText.innerText = "Passwords do not match.";
        errorBox.style.display = "flex";
        return false;
    }

    return true; // Proceed to Servlet
}
</script>
</body>
</html>