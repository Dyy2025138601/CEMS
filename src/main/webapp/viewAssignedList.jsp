<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Coordinator Dashboard - Event List</title>

<link rel="stylesheet" href="farah1.css">

<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap')
	;
</style>
</head>

<body>
	<div class="layout">
		<!-- ================= SIDEBAR ================= -->
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

		<!-- ================= HEADER ================= -->
		<div class="header">
			<div>
				<h2 class="welcome-text">Dashboard</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
                    <span class="user-name">Farhan Mazlan</span>
                    <span class="user-role">Event Coordinator</span>
                </div>
				<a href="accountCoordinator.jsp" class="profile-link"> <span
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

					<table class="event-table">
						<thead>
							<tr>
								<th>Event ID</th>
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
										<tr data-status="${event.status}">
											<td><a
												href="ViewEventDetails.jsp?eventId=${event.eventId}"
												class="event-id-link"> <strong>${event.eventId}</strong>
											</a></td>

											<td><fmt:formatDate value="${event.eventDate}"
													pattern="dd-MM-yyyy" /> <br> <fmt:formatDate
													value="${event.eventTime}" pattern="hh:mm a" /></td>

											<td>${event.venue}</td>

											<td>${event.packageName}</td>

											<td
												class="status
                                            <c:choose>
                                                <c:when test="${event.status == 'Completed'}">completed</c:when>
                                                <c:otherwise>in-progress</c:otherwise>
                                            </c:choose>
                                        ">
												${event.status}</td>
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

	<!-- ================= OPTIONAL JS ================= -->
	<script>
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
	</script>

</body>
</html>
