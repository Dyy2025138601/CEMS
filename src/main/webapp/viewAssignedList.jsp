<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ page import="cems.staffBean"%>
<%
staffBean staff = (staffBean) session.getAttribute("staff");

// Check if logged in AND if the role is correct
if (staff == null || !"COORDINATOR".equalsIgnoreCase(staff.getStaffRole())) {
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
<title>Coordinator Dashboard - Event List</title>

<link rel="stylesheet" href="style.css">

<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap')
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
		<!-- ================= SIDEBAR ================= -->
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="EventController?action=dashboardCoordinator" class="nav-item"> <img
					src="icon/dashboard.png" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="EventController?action=listCoordinatorEvents" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
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
			<div>
				<h2 class="welcome-text">Dashboard</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name"><%=staff.getStaffName()%></span> <span
						class="user-role"><%=staff.getStaffRole()%></span>
				</div>
				<a href="accountCoord.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png"
						alt="profile_image">
				</span>
				</a>
			</div>
		</div>

		<!-- ================= MAIN CONTENT ================= -->
		<main class="main">
			<div class="content-box">
				<div class="events-section">
					<div class="events-header">
						<div class="header-text">
							<h2 class="section-title">Assigned Events</h2>
							<p class="page-desc">Below are the list of events you are
								responsible for.</p>
						</div>
					</div>

					<table class="table">
						<thead>
							<tr>
								<th>ID</th>
								<th>Date &amp; Time</th>
								<th>Venue</th>
								<th>Package</th>
								<th>Status</th>
							</tr>
						</thead>

						<tbody>
							<c:choose>
								<c:when test="${empty eventList}">
									<tr>
										<td colspan="5" style="text-align: center;">No events
											assigned to you.</td>
									</tr>
								</c:when>

								<c:otherwise>
									<c:forEach var="event" items="${eventList}">
										<tr data-status="${event.eventStatus}">
											<td><a
												href="EventController?action=viewCoordinatorEvent&eventID=${event.eventID}"
												class="id-link"> <strong>${event.eventID}</strong>
											</a></td>

											<td><fmt:formatDate value="${event.eventDate}"
													pattern="dd-MM-yyyy" /> <br> <fmt:formatDate
													value="${event.eventTime}" pattern="hh:mm a" /></td>

											<td>${event.eventVenue}</td>

											<td>${event.packName}</td>

											<td
											class="status ${event.eventStatus == 'Completed' ? 'completed' : 'in-progress'}">
											${event.eventStatus}</td>
										</tr>
									</c:forEach>
								</c:otherwise>

							</c:choose>
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
	<!-- ================= OPTIONAL JS ================= -->
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
