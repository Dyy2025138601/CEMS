<%@ page import="cems.staffBean" %>
<%@ page import="java.util.List" %>
<%@ page import="cems.Equipment" %>
<%@ page import="cems.ServiceEquipment" %>
<%@ page import="cems.SupportEquipment" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
<title>Equipment List</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="farah1.css">
<style>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
</style>
</head>
<body>
    <div class="layout">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
            </div>

            <nav class="nav-menu">
                <a href="dashboardManager.jsp" class="nav-item"> 
                    <img src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> 
                    <span class="link-text">Dashboard</span>
                </a> 
                <a href="EquipmentController?action=list" class="nav-item active"> 
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
                <a href="viewCoordinatorList.jsp" class="nav-item"> 
                    <img src="icon/coordinator.png" class="nav-icon"> 
                    <span class="link-text">Coordinator</span>
                </a> 
                <a href="viewReportList.jsp" class="nav-item"> 
                    <img src="icon/report.png" class="nav-icon"> 
                    <span class="link-text">Report</span>
                </a>
            </nav>

            <div class="logout-section">
                <a href="logout.jsp" class="nav-icon-logout"> 
                    <img src="icon/logout.png"> <span class="link-text">Log Out</span>
                </a>
            </div>
        </div>

        <div class="header">
            <div>
                <h2 class="welcome-text">Equipment</h2>
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
            <div class="content-box" id="listView">
                <div class="events-header">
                    <div class="header-text">
                        <h1 class="section-title">List of Equipment</h1>
                        <p class="page-desc">Here is the list of all equipment.</p>
                    </div>
                </div>

                <div class="toolbar">
                    <div class="filter-group">
                        <button class="filter-btn active" onclick="setTab(this)">All</button>
                        <button class="filter-btn" onclick="setTab(this)">
                            <span class="dot service"></span>Service
                        </button>
                        <button class="filter-btn" onclick="setTab(this)">
                            <span class="dot support"></span>Support
                        </button>
                    </div>
                    <div class="action-group">
                        <div class="search-container">
                            <span class="search-icon"><img src="icon/search.png"></span>
                            <input type="text" placeholder="Search" class="search-input">
                        </div>
                        <button class="add-btn" onclick="window.location.href='createEquipment.jsp'">
                            <span>+</span> Create Equipment
                        </button>
                    </div>
                </div>

                <div class="events-section">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Item</th>
                                <th>Type</th>
                                <th>Category</th>
                                <th>Quantity</th>
                                <th>Total</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
						    <% 
						        // 1. Get the list from the request attribute
						        Object attr = request.getAttribute("eqpList");
						        List<Equipment> eqpList = null;
						        
						        if (attr instanceof List) {
						            eqpList = (List<Equipment>) attr;
						        }
						
						        // 2. Loop through the list if it exists
						        if (eqpList != null && !eqpList.isEmpty()) {
						            for (Equipment eqp : eqpList) {
						                // Determine the Type and Category dynamically
						                String type = (eqp instanceof ServiceEquipment) ? "service" : "support";
						                String category = "";
						                String dotClass = type.toLowerCase(); // used for CSS classes 'service' or 'support'
						
						                if (eqp instanceof ServiceEquipment) {
						                    category = ((ServiceEquipment) eqp).getServiceSet();
						                } else if (eqp instanceof SupportEquipment) {
						                    category = ((SupportEquipment) eqp).getEqpFunction();
						                }
						    %>
						    <tr class="equipment-row" data-type="<%= type.toUpperCase() %>">
						        <td>
								    <a href="EquipmentController?action=view&id=<%= eqp.getEqpID() %>" class="id-link">
								        <strong><%= eqp.getEqpID() %></strong>
								    </a>
								</td>
						        <td>
						            <div class="item-cell">
						                <%-- If image path is null, show default icon --%>
						                <img src="<%= (eqp.getEqpImage() != null) ? eqp.getEqpImage() : "icon/pot.png" %>" class="min-img">
						                <span class="item-name"><%= eqp.getEqpName() %></span>
						            </div>
						        </td>
						        <td><span class="dot <%= dotClass %>"></span> <%= type %></td>
						        <td><%= (category != null) ? category.toLowerCase() : "-" %></td>
						        <td><%= eqp.getEqpQty() %></td>
						        <td class="text-success"><%= eqp.getEqpTotQty() %></td> <%-- Replace with logic if needed --%>
						        <td>
						            <button class="edit-btn" 
									        onclick="window.location.href='EquipmentController?action=edit&id=<%= eqp.getEqpID() %>'">
									    <i class="fas fa-edit"></i>
									</button>
						        </td>
						    </tr>
						    <% 
						            } // end for
						        } else { 
						    %>
						    <tr>
						        <td colspan="7" style="text-align:center; padding: 20px;">
						            No equipment found. <a href="EquipmentController?action=list">Refresh List</a>
						        </td>
						    </tr>
						    <% } %>
						</tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <div class="modal-overlay" id="successModal" style="display: none;">
        <div class="update-modal" style="text-align: center;">
            <button class="close-btn" onclick="closeSuccessModal()">✕</button>
            <h2 id="successTitle" style="margin-bottom: 20px; color: black;">Action Successful</h2>
            <div class="success-icon">
                <i class="fas fa-check"></i>
            </div>
        </div>
    </div>

    <script>
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("collapsed");
            document.querySelector(".layout").classList.toggle("collapsed");
        }

        function setTab(btn) {
            // 1. Update UI
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            // 2. Get the filter text correctly
            const btnText = btn.innerText.toUpperCase();
            let filterValue = "ALL";
            if (btnText.includes("SERVICE")) filterValue = "SERVICE";
            if (btnText.includes("SUPPORT")) filterValue = "SUPPORT";

            const rows = document.querySelectorAll('.equipment-row');

            rows.forEach(row => {
                const rowType = row.getAttribute('data-type'); // "SERVICE" or "SUPPORT"
                
                if (filterValue === "ALL") {
                    row.style.display = ""; 
                } else if (rowType === filterValue) {
                    row.style.display = ""; 
                } else {
                    row.style.display = "none"; 
                }
            });
        }
        
        document.querySelector('.search-input').addEventListener('input', function() {
            const query = this.value.toLowerCase();
            
            // Determine active filter
            const activeBtnText = document.querySelector('.filter-btn.active').innerText.toUpperCase();
            let activeFilter = "ALL";
            if (activeBtnText.includes("SERVICE")) activeFilter = "SERVICE";
            if (activeBtnText.includes("SUPPORT")) activeFilter = "SUPPORT";

            const rows = document.querySelectorAll('.equipment-row');

            rows.forEach(row => {
                const itemName = row.querySelector('.item-name').innerText.toLowerCase();
                const rowType = row.getAttribute('data-type');

                const matchesTab = (activeFilter === "ALL" || rowType === activeFilter);
                const matchesSearch = itemName.includes(query);

                row.style.display = (matchesTab && matchesSearch) ? "" : "none";
            });
        });

        function closeSuccessModal() {
            document.getElementById("successModal").style.display = "none";
        }

        // Logic to show success message if redirected from a save/update action
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('status') === 'success') {
                document.getElementById("successModal").style.display = "flex";
                window.history.replaceState(null, null, window.location.pathname);
            }
        }
    </script>
</body>
</html>