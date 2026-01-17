<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

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
				<a href="dashboardCoordinator.jsp" class="nav-item"> <img
					src="icon/dashboard.png" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="viewAssignedList.jsp" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a>
			</nav>

			<div class="logout-section">
				<a href="logout.jsp" class="nav-icon-logout"> <img
					src="icon/logout.png"> <span class="link-text">Log Out</span>
				</a>
			</div>
		</div>

		<div class="header">
			<h2 class="welcome-text">Assigned Event</h2>

			<div class="user-profile">
				<div class="user-info">
                    <span class="user-name">Farhan Mazlan</span>
                    <span class="user-role">Event Coordinator</span>
                </div>

				<a href="account.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png">
				</span>
				</a>
			</div>
		</div>

		<main class="main">
			<div class="content-box">

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
								id="eventId" value="E001" class="field-input highlight-readonly"
								readonly>
						</div>
						<div class="event-field-inline">
							<label for="eventTime">Event Time:</label> <input type="text"
								id="eventTime" value="12.00 PM" class="field-input" readonly>
						</div>
						<div class="event-field-inline">
							<label for="venue">Venue:</label> <input type="text" id="venue"
								value="Venue B" class="field-input" readonly>
						</div>
					</div>

					<div class="event-details-row">
						<div class="event-field-inline">
							<label for="eventName">Event Name:</label> <input type="text"
								id="eventName" value="Wedding" class="field-input" readonly>
						</div>
						<div class="event-field-inline">
							<label for="eventDate">Event Date:</label> <input type="date"
								id="eventDate" value="2025-06-27" class="field-input" readonly>
						</div>
						<div class="event-field-inline">
							<label for="pax">No of Pax:</label> <input type="number" id="pax"
								value="100" class="field-input" readonly>
						</div>
					</div>
				</div>

				<!-- PACKAGE SECTION -->
				<div class="package-wrapper" id="packageSection">

					<!-- ROW 1 -->
					<div class="package-header-row">
						<!-- LEFT -->
						<h3>
							Package Selected : <span class="orange-text" id="packageName">Package
								A</span>
						</h3>
					</div>
				</div>

				<div class="events-section">
					<div class="events-header">
						<h1 class="section-title">Equipment Included</h1>
						<button class="return-btn"
							onclick="document.location='returnEquipment.jsp'">Return
							Equipment</button>
					</div>

					<!-- EQUIPMENT TABLE -->
					<table class="equipment-table">
						<thead>
							<tr>
								<th>Equipment ID</th>
								<th>Equipment Name</th>
								<th>Quantity</th>
								<th>Category</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td>S001</td>
								<td>Buffet Tray</td>
								<td>20</td>
								<td>Service</td>
							</tr>
							<tr>
								<td>S002</td>
								<td>Water Dispenser</td>
								<td>2</td>
								<td>Service</td>
							</tr>
							<tr>
								<td>D003</td>
								<td>Glass</td>
								<td>100</td>
								<td>Service</td>
							</tr>
							<tr>
								<td>D002</td>
								<td>Plate</td>
								<td>100</td>
								<td>Service</td>
							</tr>
							<tr>
								<td>P003</td>
								<td>Sink</td>
								<td>2</td>
								<td>Support</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</main>
	</div>

	<script>
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
	</script>
</body>
</html>