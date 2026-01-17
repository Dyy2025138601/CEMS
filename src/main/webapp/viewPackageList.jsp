<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Package</title>
<link rel="stylesheet" href="farah1.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap')
	;
</style>
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
				</a> <a href="equipmentList.jsp" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
				</a> <a href="viewEventList.jsp" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item active">
					<img src="icon/package.png" class="nav-icon"> <span
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
				<h2 class="welcome-text">Package</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name">Hawa Aqiera</span> <span class="user-role">Manager</span>
				</div>

				<a href="accountManager.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png"
						alt="profile_image">
				</span>
				</a>
			</div>
		</div>

		<!-- main content page -->
		<main class="main">
			<div class="content-box">

				<!-- table -->
				<div class="events-section">
					<div class="events-header">
						<div class="header-text">
							<h2 class="section-title">Package List</h2>
							<p class="page-desc">Here is the list of all packages.</p>
						</div>
					</div>
					
					<table class="table">
						<colgroup>
							<col style="width: 18%">
							<col style="width: 22%">
							<col style="width: 18%">
							<col style="width: 18%">
						</colgroup>
						<thead>
							<tr>
								<th>ID</th>
								<th>Name</th>
								<th>Pax</th>
								<th>Availability</th>
							</tr>
						</thead>
						<tbody class="body-row">
							<c:forEach items="${packages}" var="packageCatering">
								<tr>
									<td><a class="id-link"
										href="PackageController?action=view&packID=${packageCatering.packID}">
											<strong>${packageCatering.packID}</strong>
									</a></td>
									<td>${packageCatering.packName}</td>
									<td>${packageCatering.lowPackPax}-
										${packageCatering.highPackPax}</td>
									<td class="status available">${packageCatering.packAvailability}</td>
								</tr>
							</c:forEach>
						</tbody>
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