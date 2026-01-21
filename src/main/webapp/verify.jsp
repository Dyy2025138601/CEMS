<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
    <title>Verify account</title>
    <link rel="stylesheet" href="style.css">
     <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>
<div class="page-container">
    <div class="verify-card">
        <h2 class="form-title">Verify your account</h2>
       
        <p class="subtitle">Please enter the 4 digit code sent to ${sessionScope.staffEmail}</p>
        <% 
            String otpError = (String) session.getAttribute("otpError");
            if (otpError != null) { 
        %>
            <div class="verify-error-container">
                <i class="fa-solid fa-circle-exclamation" style="color: #b80000;"></i>
                <span class="verify-error-text"><%= otpError %></span>
            </div>
        <% 
                session.removeAttribute("otpError");
            } 
        %>
        
        <form action="staffServlet" method="post">
        <input type="hidden" name="action" value="verify">
             <div class="otp-container">
                <input type="text" name="otp1" maxlength="1" class="otp-box" oninput="moveNext(this, 'otp2')" id="otp1" required>
                <input type="text" name="otp2" maxlength="1" class="otp-box" oninput="moveNext(this, 'otp3')" id="otp2" required>
                <input type="text" name="otp3" maxlength="1" class="otp-box" oninput="moveNext(this, 'otp4')" id="otp3" required>
                <input type="text" name="otp4" maxlength="1" class="otp-box" id="otp4" required>
            </div>

            <button type="submit" class="primary-btn">Confirm</button>
        </form>
        
        <a href="staffServlet?action=resend" class="resend-link">Resend Code</a>
    </div>
</div>
<div class="modal-overlay" id="successModal" style="display: none;">
    <div class="update-modal-dark">
        <div class="modal-content-area">
            <div class="modal-icon-check-circle">
                <i class="fas fa-check"></i>
            </div>
            <h2 class="modal-title-orange">Verified!</h2>
            <p class="modal-message-white">Account Successfully Registered.</p>

            <button class="btn-orange-glow" onclick="closeModal()">
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

    function closeModal() {
        document.getElementById('successModal').style.display = 'none';
        window.location.href = "login.jsp"; 
    }

    window.onload = function() {
        <% 
           Boolean showSuccess = (Boolean) session.getAttribute("showSuccess");
           if (showSuccess != null && showSuccess) { 
               session.removeAttribute("showSuccess");
        %>
            // Guna 'flex' supaya dia center ke tengah screen ikut style.css anda
            document.getElementById('successModal').style.display = 'flex';
        <% } %>
    };
</script>
</body>
</html>