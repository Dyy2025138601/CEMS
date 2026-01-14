<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
    <title>Verify account</title>
    <link rel="stylesheet" href="verify.css">
</head>
<body>
<div class="page-container">
    <div class="verify-card">
        <h2 class="form-title">Verify your account</h2>
        <%-- Displaying the email dynamically from session --%>
        <p class="subtitle">Please enter the 4 digit code sent to ${sessionScope.staffEmail}</p>
        
        <form action="staffServlet" method="post">
        <input type="hidden" name="action" value="verify">
            <div class="otp-container">
                <input type="text" name="otp1" maxlength="1" class="otp-box" oninput="moveNext(this, 'otp2')" id="otp1">
                <input type="text" name="otp2" maxlength="1" class="otp-box" oninput="moveNext(this, 'otp3')" id="otp2">
                <input type="text" name="otp3" maxlength="1" class="otp-box" oninput="moveNext(this, 'otp4')" id="otp3">
                <input type="text" name="otp4" maxlength="1" class="otp-box" id="otp4">
            </div>

            <button type="submit" class="primary-btn">Confirm</button>
        </form>
        
        <a href="staffServlet" class="resend-link">Resend Code</a>
    </div>
</div>

<script>
    function moveNext(current, nextId) {
        if (current.value.length >= 1) {
            document.getElementById(nextId).focus();
        }
    }
</script>
</body>
</html>