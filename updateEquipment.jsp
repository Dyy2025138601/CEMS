<%@ page import="cems.staffBean" %>
<%@ page import="java.util.List" %>
<%@ page import="cems.Equipment" %>
<%@ page import="cems.ServiceEquipment" %>
<%@ page import="cems.SupportEquipment" %>
<%
    Equipment eqp = (Equipment) request.getAttribute("equipment");
    String category = "";
    if (eqp instanceof ServiceEquipment) {
        category = ((ServiceEquipment)eqp).getServiceSet();
    } else if (eqp instanceof SupportEquipment) {
        category = ((SupportEquipment)eqp).getEqpFunction();
    }
%>
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
    <title>Update Equipment</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="farah1.css">
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
            <div class="content-box">
                <div class="detail-header-stack">
                    <button class="back-link" onclick="window.location.href='EquipmentController?action=list'">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                    <h1 class="page-title">Update Equipment</h1>
                </div>

                <form id="updateForm" action="EquipmentController" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="eqpID" value="<%= eqp.getEqpID() %>">

                    <div class="form-inputs-grid">
                        <div class="input-group">
                            <label class="equipment-name-label">Updating: <%= eqp.getEqpName() %></label>
                        </div>
                        <div class="input-group">
                            <label>Update Quantity</label>
                            <input type="number" id="updateQty" name="eqpQty" class="field-input-static" required>
                        </div>
                    </div>

                    <div class="button-wrapper">
                        <button type="button" class="submit-btn" onclick="validateAndUpdate()">Update Records</button>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <div class="modal-overlay" id="successModal" style="display: none;">
        <div class="update-modal" style="text-align: center;">
            <h2 id="successTitle" style="margin-bottom: 20px; color: black;">Successfully<br>Updated</h2>
            <div class="success-icon"><i class="fas fa-check"></i></div>
            <button class="submit-btn" onclick="window.location.href='equipmentList.jsp'">OK</button>
        </div>
    </div>

    <script>
    function validateAndUpdate() {
        const form = document.getElementById('updateForm');
        const qtyInput = document.getElementById('updateQty');
        
        if (!qtyInput.checkValidity()) {
            qtyInput.reportValidity();
            return;
        }

        // Submit the form to the Controller
        form.submit();
    }
    </script>
</body>
</html>