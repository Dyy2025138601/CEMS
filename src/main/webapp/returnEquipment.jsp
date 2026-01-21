<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="cems.staffBean"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.EventEquipment"%>
<%
staffBean staff = (staffBean) session.getAttribute("staff");

// Check if logged in AND if the role is correct
if (staff == null || !"COORDINATOR".equalsIgnoreCase(staff.getStaffRole())) {
	// If they aren't a manager, force them out
	session.invalidate();
	response.sendRedirect("login.jsp?error=unauthorized");
	return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Return Equipment Form</title>
<link rel="stylesheet" href="style.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap')
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
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="EventController?action=dashboardCoordinator" class="nav-item "> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
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
			<div>
				<h2 class="welcome-text">Return Equipment</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name"><%=staff.getStaffName()%></span> <span
						class="user-role"><%=staff.getStaffRole()%></span>
				</div>

				<a href="accountCoordinator.jsp" class="profile-link"> <span
					class="profile-pic-default"> <img src="icon/user.png"
						alt="profile_image">
				</span>
				</a>
			</div>
		</div>

		<!-- main content page -->
		<main class="main">
			<div class="content-box">
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='EventController?action=CoordinatorEvent'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>

				<div class="events-section">

					<form action="EventController" method="post">
						<input type="hidden" name="action" value="returnEquipment">
						<input type="hidden" name="eventID" value="${eventID}">

						<div class="events-header">
							<div class="header-text">
								<h1 class="section-title">Equipment Return Form</h1>
								<p class="page-desc">
									Event ID: <strong>${eventID}</strong>
								</p>
							</div>
						</div>

						<table class="table">
							<colgroup>
								<col style="width: 8%">
								<col style="width: 13%">
								<col style="width: 10%">
								<col style="width: 10%">
								<col style="width: 10%">
								<col style="width: 14%">
								<col style="width: 10%">
								<col style="width: 10%">
							</colgroup>
							<thead>
								<tr>
									<th>ID</th>
									<th>Name</th>
									<th>Type</th>
									<th>Category</th>
									<th>Quantity Use</th>
									<th>Quantity Return</th>
									<th>Damaged</th>
									<th>Lost</th>
								</tr>
							</thead>
							<tbody>
								<%
								List<EventEquipment> myEqpList = (List<EventEquipment>) request.getAttribute("equipmentList");

								if (myEqpList != null && !myEqpList.isEmpty()) {
									for (EventEquipment eqp : myEqpList) {
										// Logic Type & Category
										String type = "Support";
										String category = eqp.getEqpFunction();

										if (eqp.getServiceSet() != null && !eqp.getServiceSet().equals("-") && !eqp.getServiceSet().isEmpty()) {
									type = "Service";
									category = eqp.getServiceSet();
										}
								%>
								<tr class="equipment-row">
									<td><input type="hidden" name="eqpID"
										value="<%=eqp.getEqpID()%>"> <input type="hidden"
										name="qtyInUse" value="<%=eqp.getQtyInUse()%>"> <strong><%=eqp.getEqpID()%></strong>
									</td>
									<td><%=eqp.getEqpName()%></td>
									<td><%=type%></td>
									<td><%=category%></td>
									<td style="font-weight: bold; color: #2c3e50;"><%=eqp.getQtyInUse()%></td>

									<%-- INPUT QUANTITY RETURN (Dikosongkan jika 0) --%>
									<td><input type="number" name="qtyReturn"
										value="<%=(eqp.getQtyReturn() <= 0) ? "" : eqp.getQtyReturn()%>"
										min="0" max="<%=eqp.getQtyInUse()%>" placeholder="0"
										class="quantity-input sm" required /></td>

									<%-- INPUT DAMAGED (Dikosongkan jika 0) --%>
									<td><input type="number" name="qtyDamage"
										value="<%=(eqp.getQtyDamage() <= 0) ? "" : eqp.getQtyDamage()%>"
										min="0" placeholder="0" class="quantity-input sm" /></td>

									<%-- INPUT LOST (Dikosongkan jika 0) --%>
									<td><input type="number" name="qtyLost"
										value="<%=(eqp.getQtyLost() <= 0) ? "" : eqp.getQtyLost()%>"
										min="0" placeholder="0" class="quantity-input sm" /></td>
								</tr>
								<%
								}
								} else {
								%>
								<tr>
									<td colspan="8" style="text-align: center;">No equipment
										found for this event.</td>
								</tr>
								<%
								}
								%>
							</tbody>
						</table>

						<div class="table-actions">
							<button type="button" class="btn reset-btn">Reset</button>

							<button type="submit" class="btn submit-btn">Submit</button>
						</div>
					</form>
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
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}

		function disableSubmit(msg) {
			const submitBtn = document.querySelector(".submit-btn");
			submitBtn.disabled = true;
			submitBtn.style.backgroundColor = "#ccc";
			if (msg) {
				hint.innerHTML = msg;
				hint.style.display = "block";
				hint.style.color = "red";
			}
		}

		function enableSubmit() {
			const submitBtn = document.querySelector(".submit-btn");
			submitBtn.disabled = false;
			submitBtn.style.backgroundColor = "";
			hint.style.display = "none";
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