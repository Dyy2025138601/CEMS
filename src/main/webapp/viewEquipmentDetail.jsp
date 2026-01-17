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
<title>Equipment Details</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="farah1.css">
</head>
<body>
	<div class="layout">
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="dashboardManager.jsp" class="nav-item"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="EquipmentController?action=list" class="nav-item active">
					<img src="icon/eqp.png" class="nav-icon"> <span
					class="link-text">Equipment</span>
				</a> <a href="viewEventList.jsp" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="viewCoordinatorList.jsp" class="nav-item"> <img
					src="icon/coordinator.png" class="nav-icon"> <span
					class="link-text">Coordinator</span>
				</a> <a href="viewReportList.jsp" class="nav-item"> <img
					src="icon/report.png" class="nav-icon"> <span
					class="link-text">Report</span>
				</a>
			</nav>

			<div class="logout-section">
				<a href="logout.jsp" class="nav-icon-logout"> <img
					src="icon/logout.png"> <span class="link-text">Log Out</span>
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
								<strong><span>Total: </span><%=eqp.getEqpTotQty()%></strong>
							</div>
						</div>
					</div>
					<div class="qty-summary-grid">
						<div class="qty-card">
							<div class="qty-info">
								<span>Available</span> <i
									class="fas fa-boxes-stacked icon-available"></i>
							</div>
							<strong class="qty-number text-success"><%=eqp.getTotQtyAvailable()%></strong>
						</div>
						<div class="qty-card">
							<div class="qty-info">
								<span>In Use</span> <i class="fas fa-hand-holding icon-inuse"></i>
							</div>
							<strong class="qty-number"><%=eqp.getTotQtyInUse()%></strong>
						</div>

						<div class="qty-card">
							<div class="qty-info">
								<span>Damaged</span> <i class="fas fa-house-damage icon-damaged"></i>
							</div>
							<strong class="qty-number text-damaged"><%=eqp.getEqpTotDamage()%></strong>
						</div>

						<div class="qty-card">
							<div class="qty-info">
								<span>Lost</span> <i class="fas fa-search-minus icon-lost"></i>
							</div>
							<strong class="qty-number text-lost"><%=eqp.getEqpTotLost()%></strong>
						</div>
					</div>

					<div class="record-section">
						<h3 class="section-subtitle">Damage and Lost Records</h3>
						<table class="table">
							<thead>
								<tr>
									<th>Coordinator</th>
									<th>Event Name</th>
									<th>Date &amp; Time</th>
									<th>Damaged</th>
									<th>Lost</th>
								</tr>
							</thead>
							<!--<tbody>
                            <tr>
                                <td>Amirul Hakim</td>
                                <td>Wedding Dinner A</td>
                                <td>24-05-2025 | 08:00 PM</td>
                                <td><strong style="color: #ff8c00;">3</strong></td>
                                <td><strong style="color: #ff4d4d;">1</strong></td>
                            </tr>
                        </tbody>  -->
						</table>
					</div>
				</div>
		</main>
	</div>

	<script>
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
	</script>

</body>
</html>