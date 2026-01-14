<%@ page import="cems.staffBean" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    staffBean staff = (staffBean) session.getAttribute("staff");
    
    // Check if logged in AND if the role is correct
    if (staff == null || !"MANAGER".equalsIgnoreCase(staff.getStaffRole())) {
        // If they aren't a manager, force them out
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
    <title>Dashboard Manager</title>
    <link rel="stylesheet" href="dashboard.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="layout">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
            </div>                

            <nav class="nav-menu">
                <a href="dashboard.jsp" class="nav-item active">
                    <img src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> 
                    <span class="link-text">Dashboard</span>
                </a>
                <a href="EquipmentController?action=list" class="nav-item">
                    <img src="icon/eqp.png" class="nav-icon"> 
                    <span class="link-text">Equipment</span>
                </a>
                <a href="viewEventList.jsp" class="nav-item">
                    <img src="icon/event.png" class="nav-icon"> 
                    <span class="link-text">Event</span>
                </a>
                <a href="PackageController?action=list" class="nav-item">
                    <img src="icon/package.png" class="nav-icon"> 
                    <span class="link-text">Package</span>
                </a>
                <a href="EClist.jsp" class="nav-item">
                    <img src="icon/coordinator.png" class="nav-icon"> 
                    <span class="link-text">Coordinator</span>
                </a>
                <a href="viewReportList.jsp" class="nav-item">
                    <img src="icon/report.png" class="nav-icon"> 
                    <span class="link-text">Report</span>
                </a>
            </nav>

            <div class="logout-section">
			    <a href="javascript:void(0);" onclick="location.replace('logout.jsp')" class="nav-icon-logout">
			       <img src="icon/logout.png">
			       <span class="link-text">Log Out</span>
			    </a>
			</div>
        </div>
    
        <div class="header"> 
    		<div>
        		<h2 class="welcome-text">Dashboard</h2>
    		</div>
    
    	<div class="user-profile">
        <div class="user-info">
            <span class="user-name"><%= staff.getStaffName() %></span>
            <span class="user-role"><%= staff.getStaffRole() %></span>
        </div>

        	<a href="account.jsp" class="profile-link">
            	<span class="profile-pic-default">
                	<img src="icon/user.png" alt="profile_image">
            	</span>
        	</a>
    	</div>
		</div>

        <main class="main">
            <div class="stats">
                <div class="stat-card">
                    <h3>PENDING RETURNS</h3>
                    <div class="value">12 <span class="trend down"><small>▼ 5%</small></span></div>
                </div>
                <div class="stat-card">
                    <h3>TOTAL EVENTS</h3>
                    <div class="value">24 <span class="trend up"><small>▲ 10%</small></span></div>
                </div>
                <div class="stat-card">
                    <h3>TOTAL EQUIPMENT</h3>
                    <div class="value">150 <span class="trend up"><small>▲ 2%</small></span></div>
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
                <table class="event-table">
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
                         <tr>
                        <td>
						    <a href="viewAssignedEvent.html?eventId=E001" class="id-link">
						        <strong>E001</strong>
						    </a>
						</td>
						<td>Company Annual Meeting</td>
                        <td>
                            27-06-2025<br>
                            12.00 PM
                        </td>
                        <td>Venue A</td>
                        <td>Package A</td>
                        <td class="status completed">Completed</td>
                    </tr>

                    <tr>
                        <td>
						    <a href="viewAssignedEvent.html?eventId=E002" class="id-link">
						        <strong>E002</strong>
						    </a>
						</td>
						<td>Wedding</td>
                        <td>
                            29-06-2025<br>
                            2.00 PM
                        </td>
                        <td>Venue B</td>
                        <td>Package B</td>
                        <td class="status completed">Completed</td>
                    </tr>

                    <tr>
                        <td>
						    <a href="viewAssignedEvent.html?eventId=E003" class="id-link">
						        <strong>E003</strong>
						    </a>
						</td>
						<td>Birthday Party</td>
                        <td>
                            30-06-2025<br>
                            10.00 AM
                        </td>
                        <td>Venue C</td>
                        <td>Package C</td>
                        <td class="status in-progress">In-progress</td>
                    </tr>
                    </tbody>
                </table>
            </div>
               
            <div class="events-section">
                <div class="events-header">
                    <h2 class="section-title">Report List</h2>                    
                </div>
                <table class="event-table">
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
                            <td>
                            	<a href="viewReportList.jsp?packID=R001" class="id-link">
                            		<strong>R001</strong>
                            	</a>
                            </td>
                            <td>Event Report</td>
                            <td>22 May - 29 May 2025</td>
                            <td>30 May 2025</td>
                        </tr>
                        <tr>
                            <td><a href="viewReportList.jsp?packID=R002" class="id-link"><strong>R002</strong></a></td>
                            <td>Event Report</td>
                            <td>21 May 2025</td>
                            <td>27 May 2025</td>
                        </tr>
                        <tr>
                            <td><a href="viewReportList.jsp?packID=R001" class="id-link"><strong>Q001</strong></a></td>
                            <td>Equipment Report</td>
                            <td>15 June - 21 June 2025</td>
                            <td>22 June 2025</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </main>
	</div>
        
        <script>
        // Sidebar Toggle Logic
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("collapsed");
            document.querySelector(".layout").classList.toggle("collapsed");
        }

        // Initialize Charts when page loads
        document.addEventListener("DOMContentLoaded", function() {
            
            // 1. Equipment Condition Bar Chart
            const ctxBar = document.getElementById('equipmentChart').getContext('2d');
            new Chart(ctxBar, {
                type: 'bar',
                data: {
                    labels: ['Preparation', 'Washing', 'Storage', 'VIP', 'Guest'],
                    datasets: [{
                        label: 'Good Condition',
                        data: [12, 19, 3, 5, 10],
                        backgroundColor: '#36a2eb'
                    }, {
                        label: 'Damaged',
                        data: [2, 3, 1, 4, 1],
                        backgroundColor: '#ff6384'
                    }, {
                        label: 'Lost',
                        data: [3, 8, 1, 6, 2],
                        backgroundColor: '#d30000'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });

            // 2. Event Status Pie Chart
            const ctxPie = document.getElementById('eventPieChart').getContext('2d');
            new Chart(ctxPie, {
                type: 'doughnut',
                data: {
                    labels: ['Completed', 'In-Progress', 'Upcoming'],
                    datasets: [{
                        data: [70, 20, 10],
                        backgroundColor: [
                            '#4bc0c0', // Greenish
                            '#ffcd56', // Yellow
                            '#36a2eb'  // Blue
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom' }
                    }
                }
            });
        });
    </script>
</body>
</html>