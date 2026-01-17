<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Coordinator Details</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- CSS -->
<link rel="stylesheet" href="ecList.css">

<!-- Google Font -->
<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"
	rel="stylesheet">
</head>

<body>
	<div class="layout">

		<!-- ================= SIDEBAR ================= -->
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="dashboardManager.jsp" class="nav-item"> <img
					src="icon/dashboard.png" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="equipmentList.jsp" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
				</a> <a href="viewEventList.jsp" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="ECController?action=list" class="nav-item"> <img
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


		<!-- ================= HEADER ================= -->
		<div class="header">
			<h2 class="welcome-text">Dashboard</h2>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name">${sessionScope.staffName}</span> <span
						class="user-role">${sessionScope.staffRole}</span>
				</div>

				<a href="account.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png">
				</span>
				</a>
			</div>
		</div>


		<!-- ================= MAIN CONTENT ================= -->
		<main class="main-content">
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='EquipmentController?action=list'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>

				<h2 class="section-title">Coordinator Details</h2>
				<p class="page-desc">Here are the details of the coordinator</p>

				<div class="coordinator-details-wrapper">

					<!-- LEFT COLUMN -->
					<div class="left-column">

						<!-- Staff Card -->
						<div class="event-details-card">
							<p>
								<strong>Staff ID:</strong> <span class="orange-text">${staff.staffID}</span>
							</p>
							<br>

							<p>
								<strong>Staff Name:</strong> ${staff.staffName}
							</p>
							<br>
							<p>
								<strong>Phone Number:</strong> ${staff.staffPhoneNum}
							</p>
							<br>
							<p>
								<strong>Staff Email:</strong> ${staff.staffEmail}
							</p>
						</div>

						<!-- Equipment Status -->
						<div class="event-details-card">
							<h3 class="orange-text">Equipment Status for This Month</h3>
							<ul style="margin-top: 15px; padding-left: 20px;">
								<li><strong>Damage:</strong> ${damageCount}</li>
								<li><strong>Lost:</strong> ${lostCount}</li>
							</ul>
						</div>

					</div>


					<!-- RIGHT COLUMN -->
					<div class="right-column event-details-card">

						<h3 class="orange-text" style="margin-bottom: 15px;">Total
							Assigned Events : ${totalEvents}</h3>

						<div class="table-scroll-container">

							<table class="event-table">
								<thead>
									<tr>
										<th>Event ID</th>
										<th>Date</th>
										<th>Status</th>
									</tr>
								</thead>

								<tbody>
									<c:forEach var="event" items="${eventList}">
										<tr>
											<td><strong>${event.eventID}</strong></td>
											<td>${event.eventDate} <br> ${event.eventTime}
											</td>
											<td><span
												class="status ${event.eventStatus eq 'Completed' ? 'completed' : 'pending'}">
													${event.eventStatus} </span></td>
										</tr>
									</c:forEach>
								</tbody>
							</table>

						</div>
					</div>

				</div>
			</div>
		</main>
	</div>


	<!-- ================= SCRIPT ================= -->
	<script>
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
	</script>

</body>
</html>
