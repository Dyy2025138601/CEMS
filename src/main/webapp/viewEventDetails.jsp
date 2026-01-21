<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="cems.staffBean"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.EventEquipment"%>
<%@ page import="cems.EventBean"%>

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
				<a href="EventController?action=dashboard" class="nav-item"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>
					
				</a> <a href="EquipmentController?action=list" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
					
				</a> <a href="EventController?action=list" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
					
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
					
				</a> <a href="staffServlet?action=listCoordinators" class="nav-item"> <img
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

		<div class="header">
			<div>
				<h2 class="welcome-text">Event</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name"><%=staff.getStaffName()%></span> <span
						class="user-role"><%=staff.getStaffRole()%></span>
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
                    <button class="back-link" onclick="window.location.href='EventController?action=list'">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                </div>
                
				<div class="events-header">
					<div class="header-text">
						<h2 class="section-title">Event Details</h2>
						<p class="page-desc">Here are the details of the event.</p>
					</div>
				</div>

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

				<div class="package-wrapper" id="packageSection">
					<div class="package-header-row">
						<h3>
							Package Selected : <span class="orange-text" id="packageName">${event.packName}</span>
						</h3>
						<div class="assign-coordinator">
							<label for="coordinator">Assign Coordinator :</label> <span class="orange-text" id="staffName">${event.staffName}</span>
						</div>
					</div>
				</div>
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
								<th>Quantity In Use</th>
							</tr>
						</thead>
						<tbody class="body-row">
<%
    List<EventBean> myEqpList = (List<EventBean>) request.getAttribute("equipmentList");

    if (myEqpList != null && !myEqpList.isEmpty()) {
        for (EventBean eqp : myEqpList) {
            
            boolean isService = false;
            String typeLabel = "Support";
            String cssClass = "support";
            String categoryDisplay = eqp.getEqpFunction();

            if (eqp.getServiceSet() != null && !eqp.getServiceSet().isEmpty() && !eqp.getServiceSet().equals("-")) {
                isService = true;
                typeLabel = "Service";
                cssClass = "service";
                categoryDisplay = eqp.getServiceSet();
            }
%>
    <tr>
        <td>
            <strong><%= eqp.getEqpID() %>
            <input type="hidden" name="eqpID" value="<%= eqp.getEqpID() %>">
            </strong>
        </td>
        <td><%= eqp.getEqpName() %></td>
        <td>
            <span class="dot <%= cssClass %>"></span> <%= typeLabel %>
        </td>
        <td style="text-transform: capitalize;">
            <%= (categoryDisplay != null) ? categoryDisplay : "-" %>
        </td>
        <td>
            <%= eqp.getTotQtyInUse() %>
        </td>
    </tr>
<%
        } 
    } else {
%>
    <tr>
        <td colspan="5" style="text-align: center;">No equipment found for this event.</td>
    </tr>
<%
    } 
%>
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

<div id="deleteModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
        <div class="modal-icon-container" style="font-size: 50px; color: #dc3545; margin-bottom: 20px;">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h3>Delete Event?</h3>
        <p class="modal-text" style="color: white; margin-bottom: 30px;">
            Are you sure you want to delete this event?<br>
            This action cannot be undone.
        </p>
        <div class="modal-buttons" style="display: flex; justify-content: center; gap: 15px;">
            <button class="btn-cancel" onclick="closeDeleteModal()" 
                style="padding: 10px 30px; border-radius: 50px; border: none; font-weight: 600; cursor: pointer;">
                Cancel
            </button>
            
            <a href="EventController?action=delete&eventID=${event.eventID}" style="text-decoration: none;">
                <button style="background: #dc3545; color: white; padding: 10px 30px; border-radius: 50px; border: none; font-weight: 600; cursor: pointer;">
                    Confirm Delete
                </button>
            </a>
        </div>
    </div>
</div>

	<script>
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
		
		// Logout Modal Logic
		function showLogoutModal() {
		    document.getElementById("logoutModal").style.display = "flex";
		}
		function closeLogoutModal() {
		    document.getElementById("logoutModal").style.display = "none";
		}
		
		// ADDED: Delete Modal Logic
		function openDeleteModal() {
	        document.getElementById("deleteModal").style.display = "flex";
	    }
	    function closeDeleteModal() {
	        document.getElementById("deleteModal").style.display = "none";
	    }
	</script>

</body>
</html>