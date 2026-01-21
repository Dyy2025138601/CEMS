<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<%@ page import="cems.staffBean"%>
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
				</a> <a href="EventController?action=list" class="nav-item active">
					<img src="icon/event.png" class="nav-icon"> <span
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
				<div class="events-section">
					<div class="events-header">
						<div class="header-text">
							<h2 class="section-title">Event List</h2>
							<p class="page-desc">Here is the list of all events.</p>
						</div>

						<div class="action-group">
							<select id="statusFilter" class="search-input"
								style="width: 150px; margin-right: 10px; cursor: pointer;">
								<option value="">All Status</option>
								<option value="In-progress">In-progress</option>
								<option value="Completed">Completed</option>
							</select>

							<div class="search-container">
								<span class="search-icon"> <img src="icon/search.png"
									style="width: 16px; height: 16px;">
								</span> <input type="text" placeholder="Search" class="search-input"
									id="searchInput">
							</div>

							<a href="EventController?action=create" class="add-btn"> <span>+</span>
								Create Event
							</a>
						</div>
					</div>

					<div class="events-section">
						<table class="table">
							<thead>
								<tr>
									<th>Event ID</th>
									<th>Date &amp;Time</th>
									<th>Venue</th>
									<th>Package</th>
									<th>Status</th>
									<th>Action</th>
								</tr>
							</thead>

							<tbody>
								<c:forEach items="${events}" var="event">
									<tr>
										<td><a
											href="EventController?action=view&eventID=${event.eventID}"
											class="id-link"> <strong>${event.eventID}</strong>
										</a></td>
										<td><fmt:formatDate value="${event.eventDate}"
												pattern="dd-MM-yyyy" /> <br> <fmt:formatDate
												value="${event.eventTime}" pattern="hh:mm a" /></td>
										<td>${event.eventVenue}</td>
										<td>${event.packName}</td>
										<td
											class="status ${event.eventStatus == 'Completed' ? 'completed' : 'in-progress'}">
											${event.eventStatus}</td>
										<td>
											<div class="action-buttons">
												<c:choose>
													<c:when test="${event.eventStatus == 'Completed'}">
														<a href="javascript:void(0)" class="edit-btn btn-disabled"
															title="Completed events cannot be edited"> <i
															class="fas fa-edit"></i>
														</a>
														<a href="javascript:void(0)"
															class="delete-btn btn-disabled"
															title="Completed events cannot be deleted"> <i
															class="fas fa-trash"></i>
														</a>
													</c:when>

													<c:otherwise>
														<a
															href="EventController?action=edit&eventID=${event.eventID}"
															class="edit-btn"> <i class="fas fa-edit"></i>
														</a>
														<a href="#" class="delete-btn"
															onclick="openDeleteModal('${event.eventID}')"> <i
															class="fas fa-trash"></i>
														</a>
													</c:otherwise>
												</c:choose>
											</div>
										</td>
									</tr>
								</c:forEach>
							</tbody>

						</table>
						<div class="pagination-container">
							<div class="pagination-info">
								Showing <span id="startRange">0</span> to <span id="endRange">0</span>
								of <span id="totalEntries">0</span> entries
							</div>
							<div class="pagination-controls">
								<button class="pag-btn" id="prevBtn">Previous</button>
								<div id="pageNumbers" class="page-numbers"></div>
								<button class="pag-btn" id="nextBtn">Next</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</main>
	</div>

	<div id="deleteModal" class="custom-modal">
		<div class="modal-content">
			<h3>Confirmation</h3>
			<p>Are you sure to delete this event?</p>
			<div class="modal-buttons">
				<button class="btn-yes" id="confirmDelete">Yes</button>
				<button class="btn-no" onclick="closeModal('deleteModal')">No</button>
			</div>
		</div>
	</div>

	<div id="successModal" class="custom-modal">
		<div class="modal-content">
			<i class="fas fa-check-circle"
				style="color: #2ecc71; font-size: 40px;"></i>
			<h3>Deleted!</h3>
			<p>Event Successfully Deleted</p>
			<div class="modal-buttons">
				<button class="btn-close" onclick="reloadPage()">Close</button>
			</div>
		</div>
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

    let currentPage = 1;
    const rowsPerPage = 10;
    let visibleRows = [];
    var currentDeleteId = null;

    function updateTableUI() {
        const searchInput = document.getElementById('searchInput');
        const statusFilter = document.getElementById('statusFilter');
        
        if (!searchInput || !statusFilter) return;

        const searchFilterValue = searchInput.value.toLowerCase().trim();
        const statusFilterValue = statusFilter.value.toLowerCase().trim();
        const allRows = Array.from(document.querySelectorAll('.table tbody tr'));
        
        // 1. Filtering Logic
        visibleRows = allRows.filter(row => {
            const rowText = row.textContent.toLowerCase();
            const statusCell = row.querySelector('.status');
            const statusText = statusCell ? statusCell.textContent.toLowerCase().trim() : "";
            
            const matchesSearch = rowText.includes(searchFilterValue);
            const matchesStatus = (statusFilterValue === "") || (statusText === statusFilterValue);

            row.style.display = 'none'; // Sembunyikan semua dulu
            return matchesSearch && matchesStatus;
        });

        const totalEntries = visibleRows.length;
        const totalPages = Math.ceil(totalEntries / rowsPerPage) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        // 2. Pagination Display Logic
        const start = (currentPage - 1) * rowsPerPage;
        const end = start + rowsPerPage;

        visibleRows.slice(start, end).forEach(row => {
            row.style.display = '';
        });

        // 3. Update Text Info (Showing x to y of z)
        document.getElementById('totalEntries').innerText = totalEntries;
        document.getElementById('startRange').innerText = totalEntries === 0 ? 0 : start + 1;
        document.getElementById('endRange').innerText = Math.min(end, totalEntries);

        // 4. Update Pagination Controls (Buttons & Numbers)
        updatePaginationButtons(totalPages);
    }

    function updatePaginationButtons(totalPages) {
        const prevBtn = document.getElementById('prevBtn');
        const nextBtn = document.getElementById('nextBtn');
        const pageNumbersContainer = document.getElementById('pageNumbers');

        prevBtn.disabled = (currentPage === 1);
        nextBtn.disabled = (currentPage === totalPages || totalEntries === 0);

        pageNumbersContainer.innerHTML = '';
        for (let i = 1; i <= totalPages; i++) {
            const btn = document.createElement('button');
            btn.innerText = i;
            btn.classList.add('page-num');
            if (i === currentPage) btn.classList.add('active');
            btn.onclick = () => {
                currentPage = i;
                updateTableUI();
            };
            pageNumbersContainer.appendChild(btn);
        }
    }

    /* ---------------- EVENT LISTENERS ---------------- */
    window.onload = function() {
        updateTableUI(); 

        document.getElementById('searchInput').addEventListener('input', () => {
            currentPage = 1;
            updateTableUI();
        });

        document.getElementById('statusFilter').addEventListener('change', () => {
            currentPage = 1;
            updateTableUI();
        });

        document.getElementById('nextBtn').onclick = () => {
            currentPage++;
            updateTableUI();
        };

        document.getElementById('prevBtn').onclick = () => {
            if (currentPage > 1) {
                currentPage--;
                updateTableUI();
            }
        };
    };

    /* ---------------- MODAL LOGIC ---------------- */
    function openDeleteModal(id) {
        currentDeleteId = id; 
        document.getElementById('deleteModal').style.display = 'flex';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    function showLogoutModal() { document.getElementById("logoutModal").style.display = "flex"; }
    function closeLogoutModal() { document.getElementById("logoutModal").style.display = "none"; }
    function reloadPage() { window.location.reload(); }

    document.getElementById('confirmDelete').onclick = function() {
        if (!currentDeleteId) return;
        fetch("EventController?action=delete&eventID=" + currentDeleteId)
        .then(response => {
            if (response.ok) { 
                closeModal('deleteModal'); 
                document.getElementById('successModal').style.display = 'flex'; 
            } else {
                alert("Delete failed.");
            }
        });
    };
</script>
</body>
</html>