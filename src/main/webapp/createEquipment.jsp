<%@ page import="cems.staffBean" %>
<%@ page import="java.util.List" %>
<%@ page import="cems.Equipment" %>
<%@ page import="cems.ServiceEquipment" %>
<%@ page import="cems.SupportEquipment" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    staffBean staff = (staffBean) session.getAttribute("staff");
    
    // Check if logged in AND if the role is correct
    if (staff == null || !"MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
        session.invalidate(); 
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Equipment</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="farah1.css">
</head>
<body>
    <div class="layout">
    	<div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
            </div>

            <nav class="nav-menu">
                <a href="dashboardManager.jsp" class="nav-item"> 
                    <img src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> 
                    <span class="link-text">Dashboard</span>
                </a> 
                <a href="EquipmentController?action=list" class="nav-item active"> 
                    <img src="icon/eqp.png" class="nav-icon"> 
                    <span class="link-text">Equipment</span>
                </a> 
                <a href="viewEventList.jsp" class="nav-item"> 
                    <img src="icon/event.png" class="nav-icon"> 
                    <span class="link-text">Event</span>
                </a> 
                <a href="PackageController?action=list" class="nav-item"> 
                    <img src="icon/package.png" class="nav-icon"> 
                    <span class="link-text">Package</span>
                </a> 
                <a href="viewCoordinatorList.jsp" class="nav-item"> 
                    <img src="icon/coordinator.png" class="nav-icon"> 
                    <span class="link-text">Coordinator</span>
                </a> 
                <a href="viewReportList.jsp" class="nav-item"> 
                    <img src="icon/report.png" class="nav-icon"> 
                    <span class="link-text">Report</span>
                </a>
            </nav>

            <div class="logout-section">
                <a href="logout.jsp" class="nav-icon-logout"> 
                    <img src="icon/logout.png"> <span class="link-text">Log Out</span>
                </a>
            </div>
        </div>
        <div class="header">
            <div>
                <h2 class="welcome-text">Equipment</h2>
            </div>
            <div class="user-profile">
                <div class="user-info">
                    <span class="user-name"><%= staff.getStaffName() %></span>
                    <span class="user-role"><%= staff.getStaffRole() %></span>
                </div>
                <a href="account.jsp" class="profile-link"> 
                    <span class="profile-pic-default"> 
                        <img src="icon/user.png" alt="profile_image">
                    </span>
                </a>
            </div>
        </div>
        <main class="main">
            <div class="content-box" id="addView">
                <div class="detail-header-stack">
                    <button class="back-link" onclick="window.location.href='EquipmentController?action=list'">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                    <h1 class="page-title">Add New Equipment</h1>
                </div>

                <form id="eqpForm" action="EquipmentController" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="insert">
                    
                    <div class="detail-grid">
					    <div class="form-inputs-grid">
					        <div class="input-group">
					            <label>Equipment Name</label>
					            <input type="text" name="eqpName" class="field-input-static" placeholder="e.g. Silver Fork" required>
					        </div>
					        <div class="input-group">
					            <label>Quantity</label>
					            <input type="number" name="eqpQty" class="field-input-static" min="1" required>
					        </div>
					        <div class="input-group">
					            <label>Type of Equipment</label>
					            <select id="equipmentType" name="equipmentType" class="field-input-static" onchange="handleTypeChange()" required>
					                <option value="" disabled selected>Select type</option>
					                <option value="service">Service</option>
					                <option value="support">Support</option>
					            </select>
					        </div>
					
					        <div id="serviceOptions" class="category-options" style="display:none;">
					            <label>Category (Service):</label>
					            <div class="radio-group">
					                <label><input type="radio" name="service" value="VIP"> VIP</label>
					                <label><input type="radio" name="service" value="GUEST"> Guest</label>
					            </div>
					        </div>
					
					        <div id="supportOptions" class="category-options" style="display:none;">
					            <label>Category (Support):</label>
					            <div class="radio-group">
					                <label><input type="radio" name="support" value="PREPARATION"> Preparation</label>
					                <label><input type="radio" name="support" value="WASHING"> Washing</label>
					                <label><input type="radio" name="support" value="STORAGE"> Storage</label>
					            </div>
					        </div>
					    </div>
					
					    <div class="image-column-container">
					        <label style="color: white; display: block; margin-bottom: 12px; font-weight: 500; font-size: 14px;">Equipment Image</label>
					        <div class="detail-main-card">
					            <div class="detail-img-containerr">
					                <label for="equipmentImage" class="image-box-static" style="height: 250px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
					                    <img id="imagePreview" src="icon/ImageInsrt.png" style="max-width: 80%; max-height: 80%; object-fit: contain;">
					                    <span style="margin-top: 10px; font-size: 12px; color: #ccc;">Click to Upload Image</span>
					                </label>
					                <input type="file" id="equipmentImage" name="equipmentImage" hidden accept="image/*" onchange="previewImage(event)">
					            </div>
					        </div>
					    </div>
					</div> <div class="button-wrapper">
                        <button type="button" class="submit-btn" onclick="validateAndSubmit()">Save</button>
                    </div>
                </form>
            </div>
        </main>
    </div>
    
    <div class="modal-overlay" id="successModal">
	    <div class="update-modal-dark">
	     
	        <div class="modal-content-area">
	            <div class="modal-icon-check-circle">
	                <i class="fas fa-check"></i>
	            </div>
	            <h2 class="modal-title-orange">Success!</h2>
	            <p class="modal-message-white">New equipment has been successfully created.</p>
	            <button class="btn-orange-glow" onclick="window.location.href='EquipmentController?action=list'">
	                Go to Equipment List
	            </button>
	        </div>
	    </div>
	</div>
    
    <script>
        function handleTypeChange() {
            const type = document.getElementById('equipmentType').value;
            const serviceDiv = document.getElementById('serviceOptions');
            const supportDiv = document.getElementById('supportOptions');
            if (type === 'service') {
                serviceDiv.style.display = 'block';
                supportDiv.style.display = 'none';
            } else {
                serviceDiv.style.display = 'none';
                supportDiv.style.display = 'block';
            }
        }

        function previewImage(event) {
            const file = event.target.files[0];
            if (!file) return;

            const img = document.getElementById('imagePreview');
            // This finds the <span> text inside your label
            const uploadText = document.querySelector('.image-box-static span');

            const reader = new FileReader();
            reader.onload = () => {
                img.src = reader.result;
                img.style.width = "100%";
                img.style.height = "100%";
                img.style.objectFit = "contain";
                
                // Hides the "Click to Upload Image" text
                if (uploadText) {
                    uploadText.style.display = "none";
                }
            };
            reader.readAsDataURL(file);
        }

        function validateAndSubmit() {
            const form = document.getElementById('eqpForm');
            const imageInput = document.getElementById('equipmentImage');
            const btn = document.querySelector('.submit-btn');
            
            // 1. Check validasi basic (required fields)
            if (!form.checkValidity()) { 
                form.reportValidity(); 
                return; 
            }
            
            // 2. Check kalau gambar tak upload
            if (imageInput.files.length === 0) { 
                alert("⚠️ Please upload an image."); 
                return; 
            }

            // --- LOADING STATE ---
            const originalText = btn.innerHTML;
            btn.innerHTML = 'Saving... <i class="fas fa-spinner fa-spin"></i>';
            btn.style.pointerEvents = 'none';
            btn.style.opacity = '0.7';

            // 3. Guna FormData untuk hantar fail & input
            const formData = new FormData(form);

            fetch("EquipmentController", {
                method: "POST",
                body: formData
            })
            .then(response => {
                if (response.ok) {
                    // Tunjuk modal success
                    document.getElementById('successModal').style.display = 'flex';
                } else {
                    alert("Failed to save equipment. Please check console for errors.");
                    // Reset butang
                    btn.innerHTML = originalText;
                    btn.style.pointerEvents = 'auto';
                    btn.style.opacity = '1';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert("Technical error occurred.");
                btn.innerHTML = originalText;
                btn.style.pointerEvents = 'auto';
                btn.style.opacity = '1';
            });
        }
    </script>
</body>
</html>