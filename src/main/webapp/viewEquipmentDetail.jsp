<%@ page import="cems.staffBean"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
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
<title>Equipment Details</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
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

				</a> <a href="EquipmentController?action=list" class="nav-item active">
					<img src="icon/eqp.png" class="nav-icon"> <span
					class="link-text">Equipment</span>

				</a> <a href="EventController?action=list" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>

				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>

				</a> <a href="staffServlet?action=listCoordinators" class="nav-item">
					<img src="icon/coordinator.png" class="nav-icon"> <span
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
				<a href="account.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png"
						alt="profile_image">
				</span>
				</a>
			</div>
		</div>
		<main class="main">
			<div class="content-box" id="detailView">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='EquipmentController?action=list'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>

				<div class="detail-grid">
					<div class="left-column">
						<div class="detail-main-card">
							<div class="detail-img-container">
								<img id="detailImg" src="<%=eqp.getEqpImage()%>"
									alt="Item Image">
							</div>
							<div class="detail-basic-info">
								<h2 id="detailName"><%=eqp.getEqpName()%></h2>
								<p class="detail-id" id="detailIdDisplay">
									ID:
									<%=eqp.getEqpID()%></p>
								<%-- <div class="status-badge" id="detailType"></div>--%>
								<span class="card-label">Total: </span><strong
									class="card-total"><%=eqp.getEqpQty()%></strong>
							</div>
						</div>
					</div>
					<div class="qty-summary-grid">
						<div class="qty-card card-available">
							<div class="card-content">
								<span class="card-label">Available</span> <strong
									class="card-number"><%=eqp.getTotQtyAvailable()%></strong>
							</div>
							<i class="bg-icon fa fa-check-circle"></i>
						</div>

						<div class="qty-card card-use">
							<div class="card-content">
								<span class="card-label">In Use</span> <strong
									class="card-number"><%=eqp.getTotQtyInUse()%></strong>
							</div>
							<i class="bg-icon fa fa-hand-holding"></i>
						</div>

						<div class="qty-card card-damaged">
							<div class="card-content">
								<span class="card-label">Damaged</span> <strong
									class="card-number"><%=eqp.getEqpTotDamage()%></strong>
							</div>
							<i class="bg-icon fa fa-heart-broken"></i>
						</div>

						<div class="qty-card card-lost">
							<div class="card-content">
								<span class="card-label">Lost</span> <strong class="card-number"><%=eqp.getEqpTotLost()%></strong>
							</div>
							<i class="bg-icon fa fa-search"></i>
						</div>
					</div>
				</div>

				<div class="record-section">
					<h3 class="section-subtitle">Damage and Lost Records</h3>
					<table class="table">
						<thead>
							<tr>
								<th>Coordinator Name</th>
								<th>Event Name</th>
								<th>Date</th>
								<th>Damaged</th>
								<th>Lost</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="record" items="${usageHistory}">
								<tr>
									<td><strong>${record.staffName}</strong></td>
									<td>${record.eventName}</td>
									<td>${record.eventDate}</td>
									<td><strong style="color: orange;">${record.qtyDamage}</strong>
									</td>
									<td><strong style="color: red;">${record.qtyLost}</strong>
									</td>
								</tr>
							</c:forEach>

							<c:if test="${empty usageHistory}">
								<tr>
									<td colspan="5"
										style="text-align: center; padding: 30px; color: #888;">
										<i class="fas fa-info-circle"></i> No damage or lost records
										found for this equipment.
									</td>
								</tr>
							</c:if>
						</tbody>
					</table>
				</div>
			</div>
		</main>
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
		function showLogoutModal() {
			document.getElementById("logoutModal").style.display = "flex";
		}

		function closeLogoutModal() {
			document.getElementById("logoutModal").style.display = "none";
		}
	</script>

</body>
</html>