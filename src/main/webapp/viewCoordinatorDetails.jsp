<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="cems.staffBean"%>
<%@ page import="cems.EventEquipment"%>
<%@ page import="cems.EventBean"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
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
<title>Coordinator Details</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet" href="style.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
response.setHeader("Pragma", "no-cache"); // HTTP 1.0
response.setDateHeader("Expires", 0); // Proxies
%>
</head>

<body>
	<div class="layout">

		<!-- ================= SIDEBAR ================= -->
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

				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>

				</a> <a href="staffServlet?action=listCoordinators"
					class="nav-item active"> <img src="icon/coordinator.png"
					class="nav-icon"> <span class="link-text">Coordinator</span>
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


		<!-- ================= HEADER ================= -->
		<div class="header">
			<h2 class="welcome-text">Coordinator</h2>

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
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='staffServlet?action=listCoordinators'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>
				<div class="events-header">
					<div class="header-text">
						<h1 class="section-title">Coordinator Details &amp; Activity
							Report</h1>
						<p class="page-desc">
							Viewing event history and equipment accountability for <strong>${coordinator.staffName}</strong>.
						</p>
					</div>
				</div>

				<div class="coordinator-details-wrapper">
					<div class="coor-details-left">
						<div class="qty-card-coor card-profile">
							<div class="card-content">
								<h3 class="card-label">Staff Profile</h3>
								<p>
									<strong>ID:</strong> ${coordinator.staffID}
								</p>
								<p>
									<strong>Phone:</strong> ${coordinator.staffPhoneNum}
								</p>
								<p>
									<strong>Email:</strong> ${coordinator.staffEmail}
								</p>
							</div>
							<i class="bg-icon fa fa-user"></i>
						</div>

						<div class="qty-card-coor card-damaged">
							<div class="card-content">
								<span class="card-label">Total Damaged</span> <strong
									class="card-number">${damageCount}</strong>
							</div>
							<i class="bg-icon fa fa-heart-broken"></i>
						</div>

						<div class="qty-card-coor card-lost">
							<div class="card-content">
								<span class="card-label">Total Lost</span> <strong
									class="card-number">${lostCount}</strong>
							</div>
							<i class="bg-icon fa fa-search"></i>
						</div>

					</div>
				</div>
				<h3 class="section-subtitle">Event &amp; Equipment
					Accountability Log</h3>

				<div class="table-scroll-container">
					<table class="table">
						<thead>
							<tr>
								<th>Event ID</th>
								<th>Event Date</th>
								<th>Event Status</th>
								<th>Equipment Issues</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="event" items="${eventList}">
								<tr>
									<td class="id-link"><strong>${event.eventID}</strong></td>
									<td><span> ${event.eventDate}</span></td>
									<td
										class="status ${event.eventStatus == 'Completed' ? 'completed' : 'in-progress'}">
										${event.eventStatus}</td>
									<td><c:set var="hasIssue" value="false" />
										<div class="issue-inner-list">
											<c:forEach var="issue" items="${equipmentIssues}">
												<c:if test="${issue.eventID eq event.eventID}">
													<c:set var="hasIssue" value="true" />
													<div
														style="margin-bottom: 5px; padding: 5px; background: #fff5f5; border-radius: 4px; border-left: 3px solid red;">
														<strong>${issue.eqpName}</strong>:
														<c:if test="${issue.qtyLost > 0}">
															<span style="color: red;">Lost (${issue.qtyLost})</span>
														</c:if>
														<c:if test="${issue.qtyDamage > 0}">
															<span style="color: orange;">Damaged
																(${issue.qtyDamage})</span>
														</c:if>
													</div>
												</c:if>
											</c:forEach>

											<c:if test="${!hasIssue}">
												<span class="issue-message">&check; No issues
													reported</span>
											</c:if>
										</div></td>
								</tr>
							</c:forEach>
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

	<!-- ================= SCRIPT ================= -->
	<script>
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