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

		<main class="main">
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='PackageController?action=list'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>
				

				<div class="page-info">
					<h1 class="package-title">${packageCatering.packName}</h1>
					<div class="info-group">
						<p class="package-id">ID: ${packageCatering.packID}</p>
						<p class="package-pax">Pax: ${packageCatering.lowPackPax} -
							${packageCatering.highPackPax}</p>
					</div>
				</div>

				<div class="events-section">
					<div class="events-header">
						<h1 class="section-subtitle">Equipment Included</h1>
						<div class="header-actions">
							<a class="update-btn"
								href="PackageController?action=edit&packID=${packageCatering.packID}">
								<i class="fas fa-edit"></i> Update Quantity
							</a>
							<button class="btn-primary" onclick="openEquipModal()">
								<i class="fa fa-plus"></i> Add Equipment
							</button>
						</div>
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
									<td><strong>${item.eqpID}
									<input type="hidden" name="eqpID"
										value="${item.eqpID}">
									</strong></td>
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

									<td>${item.qtyRequired} <%-- Compare against 'Y' (ASCII 89) --%>
										<c:if test="${item.is_paxDepend == 89}">
											<span style="font-size: 0.9em; color: #888;"> (per
												person)</span>
										</c:if>
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
			</div>
		</main>
	</div>

	<div id="newEquipmentModal" class="equip-modal-overlay">
		<div class="equip-modal-content">
			<div class="equip-modal-header">
				<h3>Add New Equipment</h3>
				<span class="equip-close-btn" onclick="closeEquipModal()">&times;</span>
			</div>

			<form action="PackageController" method="post" id="addEquipForm">
				<input type="hidden" name="action" value="addContent">
				<div class="equip-modal-body">
					<input type="hidden" name="packID"
						value="${packageCatering.packID}"> <input type="hidden"
						name="isPaxDepend" id="isPaxDepend" value="false">

					<div class="form-group">
						<label for="eqpID">Select Equipment</label> <select name="eqpID"
							id="eqpID" required>
							<option value="" disabled selected>Choose equipment...</option>
							<c:forEach var="item" items="${availableEquipmentList}">
								<option value="${item.eqpID}">${item.eqpName}</option>
							</c:forEach>
						</select>
					</div>

					<div class="form-group">
						<label class="radio-label">Is Quantity Pax Dependent?</label>
						<div class="radio-group">
							<label class="radio-option"> <input type="radio"
								name="paxRadio" value="yes" onchange="togglePaxLogic(true)">
								Yes
							</label> <label class="radio-option"> <input type="radio"
								name="paxRadio" value="no" checked
								onchange="togglePaxLogic(false)"> No
							</label>
						</div>
					</div>
						
					<div class="form-group" id="qtyInputGroup">
						<label for="qtyRequired">Quantity Required</label> <input
							type="number" name="qtyRequired" id="qtyRequired" min="1"
							placeholder="e.g. 100" required>
					</div>
				</div>

				<div class="equip-modal-footer">
					<button type="button" class="btn-cancel"
						onclick="closeEquipModal()">Cancel</button>
					<button type="submit" class="btn-primary">Add to Package</button>
				</div>
			</form>
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
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}

		function openEquipModal() {
			const modal = document.getElementById('newEquipmentModal');
			modal.style.display = 'flex';

			// Ensure logic is reset when opening
			const noRadio = document
					.querySelector('input[name="paxRadio"][value="no"]');
			if (noRadio) {
				noRadio.checked = true;
				togglePaxLogic(false);
			}
		}

		function closeEquipModal() {
			const modal = document.getElementById('newEquipmentModal');
			modal.style.display = 'none';
		}

		// Close ONLY this modal if clicking outside
		window.addEventListener('click', function(event) {
			const modal = document.getElementById('newEquipmentModal');
			if (event.target == modal) {
				modal.style.display = 'none';
			}
		});

		// --- Logic for Pax Dependency ---
		function togglePaxLogic(isDependent) {
			const qtyGroup = document.getElementById('qtyInputGroup');
			const qtyInput = document.getElementById('qtyRequired');
			const hiddenFlag = document.getElementById('isPaxDepend');

			if (isDependent) {
				// If YES: Hide input, remove requirement, set value to 0
				qtyGroup.style.display = 'none';
				qtyInput.required = false;
				qtyInput.value = "1"; // Backend handles this as "Dynamic/Pax Dependent"
				hiddenFlag.value = "true";
			} else {
				// If NO: Show input, make required, clear value
				qtyGroup.style.display = 'block';
				qtyInput.required = true;
				qtyInput.value = "";
				hiddenFlag.value = "false";
			}

		function showLogoutModal() {
		    document.getElementById("logoutModal").style.display = "flex";
		}

		function closeLogoutModal() {
		    document.getElementById("logoutModal").style.display = "none";
		}
		}
	</script>
</body>
</html>