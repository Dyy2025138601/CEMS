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
    <link rel="stylesheet" href="style.css">
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
					
				</a> <a href="EquipmentController?action=list" class="nav-item active"> <img
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
            <div>
                <h2 class="welcome-text">Equipment</h2>
            </div>
            <div class="user-profile">
                <div class="user-info">
                    <span class="user-name"><%= staff.getStaffName() %></span>
                    <span class="user-role"><%= staff.getStaffRole() %></span>
                </div>
                <a href="accountManager.jsp" class="profile-link"> 
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
                </div>
                <div class="events-header">
						<h1 class="section-title">Add New Equipment</h1>
				</div>

                <form id="eqpForm" action="EquipmentController?action=insert" method="post" enctype="multipart/form-data">
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
                        <button type="button" class="submit-btn" onclick="validateAndSubmit()">Submit</button>
                    </div>
                </form>
            </div>
        </main>
    </div>

<div class="modal-overlay" id="successModal" style="display: none;">
    <div class="update-modal-dark">
        
        <div class="modal-content-area">
            <div class="modal-icon-check-circle">
                <i class="fas fa-check"></i>
            </div>
            <h2 class="modal-title-orange">Success!</h2>
            <p class="modal-message-white">New Equipment has been successfully created.</p>
            
            <button class="btn-orange-glow" onclick="window.location.href='EquipmentController?action=list'">
                Go to Equipment List
            </button>
        </div>
    </div>
</div>
	
    <!--<div class="modal-overlay" id="successModal" style="display:none">
	    <div class="update-modal-dark">
	        <span class="modal-close-x-dark" onclick="window.location.href='EquipmentController?action=list'">&times;</span>
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
	</div>-->
	
	<div id="logoutModal" class="modal-overlay" style="display: none;">
		<div class="modal-content">
			<div class="modal-icon-container"
				style="font-size: 50px; color: #f36f21; margin-bottom: 20px;">
				<i class="fa-solid fa-right-from-bracket"></i>
			</div>
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
            
            if (!form.checkValidity()) { 
                form.reportValidity(); 
                return; 
            }
            
            if (imageInput.files.length === 0) { 
                alert("⚠️ Please upload an image."); 
                return; 
            }

            const originalText = btn.innerHTML;
            btn.innerHTML = 'Saving... <i class="fas fa-spinner fa-spin"></i>';
            btn.style.pointerEvents = 'none';

            // Gunakan Fetch seperti di Update
            const formData = new FormData(form);
            fetch("EquipmentController?action=insert", {
                method: "POST",
                body: formData
            })
            .then(response => {
                if (response.ok) {
                    // Tunjukkan modal yang sudah disamakan design-nya
                    document.getElementById('successModal').style.display = 'flex';
                    
                    // Auto redirect setelah 2 detik
                    
                } else {
                    alert("Failed to create equipment!");
                    btn.innerHTML = originalText;
                    btn.style.pointerEvents = 'auto';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert("Technical Error occurred.");
                btn.innerHTML = originalText;
                btn.style.pointerEvents = 'auto';
            });
        }
         function showLogoutModal() {
 		    document.getElementById("logoutModal").style.display = "flex";
 		}

 		function closeLogoutModal() {
 		    document.getElementById("logoutModal").style.display = "none";
 		}
 		
 	// Add this inside your <script> tags at the bottom of createEquipment.jsp
 		const urlParams = new URLSearchParams(window.location.search);
 		if (urlParams.has('success')) {
 		    document.getElementById('successModal').style.display = 'flex';
 		}
    </script>
</body>
</html>