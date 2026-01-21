<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ page import="cems.staffBean"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.EventEquipment"%>
<%
staffBean staff = (staffBean) session.getAttribute("staff");

// Sekarang kita benarkan COORDINATOR masuk. 
// Jika bukan Coordinator, baru kita tendang.
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
<title>Event Details</title>

<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="style.css">
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
response.setHeader("Pragma", "no-cache"); // HTTP 1.0
response.setDateHeader("Expires", 0); // Proxies
%>
</head>
<body>
	<div class="layout">
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="EventController?action=dashboardCoordinator" class="nav-item"> <img
					src="icon/dashboard.png" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="EventController?action=listCoordinatorEvents"
					class="nav-item active"> <img src="icon/event.png"
					class="nav-icon"> <span class="link-text">Event</span>
				</a>
			</nav>

			<div class="logout-section">
				<a href="javascript:void(0)" onclick="showLogoutModal()"
					class="nav-icon-logout"> <img src="icon/logout.png"> <span
					class="link-text">Log Out</span>
				</a>
			</div>
		</div>

		<div class="header">
			<h2 class="welcome-text">Assigned Event</h2>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name"><%=staff.getStaffName()%></span> <span
						class="user-role"><%=staff.getStaffRole()%></span>
				</div>

				<a href="accountCoord.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png">
				</span>
				</a>
			</div>
		</div>

		<main class="main">
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='EventController?action=listCoordinatorEvents'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>

				<div class="events-header">
					<div class="header-text">
						<h2 class="section-title">Event Details</h2>
						<p class="page-desc">Here are the details of the event.</p>
					</div>

					<div class="action-group">
						<c:choose>
							<%-- If status is Completed, show a disabled button --%>
							<c:when test="${event.eventStatus eq 'Completed'}">
								<button class="add-btn btn-disabled" disabled>
									<i class="fas fa-check-circle"></i> Returned
								</button>
							</c:when>

							<%-- Otherwise, show the active link --%>
							<c:otherwise>
								<a
									href="EventController?action=viewReturnForm&eventID=${event.eventID}"
									class="add-btn"> <i class="fas fa-box-open"></i> Return
									Equipment
								</a>
							</c:otherwise>
						</c:choose>
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
							<fmt:formatDate value="${event.eventDate}" pattern="yyyy-MM-dd"
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
							<label for="coordinator">Assign Coordinator :</label> <span
								class="orange-text" id="staffName">${event.staffName}</span>
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
								<th>ID</th>
								<th>Name</th>
								<th>Type</th>
								<th>Category</th>
								<th>Quantity Use</th>
							</tr>
						</thead>
						<tbody>
							<c:choose>
								<c:when test="${not empty equipmentList}">
									<c:forEach var="item" items="${equipmentList}">
										<tr class="equipment-row">
											<td><strong>${item.eqpID}</strong></td>
											<td>${item.eqpName}</td>

											<%-- Tentukan Type: Jika serviceSet ada isi, maka Service --%>
											<td><c:choose>
													<c:when
														test="${not empty item.serviceSet && item.serviceSet != '-'}">
                                Service
                            </c:when>
													<c:otherwise>Support</c:otherwise>
												</c:choose></td>

											<%-- Tentukan Category --%>
											<td><c:choose>
													<c:when
														test="${not empty item.serviceSet && item.serviceSet != '-'}">
                                ${item.serviceSet}
                            </c:when>
													<c:otherwise>${item.eqpFunction}</c:otherwise>
												</c:choose></td>

											<td>${item.qtyInUse}</td>
										</tr>
									</c:forEach>
								</c:when>
								<c:otherwise>
									<tr>
										<td colspan="5" style="text-align: center;">No equipment
											found for this event.</td>
									</tr>
								</c:otherwise>
							</c:choose>
						</tbody>
					</table>
					<div class="table-actions">
						<button type="button" class="print-btn" onclick="window.print()">
							<i class="fas fa-print"></i> Print
						</button>
					</div>
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