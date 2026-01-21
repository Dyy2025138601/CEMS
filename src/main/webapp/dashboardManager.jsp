<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ page import="cems.staffBean"%>
<%@ page import="cems.Equipment"%>
<%
staffBean staff = (staffBean) session.getAttribute("staff");

// Check if logged in AND if the role is correct
if (staff == null || !"MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
	session.invalidate();
	response.sendRedirect("login.jsp?error=unauthorized");
	return;
}
%>
<%
// Retrieve statistics and data from request attributes
int pendingCount = (request.getAttribute("pendingCount") != null) ? (Integer) request.getAttribute("pendingCount") : 0;
int eventCount = (request.getAttribute("eventCount") != null) ? (Integer) request.getAttribute("eventCount") : 0;
int eqpCount = (request.getAttribute("eqpCount") != null) ? (Integer) request.getAttribute("eqpCount") : 0;

String evChartData = (String) request.getAttribute("evChartData");

String returnRate = (String) request.getAttribute("returnRate");
String eventGrowth = (String) request.getAttribute("eventGrowth");
String lossRate = (String) request.getAttribute("lossRate");

// Default values if null
if (returnRate == null)
	returnRate = "0.0";
if (eventGrowth == null)
	eventGrowth = "0.0";
if (lossRate == null)
	lossRate = "0.0";

if (evChartData == null)
	evChartData = "0,0,0";
%>
<%
String chartLabels = (String) request.getAttribute("chartLabels");
String chartGood = (String) request.getAttribute("chartGood");
String chartDamaged = (String) request.getAttribute("chartDamaged");
String chartLost = (String) request.getAttribute("chartLost");

// Defaults to prevent JS errors if DB is empty
if (chartLabels == null)
	chartLabels = "'No Data'";
if (chartGood == null)
	chartGood = "0";
if (chartDamaged == null)
	chartDamaged = "0";
if (chartLost == null)
	chartLost = "0";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard Manager</title>
<link rel="stylesheet" href="style.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap')
	;
</style>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
response.setHeader("Pragma", "no-cache"); // HTTP 1.0
response.setDateHeader("Expires", 0); // Proxies
%>
</head>
</head>
<body>
	<div class="layout">
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="EventController?action=dashboard" class="nav-item active">
					<img src="icon/dashboard.png" alt="Dashboard" class="nav-icon">
					<span class="link-text">Dashboard</span>

				</a> <a href="EquipmentController?action=list" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>

				</a> <a href="EventController?action=list" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>

				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>

				</a> <a href="staffServlet?action=listCoordinators" class="nav-item">
					<img src="icon/coordinator.png" class="nav-icon"> <span
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
				<h2 class="welcome-text">Dashboard</h2>
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
			<div class="stats">
				<div class="stat-card">
					<h3>PENDING RETURNS</h3>
					<div class="value">
						<%=pendingCount%>
						<span
							class="trend <%=Double.parseDouble(returnRate) > 20 ? "down" : "up"%>">
							<small><%=returnRate%>% of total</small>
						</span>
					</div>
				</div>
				<div class="stat-card">
					<h3>TOTAL EVENTS</h3>
					<div class="value">
						<%=eventCount%>
						<span class="trend up"> <small>▲ <%=eventGrowth%>%
								New
						</small>
						</span>
					</div>
				</div>
				<div class="stat-card">
					<h3>TOTAL EQUIPMENT (Good Condition)</h3>
					<div class="value">
						<%=eqpCount%>
						<span
							class="trend <%=Double.parseDouble(lossRate) > 5 ? "down" : "up"%>">
							<small><%=lossRate%>% Damaged/Lost</small>
						</span>
					</div>
				</div>
			</div>
			<div class="charts-row">
				<div class="chart-card">
					<div class="chart-header">
						<h3>Equipment Condition</h3>
					</div>
					<div class="chart-container">
						<canvas id="equipmentChart"></canvas>
					</div>
				</div>
				<div class="chart-card">
					<div class="chart-header">
						<h3>Event Status</h3>
					</div>
					<div class="piechart-container">
						<canvas id="eventPieChart"></canvas>
					</div>
				</div>
			</div>

			<div class="events-section">
				<div class="events-header">
					<h2 class="section-title">Upcoming Events</h2>
				</div>
				<table class="table">
					<thead>
						<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Date &amp; Time</th>
							<th>Venue</th>
							<th>Package</th>
							<th>Status</th>
						</tr>
					</thead>
					<tbody>
						<%
						// Retrieve and cast the events list
						java.util.List<cems.EventBean> events = (java.util.List<cems.EventBean>) request.getAttribute("events");

						if (events != null && !events.isEmpty()) {
							// Setup Date Formatters
							java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd-MM-yyyy");
							java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");

							for (cems.EventBean event : events) {
								// Determine status class
								String statusClass = "in-progress";
								if ("Completed".equalsIgnoreCase(event.getEventStatus())) {
							statusClass = "completed";
								}
						%>
						<tr>
							<td><a
								href="EventController?action=view&eventID=<%=event.getEventID()%>"
								class="id-link"> <strong><%=event.getEventID()%></strong>
							</a></td>
							<td><%=event.getEventName()%></td>
							<td><%=dateFormat.format(event.getEventDate())%><br>
								<%=timeFormat.format(event.getEventTime())%></td>
							<td><%=event.getEventVenue()%></td>
							<td><%=(event.getPackName() != null) ? event.getPackName() : "N/A"%></td>
							<td class="status <%=statusClass%>"><%=event.getEventStatus()%>
							</td>
						</tr>
						<%
						}
						} else {
						%>
						<tr>
							<td colspan="6" style="text-align: center;">No upcoming
								events found.</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
		</main>
	</div>
	<div id="logoutModal" class="modal-overlay" style="display: none;">
		<div class="modal-content">
			<div class="modal-icon-container"
				style="font-size: 50px; color: #f36f21; margin-bottom: 20px;">
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

		// Initialize Charts when page loads
		document.addEventListener("DOMContentLoaded", function() {
			// 1. Equipment Bar Chart
			const ctxBar = document.getElementById('equipmentChart')
					.getContext('2d');
			new Chart(ctxBar, {
				type : 'bar',
				data : {
					labels : [
	<%=chartLabels%>
		], // e.g., ['VIP', 'PREPARATION', 'GUEST']
					datasets : [ {
						label : 'Good',
						data : [
	<%=chartGood%>
		],
						backgroundColor : '#36a2eb'
					}, {
						label : 'Damaged',
						data : [
	<%=chartDamaged%>
		],
						backgroundColor : '#ffcd56'
					}, {
						label : 'Lost',
						data : [
	<%=chartLost%>
		],
						backgroundColor : '#d30000'
					} ]
				},
				options : {
					responsive : true,
					maintainAspectRatio : false,
					scales : {
						x : {
							stacked : true
						},
						y : {
							stacked : true,
							beginAtZero : true,
							// REMOVE any 'max: 800' if it exists
							ticks : {
								precision : 0,
								// This ensures the scale increments are useful for small numbers
								stepSize : 5
							}
						}
					},
					plugins : {
						legend : {
							position : 'bottom'
						},
						// Add tooltips to see exact numbers on small bars
						tooltip : {
							enabled : true,
							mode : 'index',
							intersect : false
						}
					}
				}
			});

			// 2. Event Pie Chart
			const evData = [
	<%=evChartData%>
		];
			new Chart(document.getElementById('eventPieChart'), {
				type : 'doughnut',
				data : {
					labels : [ 'Completed', 'In-Progress'],
					datasets : [ {
						data : evData,
						backgroundColor : [ '#4bc0c0', '#ffcd56']
					} ]
				},
				options : {
					responsive : true,
					maintainAspectRatio : false
				}
			});
		});
		function showLogoutModal() {
			document.getElementById("logoutModal").style.display = "flex";
		}

		function closeLogoutModal() {
			document.getElementById("logoutModal").style.display = "none";
		}
	</script>
</body>
</html>