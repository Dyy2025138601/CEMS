
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="cems.staffBean"%>
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
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Package Details</title>
<link rel="stylesheet" href="style.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap')
	;
</style>
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
					
				</a> <a href="EquipmentController?action=list" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
					
				</a> <a href="EventController?action=list" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
					
				</a> <a href="PackageController?action=list" class="nav-item active"> <img
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
				<h2 class="welcome-text">Package</h2>
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

		<!-- main content page -->
		<!-- main content page -->
		<main class="main">
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='PackageController?action=list'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>
				
				<div class="events-header">
						<h1 class="section-title">Update Package</h1>
				</div>
				
				<div class="page-info">
					<h1 class="package-title">${packageCatering.packName}</h1>
					<div class="info-group">
						<p class="package-id">ID: ${packageCatering.packID}</p>
						<p class="package-pax">Pax: ${packageCatering.lowPackPax} -
							${packageCatering.highPackPax}</p>
					</div>
				</div>

				<form id="updatePackageForm">
					<input type="hidden" name="action" value="updateQty"> <input
						type="hidden" name="packID" value="${packageCatering.packID}">

					<!-- table -->
					<div class="table-group">
						<h1 class="section-subtitle">Equipment Included</h1>
					</div>
					<table class="table">
						<colgroup>
							<col style="width: 18%">
							<col style="width: 22%">
							<col style="width: 18%">
							<col style="width: 18%">
							<col style="width: 30%">
						</colgroup>
						<thead>
							<tr>
								<th>ID</th>
								<th>Name</th>
								<th>Type</th>
								<th>Category</th>
								<th>Quantity Required</th>
							</tr>
						</thead>
						<tbody class="body-row">
							<c:forEach items="${contentList}" var="item">
								<tr>
									<td>${item.eqpID}<input type="hidden" name="eqpID"
										value="${item.eqpID}">
									</td>
									<td>${item.eqpName}</td>

									<%-- DYNAMIC TYPE COLUMN --%>
									<td><c:choose>
											<%-- If serviceSet has a value, it's Service equipment --%>
											<c:when test="${not empty item.serviceSet}">
												<span class="dot service"></span> Service
                    						</c:when>
											<%-- If eqpFunction has a value, it's Support equipment --%>
											<c:when test="${not empty item.eqpFunction}">
												<span class="dot support"></span> Support
                   							</c:when>
										</c:choose></td>

									<%-- DYNAMIC CATEGORY COLUMN --%>
									<td style="text-transform: capitalize;"><c:choose>
											<c:when test="${not empty item.serviceSet}">
                        							${item.serviceSet}
                    						</c:when>
											<c:when test="${not empty item.eqpFunction}">
                        							${item.eqpFunction}
                    						</c:when>
											<c:otherwise>
                        -
                    						</c:otherwise>
										</c:choose></td>

									<td>
										<div style="display: flex; align-items: center; gap: 5px;">
											<input type="number" name="qtyRequired"
												value="${item.qtyRequired}" class="quantity-input">
											<c:if test="${item.is_paxDepend == 89}">
												<span
													style="font-size: 0.9em; color: #888; white-space: nowrap;">
													(per person) </span>
											</c:if>
										</div>
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
					<!-- button -->
					<div class="table-actions">
						<button type="button" class="btn reset-btn">Reset</button>
						<button class="btn submit-btn">Submit</button>
					</div>

				</form>
			</div>

		</main>
	</div>
	
	<!-- Success Modal -->
	<div id="createSuccessModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
        <div class="modal-icon-container" style="font-size: 50px; color: #2ecc71; margin-bottom: 20px;">
            <i class="fas fa-check-circle"></i>
        </div>
        <h3 style="color: white; margin-bottom: 10px;">Success!</h3>
        <p class="modal-text" style="color: #cccccc; margin-bottom: 30px;">
            The equipment quantities for this package have been updated.
        </p>
        <div class="modal-buttons" style="display: flex; justify-content: center;">
            <button class="btn-logout" 
                style="background: linear-gradient(to right, #ff8c00, #ff4500); min-width: 200px;"
                onclick="window.location.href='PackageController?action=list'">
                Back to Package List
            </button>
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
		  const inputs = document.querySelectorAll('.quantity-input');
		
		  // Store original values
		  inputs.forEach(input => {
		    input.dataset.original = input.value;
		  });
		
		  document.querySelector('.reset-btn').addEventListener('click', () => {
		    inputs.forEach(input => {
		      input.value = input.dataset.original;
		      input.closest('tr').classList.remove('edited');
		    });
		  });
			
		  /*
		  document.querySelector('.btn-save').addEventListener('click', () => {
		    const updatedData = [];
		
		    inputs.forEach(input => {
		      updatedData.push({
		        eqpId: input.closest('tr').children[0].innerText,
		        quantity: input.value
		      });
		    });
		
		    console.log('Saved data:', updatedData);
		    alert('Changes saved successfully!');
		  });*/
	</script>

	<script>
	
	// C. Form Submit
    // Kod untuk Submit Form via AJAX
// Kod untuk Submit Form via AJAX
document.getElementById('updatePackageForm').onsubmit = function(e) {
    e.preventDefault();
    
    const formData = new URLSearchParams(new FormData(this));
    
    fetch('PackageController', {
        method: 'POST',
        body: formData,
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    })
    .then(response => {
        if (response.ok) {
            // Tunjukkan modal yang sama gaya dengan logout
            document.getElementById('createSuccessModal').style.display = 'flex';
        } else {
            alert("❌ Failed to update package.");
        }
    })
    .catch(err => {
        console.error("System Error:", err);
        alert("System Error occurred.");
    });
}; // Pastikan tutup dengan betul di sini

// Fungsi Logout (Kekalkan yang sedia ada)
function showLogoutModal() {
    document.getElementById("logoutModal").style.display = "flex";
}
function closeLogoutModal() {
    document.getElementById("logoutModal").style.display = "none";
}
    </script>

</body>
</html>