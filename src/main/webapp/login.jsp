

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<link rel="icon" href="data:,">
<link rel="stylesheet" href="style.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>
<div class="login-page">
    <div class="login-card">
        <div class="login-left">
            <div class="logo-wrapper">
                <div class="logo-circle">
                    <img src="icon/logo.png" alt="Logo">
                </div>
            </div>
            <h1 class="system-title">Catering Equipment<br>Management System</h1>
        </div>
        <div class="login-right">
            <h2 class="login-title">Log In</h2>
            <% 
		        // 1. Retrieve the message from the session
		        String loginError = (String) session.getAttribute("loginError"); 
		        
		        if (loginError != null) { 
		    %>
		        <div class="error-container">
		            <i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
		            <span class="error-text"><%= loginError %></span>
		        </div>
		    <% 
		            // 2. Remove it immediately so it is gone on next refresh
		            session.removeAttribute("loginError"); 
		        } 
		    %>
            <form action="staffServlet" method="post" class="form-register">
            <input type="hidden" name="action" value="login">
                <div class="role-group">
                    <label class="role-option">
                        <input type="radio" name="staffRole" value="MANAGER" required>
                        <span>Manager</span>
                    </label>
                    <label class="role-option">
                        <input type="radio" name="staffRole" value="COORDINATOR">
                        <span>Coordinator</span>
                    </label>
                </div>

                <input type="email" name="staffEmail" placeholder="Email" class="login-input" required>
                <input type="password" name="staffPassword" placeholder="Password" class="login-input" maxlength="8" required>
                
				<div style="width: 75%; text-align: right; margin-bottom: 10px;">
				    <a href="forgotPass.jsp" class="forgot-password-link">Forgot Password?</a>
				</div>                
                <button type="submit" class="login-btn">Log In</button>
            </form>

             <p class="register-text">
                New Coordinator? <a href="register.jsp">Register Here</a>
            </p>
        </div>
    </div>
</div>
</body>
</html>