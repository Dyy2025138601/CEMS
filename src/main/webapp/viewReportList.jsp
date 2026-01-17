<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Report List</title>
<link rel="stylesheet" href="farah1.css">
<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"
	rel="stylesheet">
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
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="viewCoordinatorList.jsp" class="nav-item"> <img
					src="icon/coordinator.png" class="nav-icon"> <span
					class="link-text">Coordinator</span>
				</a> <a href="viewReportList.jsp" class="nav-item active"> <img
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
				<h2 class="welcome-text">Report</h2>
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

		<main class="main">
			<div class="content-box">
				<div class="events-section">
					<div class="events-header">
						<div class="header-text">
							<h2 class="section-title">Report List</h2>
							<p class="page-desc">Here is the list of all generated reports.</p>
						</div>

						<div class="action-group">
							<button class="generate-btn"
								onclick="document.location='generateReport.jsp'">
								<span>+</span> Generate Report
							</button>
						</div>
					</div>
					<table class="table">
						<colgroup>
							<col style="width: 15%">
							<col style="width: 25%">
							<col style="width: 30%">
							<col style="width: 30%">
						</colgroup>
						<thead>
							<tr>
								<th>Report ID</th>
								<th>Type</th>
								<th>Date Range</th>
								<th>Date Generated</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"> <strong>R001</strong>
								</a></td>
								<td>Event Report</td>
								<td>22 May - 29 May 2025</td>
								<td>30 May 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R002"
									class="id-link"><strong>R002</strong></a></td>
								<td>Event Report</td>
								<td>21 May 2025</td>
								<td>27 May 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"><strong>Q001</strong></a></td>
								<td>Equipment Report</td>
								<td>15 June - 21 June 2025</td>
								<td>22 June 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"><strong>Q001</strong></a></td>
								<td>Equipment Report</td>
								<td>15 June - 21 June 2025</td>
								<td>22 June 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"><strong>Q001</strong></a></td>
								<td>Equipment Report</td>
								<td>15 June - 21 June 2025</td>
								<td>22 June 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"><strong>Q001</strong></a></td>
								<td>Equipment Report</td>
								<td>15 June - 21 June 2025</td>
								<td>22 June 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"><strong>Q001</strong></a></td>
								<td>Equipment Report</td>
								<td>15 June - 21 June 2025</td>
								<td>22 June 2025</td>
							</tr>
							<tr>
								<td><a href="viewReportList.jsp?packID=R001"
									class="id-link"><strong>Q001</strong></a></td>
								<td>Equipment Report</td>
								<td>15 June - 21 June 2025</td>
								<td>22 June 2025</td>
							</tr>
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