<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register account</title>
    <link rel="icon" href="data:,">
	<link rel="stylesheet" href="style.css">
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
		    
            <form action="staffServlet" method="post" class="form-register" onsubmit="return validateRegister()">
                <input type="hidden" name="action" value="register">

                <input type="text" name="staffName" placeholder="Name" class="register-input" required>
				<input type="email" name="staffEmail" placeholder="Email" class="register-input" required>
				
				<input type="password" name="staffPassword" placeholder="Password" id="pass" class="register-input" maxlength="8" required>
				<input type="password" name="confirmPassword" placeholder="Confirm Password" id="confirmPass" class="register-input" maxlength="8" required>
				<div class="registration-hints">
				    * Password must be exactly 8 characters.<br>
				</div>
				<input type="number" name="staffPhoneNum" id="phone" placeholder="Phone Number" class="register-input" oninput="if(this.value.length > 12) this.value = this.value.slice(0, 12);" required>
				<div class="registration-hints">
				    * Phone number max 12 digits.
				</div>
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
    const phone = document.getElementById("phone").value;
    const errorBox = document.getElementById("clientError");
    const errorText = document.getElementById("clientErrorText");

    // Updated to check for exactly 8
    if (pass.length !== 8) {
        errorText.innerText = "Password must be exactly 8 characters.";
        errorBox.style.display = "flex";
        return false;
    }

    if (pass !== confirmPass) {
        errorText.innerText = "Passwords do not match.";
        errorBox.style.display = "flex";
        return false;
    }
    
 // Check Phone Length (Max 13)
    if (phone.length > 13) {
        errorText.innerText = "Phone number cannot exceed 13 digits.";
        errorBox.style.display = "flex";
        return false;
    }

    return true;
}
</script>
</body>
</html>