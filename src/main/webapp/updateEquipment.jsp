<%@ page import="cems.staffBean"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
<%
Equipment eqp = (Equipment) request.getAttribute("equipment");
String category = "";
if (eqp instanceof ServiceEquipment) {
	category = ((ServiceEquipment) eqp).getServiceSet();
} else if (eqp instanceof SupportEquipment) {
	category = ((SupportEquipment) eqp).getEqpFunction();
}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Update Equipment</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
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
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='EquipmentController?action=list'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>
				
				<div class="events-header">
					<div class="header-text">
						<h2 class="section-title">Update Equipment</h2>
					</div>
				</div>

				<form id="updateForm" action="EquipmentController" method="post"
					enctype="multipart/form-data">
					<input type="hidden" name="action" value="update"> <input
						type="hidden" name="eqpID" value="<%=eqp.getEqpID()%>">

					<div class="detail-grid">
						<div class="form-inputs-grid">
							<div class="input-group">
								<label>Equipment Name</label> <input type="text" name="eqpName"
									class="field-input-static lock" value="<%=eqp.getEqpName()%>"
									readonly
									style="background-color: #2a2a2a !important; color: #888 !important; cursor: not-allowed;">
							</div>

							<div class="input-group">
								<label>Add Quantity</label> <input type="number"
							           name="addedQty"  class="field-input-static"
							           value="0"        min="1"          required>
							    <small style="color: #888;">Current stock in system: <%=eqp.getEqpQty()%></small>
							</div>

							<div class="input-group">
								<label>Type of Equipment</label> <input type="text"
									class="field-input-static lock"
									value="<%=(eqp instanceof ServiceEquipment) ? "Service" : "Support"%>"
									readonly
									style="background-color: #2a2a2a !important; color: #888 !important; cursor: not-allowed;">
							</div>

							<div class="input-group">
								<label>Category Details</label> <input type="text"
									class="field-input-static lock"
									value="<%=(category != null) ? category.toLowerCase() : ""%>"
									readonly
									style="background-color: #2a2a2a !important; color: #888 !important; cursor: not-allowed;">
							</div>
						</div>

						<div class="image-column-container">
							<label
								style="color: white; display: block; margin-bottom: 12px; font-weight: 500; font-size: 14px;">Equipment
								Image</label>

							<div class="detail-main-card-lock">
								<div class="detail-img-containerr">
									<label class="image-box-static lock"
										style="background-color: #2a2a2a !important; cursor: default; border: 2px dashed #444; height: 250px; display: flex; align-items: center; justify-content: center;">
										<img id="imagePreview"
										src="<%=(eqp.getEqpImage() != null) ? eqp.getEqpImage() : "icon/ImageInsrt.png"%>"
										style="max-width: 90%; max-height: 90%; object-fit: contain; opacity: 0.5;">
									</label>
								</div>
							</div>
						</div>
					</div>

					<div class="button-wrapper">
						<button type="button" class="submit-btn" onclick="submitUpdate()">Update</button>
					</div>
				</form>
			</div>
		</main>
	</div>

	<div class="modal-overlay" id="successModal" style="display: none;"
		onclick="closeModalOnOutsideClick(event)">
		<div class="update-modal-dark" onclick="event.stopPropagation()">
			

			<div class="modal-content-area">
				<div class="modal-icon-check-circle">
					<i class="fas fa-check"></i>
				</div>
				<h2 class="modal-title-orange">Success!</h2>
				<p class="modal-message-white">Equipment has been successfully
					updated.</p>

				<button class="btn-orange-glow"
					onclick="window.location.href='EquipmentController?action=list'">
					Go to Equipment List</button>
			</div>
		</div>
	</div>
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

        function previewImage(event) {
        const file = event.target.files[0];
        const img = document.getElementById('imagePreview');
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                img.src = reader.result;
            };
            reader.readAsDataURL(file);
        }
    }
    function validateAndUpdate() {
        const form = document.getElementById('updateForm');
        const qtyInput = document.getElementById('updateQty');
        
        if (!qtyInput.checkValidity()) {
            qtyInput.reportValidity();
            return;
        }

        // Submit the form to the Controller
        form.submit();
    }
    function submitUpdate() {
        const form = document.getElementById('updateForm'); 
        const btn = document.querySelector('.submit-btn');
		if(!form) {
            console.error("Form tidak dijumpai!");
            return;
        }
        const originalText = btn.innerHTML;

        btn.innerHTML = 'Updating... <i class="fas fa-spinner fa-spin"></i>';
        btn.style.pointerEvents = 'none';
		btn.style.opacity = '0.7';

        const formData = new FormData(form);

        fetch("EquipmentController", {
            method: "POST",
            body: formData
        })
        .then(response => {
            if (response.ok) {
                // Tunjuk modal
                document.getElementById('successModal').style.display = 'flex';
                
                // --- TAMBAHAN: Auto redirect ke List selepas 2 saat ---
                
                // -----------------------------------------------------
            } else {
                alert("Update failed!");
                btn.innerHTML = originalText;
                btn.style.pointerEvents = 'auto';
				btn.style.opacity = '1';
            }
        })
        .catch(error => {
            console.error('Error:', error);
			alert("Technical Error.");
            btn.innerHTML = originalText;
            btn.style.pointerEvents = 'auto';
			btn.style.opacity = '1';
        });
    }
    
    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }
    
    function closeModalOnOutsideClick(event) {
        const modal = document.getElementById('successModal');
        if (event.target === modal) {
            closeModal('successModal');
        }
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