<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Coordinator - Account</title>
    <link rel="stylesheet" href="account.css?v=1.2">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>
    <div class="dashboard" id="dashboard">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
            </div>                
            <nav class="nav-menu">
                <a href="dashboardCoordinator.jsp" class="nav-item">
                    <img src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> 
                    <span class="link-text">Dashboard</span>
                </a>
                <a href="viewAssignedList.jsp" class="nav-item">
                    <img src="icon/event.png" class="nav-icon"> 
                    <span class="link-text">Event</span>
                </a>
            </nav>
            <div class="logout-section">
                <a href="logout.jsp" class="nav-icon-logout">
                   <img src="icon/logout.png"> <span class="link-text">Log Out</span>
                </a>
            </div>
        </div>

        <div class="header"> 
            <h2 class="welcome-text">Account Settings</h2>
            <div class="user-profile">
                <div class="user-info">
                    <span class="user-name">Farhan Mazlan</span>
                    <span class="user-role">Event Coordinator</span>
                </div>
                <a href="accountCoordinator.jsp" class="profile-link">
                    <span class="profile-pic-default">
                        <img src="icon/user.png" alt="profile_image">
                    </span>
                </a>
            </div>
        </div>

        <main class="main">
		    <div class="profile-card">
		        <div id="view-profile" class="view">
		            <header class="profile-header">
		                <div class="avatar-wrapper"><img src="icon/user.png" alt="Profile"></div>
		                <div class="header-text">
		                    <h2>Hawa Aqiera</h2>
		                    <p>Coordinator</p>
		                </div>
		            </header>
		            <div class="settings-grid">
		                <div class="field-row">
		                    <div class="field-info"><label>Email Address</label><span class="value">hawa@example.com</span></div>
		                </div>
		                <hr class="divider">
		                <div class="field-row">
		                    <div class="field-info"><label>Phone Number</label><span class="value">0123456789</span></div>
		                    <button class="text-edit-btn" onclick="showView('view-phone')">Update</button>
		                </div>
		                <hr class="divider">
		                <div class="field-row">
		                    <div class="field-info"><label>Password</label><span class="value">••••••••</span></div>
		                    <button class="text-edit-btn" onclick="showView('view-password')">Update</button>
		                </div>
		            </div>
		        </div>
		
		        <div id="view-phone" class="view" style="display:none;">
		            <button class="back-link" onclick="handleBack()"><i class="fas fa-arrow-left"></i> Back</button>
		            <h2 class="view-title">Update Phone</h2>
		            <form class="static-form" onsubmit="event.preventDefault(); showSuccessState();">
		                <div class="input-block">
		                    <label>New Phone Number</label>
		                    <input type="tel" id="input-phone" class="minimal-input" placeholder="0123456789" pattern="[0-9]*" oninput="checkInput(this)"required>
		                    <span id="phone-error" class="error-text">Only numbers allowed</span>
		                    <button type="submit" class="update-btn">Update</button>
		                    </div>
		            </form>
		        </div>
		
		        <div id="view-password" class="view" style="display:none;">
		            <button class="back-link" onclick="handleBack()"><i class="fas fa-arrow-left"></i> Back</button>
		            <h2 class="view-title">Change Password</h2>
		            <form class="static-form" onsubmit="event.preventDefault(); showSuccessState();">
		                <div class="input-block">
		                    <label>Old Password</label>
		                    <input type="password" id="input-old-pass" class="minimal-input">
		                </div>
		                <div class="input-block">
		                    <label>New Password</label>
		                    <input type="password" id="input-new-pass" class="minimal-input">
		                </div>
		                <div class="input-block">
		                    <label>Confirm Password</label>
		                    <input type="password" id="input-confirm-pass" class="minimal-input">
		                    <button type="submit" class="update-btn">Update</button>
		                </div>
		            </form>
		        </div>
		        
		        <div id="confirmModal" class="modal-overlay" style="display: none;">
				    <div class="modal-content confirm-modal">
				        <p id="confirmMessage">You have unsaved changes. Are you sure you want to cancel?</p>
				        <div class="modal-footer-confirm">
				            <button type="button" class="modal-cancel-btn" onclick="closeConfirm(false)">No</button>
				            <button type="button" class="modal-ok-btn" onclick="closeConfirm(true)">Yes, Discard</button>
				        </div>
				    </div>
				</div>
		
		        <div id="view-success" class="view" style="display:none; text-align: center;">
				    <div class="success-icon">
				        <i class="fas fa-check"></i>
				    </div>
				    
				    <h2 id="successTitle" class="view-title">
				        Successfully<br>Updated
				    </h2>
				    
				    <p class="success-subtitle">
				        Your account details have been updated.
				    </p>
				    
				    <button class="back-btn" onclick="showView('view-profile')">
				        Back to Profile
				    </button>
				</div>
		    </div>
		</main>
    </div>

    <script>
    
    let currentViewId = 'view-profile';

    function showView(viewId) {
        // Hide all views
        document.querySelectorAll('.view').forEach(v => v.style.display = 'none');
        // Show target view
        document.getElementById(viewId).style.display = 'block';
        currentViewId = viewId;
    }

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

    function togglePasswordVisibility() {
        const passwordSpan = document.getElementById('password-value');
        const eyeIcon = document.getElementById('eye-icon');
        
        // In a real app, 'ActualPassword123' would come from your backend/state
        const realPassword = "ActualPassword123"; 
        const maskedPassword = "â¢â¢â¢â¢â¢â¢â¢â¢";

        if (passwordSpan.textContent === maskedPassword) {
            passwordSpan.textContent = realPassword;
            passwordSpan.style.letterSpacing = "0px"; // Normal spacing for text
            eyeIcon.classList.remove('fa-eye');
            eyeIcon.classList.add('fa-eye-slash');
        } else {
            passwordSpan.textContent = maskedPassword;
            passwordSpan.style.letterSpacing = "2px"; // Wider spacing for dots
            eyeIcon.classList.remove('fa-eye-slash');
            eyeIcon.classList.add('fa-eye');
        }
    }
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("collapsed");
            document.getElementById("dashboard").classList.toggle("collapsed");
        }
        
        function checkInput(input) {
            const errorSpan = document.getElementById('phone-error');
            
            // 1. If user typed a non-number
            if (/\D/.test(input.value)) {
                input.value = ""; // Reset the value
                errorSpan.style.display = 'block'; // Show error
            } 
            // 2. If the input is empty or contains only valid numbers
            else {
                errorSpan.style.display = 'none'; // Hide error immediately
            }
        }
        
        function handlePhoneSubmit(event) {
            event.preventDefault();
            const input = document.getElementById('input-phone');
            const errorSpan = document.getElementById('phone-error');

            if (!input.value.trim()) {
                errorSpan.textContent = "This field is required"; // Specific message for empty
                errorSpan.style.display = 'block';
                return;
            }

            // If everything is fine, show success
            showSuccessState();
        }
       
    </script>
</body>
</html>