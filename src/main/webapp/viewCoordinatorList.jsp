<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager Dashboard</title>

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
					
				</a> <a href="staffServlet?action=listCoordinators" class="nav-item active"> <img
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


		<!-- ================= HEADER ================= -->
		<div class="header">
			<div>
				<h2 class="welcome-text">Event Coordinator</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name">${sessionScope.staffName}</span> <span
						class="user-role">${sessionScope.staffRole}</span>
				</div>

				<a href="accountManager.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png">
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
							<h2 class="section-title">Coordinator List</h2>
							<p class="page-desc">Here is the list of all coordinators.</p>
						</div>
					</div>
						<table class="table">
							<colgroup>
								<col style="width: 18%">
								<col style="width: 22%">
								<col style="width: 18%">
								<col style="width: 18%">
								<col style="width: 24%">
							</colgroup>

							<thead>
								<tr>
									<th>ID</th>
									<th>Name</th>
									<th>Status</th>
									<th>Assignments</th>
									<th>Contact</th>
								</tr>
							</thead>

							<tbody>
								<c:forEach var="c" items="${coordinatorList}">
									<tr>
										<td><a
											href="staffServlet?action=viewCoordinator?staffID=${c.staffID}"
											class="id-link"> <strong>${c.staffID}</strong>
										</a></td>

										<td>${c.staffName}</td>

										<td><span
											class="status ${c.assignmentCount > 0 ? 'unavailable' : 'available'}">
												${c.assignmentCount > 0 ? 'Not Available' : 'Available'} </span></td>

										<td>${c.assignmentCount}</td>

										<td>${c.staffPhoneNum}</td>
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
