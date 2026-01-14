<%@ page import="cems.staffBean" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Coordinator</title>
    <link rel="stylesheet" href="dashboard.css">
    <style>
	@import url('https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap');
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
                <a href="dashboardCoordinator.jsp" class="nav-item active">
                    <img src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> 
                    <span class="link-text">Dashboard</span>
                </a>
                <a href="viewAssignedList.jsp" class="nav-item">
                    <img src="icon/event.png" class="nav-icon"> 
                    <span class="link-text">Event</span>
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

        	<a href="accountCoord.jsp" class="profile-link">
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
                	<h3>EVENT STATUS</h3>
                	<div class="piechartCoor-container">
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
                        <td>White Hall</td>
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
                        <td>Megamall</td>
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
                        <td>Bangunan Biru</td>
                        <td>Package C</td>
                        <td class="status in-progress">In-progress</td>
                    </tr>
                    <tr>
                        <td>
						    <a href="viewAssignedEvent.html?eventId=E004" class="id-link">
						        <strong>E004</strong>
						    </a>
						</td>
						<td>Birthday Party</td>
                        <td>
                            25-08-2025<br>
                            11.00 AM
                        </td>
                        <td>Hall of Fame</td>
                        <td>Package C</td>
                        <td class="status in-progress">In-progress</td>
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
        	            ],
        	            borderWidth: 0 // Optional: Removes white border for cleaner look
        	        }]
        	    },
        	    options: {
        	        responsive: true,
        	        maintainAspectRatio: false, // Allows chart to resize to the container height
        	        layout: {
        	            padding: 0
        	        },
        	        plugins: {
        	            legend: { 
        	                position: 'right', // <--- MOVES LABELS TO THE RIGHT
        	                align: 'center',   // Vertically aligns legend to the middle
        	                labels: {
        	                    boxWidth: 12,  // Makes the colored box smaller
        	                    padding: 15,   // Adds space between label rows
        	                    font: {
        	                        size: 11   // Adjust font size if needed
        	                    }
        	                }
        	            }
        	        }
        	    }
        	});
        	
        });
    </script>
</body>
</html>