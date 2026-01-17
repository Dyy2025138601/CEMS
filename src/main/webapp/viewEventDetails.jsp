<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Event Details</title>

<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">
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
				</a> <a href="equipmentList.jsp" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
				</a> <a href="EventController?action=list" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="viewCoordinatorList.jsp" class="nav-item">
					<img src="icon/coordinator.png" class="nav-icon"> <span
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
				<h2 class="welcome-text">Event</h2>
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
		
				<div class="detail-header-stack">
                    <button class="back-link" onclick="window.location.href='EquipmentController?action=list'">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                </div>
                
				<div class="events-header">
					<div class="header-text">
						<h2 class="section-title">Event Details</h2>
						<p class="page-desc">Here are the details of the event.</p>
					</div>
				</div>

				<!-- EVENT INFO CARD -->
				<!-- Event Info Form Card -->
				<div class="event-details-card">
					<div class="event-details-row">
						<div class="event-field-inline">
							<label for="eventId">Event ID:</label> <input type="text"
								id="eventId" value="${event.eventID}"
								class="field-input highlight-readonly" readonly>
						</div>
						<div class="event-field-inline">
							<fmt:formatDate value="${event.eventDate}" pattern="dd-MM-yyyy"
								var="theFormattedDate" />
							<label for="eventDate">Event Date:</label> <input type="date"
								id="eventDate" value="${theFormattedDate}" class="field-input"
								readonly>
						</div>
						<div class="event-field-inline">
							<fmt:formatDate value="${event.eventTime}" pattern="hh:mm a"
								var="theFormmatedTime" />
							<label for="eventTime">Event Time:</label> <input type="text"
								id="eventTime" value="${theFormmatedTime}" class="field-input"
								readonly>
						</div>
					</div>

					<div class="event-details-row">
						<div class="event-field-inline">
							<label for="eventName">Event Name:</label> <input type="text"
								id="eventName" value="${event.eventName}" class="field-input"
								readonly>
						</div>
						<div class="event-field-inline">
							<label for="venue">Venue:</label> <input type="text" id="venue"
								value="${event.eventVenue}" class="field-input" readonly>
						</div>
						<div class="event-field-inline">
							<label for="pax">No of Pax:</label> <input type="number" id="pax"
								value="${event.eventPax}" class="field-input" readonly>
						</div>
					</div>
				</div>

				<!-- PACKAGE SECTION -->
				<div class="package-wrapper" id="packageSection">
					<!-- ROW 1 -->
					<div class="package-header-row">
						<!-- LEFT -->
						<h3>
							Package Selected : <span class="orange-text" id="packageName">${event.packName}</span>
						</h3>
						<div class="assign-coordinator">
							<label for="coordinator">Assign Coordinator :</label> <span class="orange-text" id="staffName">${event.staffName}</span>
						</div>
					</div>
				</div>
				<!-- EQUIPMENT TABLE -->
				<div class="events-section">
					<div class="events-header">
						<p class="page-desc">Equipment Included</p>
					</div>
					<table class="table">
						<thead>
							<tr>
								<th>Equipment ID</th>
								<th>Equipment Name</th>
								<th>Quantity In Use</th>
								<th>Serving Set</th>
								<th>Function</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="item" items="${equipmentList}">
								<tr>
									<td><strong>${item.eqpID}</strong></td>
									<td>${item.eqpName}</td>
									<td>${item.totQtyInUse}</td>
									<td>${item.serviceSet}</td>
									<td>${item.eqpFunction}</td>
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