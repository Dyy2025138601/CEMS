<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
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
<link rel="stylesheet" href="farah1.css">
</head>
<body>
	<div class="layout">
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="dashboardManager.jsp" class="nav-item"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="EquipmentController?action=list" class="nav-item active"> 
                    <img src="icon/eqp.png" class="nav-icon"> <span 
                    class="link-text">Equipment</span>
                </a><a href="EventController?action=list" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon active"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="viewCoordinatorList.jsp" class="nav-item"> <img
					src="icon/coordinator.png" class="nav-icon"> <span
					class="link-text">Coordinator</span>
				</a> <a href="viewReportList.jsp" class="nav-item"> <img
					src="icon/report.png" class="nav-icon"> <span
					class="link-text">Report</span>
				</a>
			</nav>

			<div class="logout-section">
				<a href="logout.jsp" class="nav-icon-logout"> <img
					src="icon/logout.png"> <span class="link-text">Log Out</span>
				</a>
			</div>
		</div>

		<div class="header">
			<div>
				<h2 class="welcome-text">Event</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name">Hawa Aqiera</span> <span class="user-role">Manager</span>
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
							<div class="search-container">
								<span class="search-icon"><img src="icon/search.png"
									style="width: 16px; height: 16px;"></span> <input type="text"
									placeholder="Search" class="search-input" id="searchInput">
							</div>
							<a href="EventController?action=create" class="add-btn"><span>+</span>
								Create Event</a>
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
												<a
													href="EventController?action=edit&eventID=${event.eventID}"
													class="edit-btn"> <i class="fas fa-edit"></i>
												</a> <a href="#" class="delete-btn"
													onclick="openDeleteModal('${event.eventID}')"> <i
													class="fas fa-trash"></i>
												</a>
											</div>
										</td>
									</tr>
								</c:forEach>
							</tbody>

						</table>
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

	<script>
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
		
		// SEARCH FILTER LOGIC
	    document.getElementById('searchInput').addEventListener('keyup', function() {
	        // 1. Ambil nilai input dan tukar ke huruf kecil (lowercase)
	        const filter = this.value.toLowerCase();
	        
	        // 2. Target semua baris data dalam tbody (kecuali header)
	        const rows = document.querySelectorAll('.event-table tbody tr');

	        rows.forEach(row => {
	            // 3. Ambil teks dari seluruh baris (ID, Venue, Package, dll)
	            const text = row.textContent.toLowerCase();
	            
	            // 4. Jika teks wujud dalam baris, tunjuk baris tersebut. Jika tidak, sorok.
	            if (text.includes(filter)) {
	                row.style.display = '';
	            } else {
	                row.style.display = 'none';
	            }
	        });
	    });
	</script>

	<script>
    var currentDeleteId = null;

    // Buka Modal Pengesahan
    function openDeleteModal(id) {
        currentDeleteId = id; // Simpan ID event yang nak delete
        document.getElementById('deleteModal').style.display = 'block';
    }

    // Tutup Modal (function generic untuk tutup mana-mana modal)
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    // --- PROSES DELETE ---
    document.getElementById('confirmDelete').onclick = function() {
        if (!currentDeleteId) return;

        // URL ke Controller
        var url = "EventController?action=delete&eventID=" + currentDeleteId;

        fetch(url)
        .then(response => {
            if (response.ok) { 
                // Kalau server kata OK (Soft delete berjaya)
                closeModal('deleteModal'); // Tutup modal tanya
                document.getElementById('successModal').style.display = 'block'; // Buka modal success
            } else {
                alert("Gagal memadam event. Sila cuba lagi.");
            }
        })
        .catch(err => {
            console.error("Error:", err);
            alert("Ralat sistem.");
        });
    }; // <--- INI YANG HILANG TADI (Penutup function)

    // Refresh page bila user tekan Close pada success modal
    function reloadPage() {
        window.location.reload(); 
    }

    // Sidebar & Search (Kod asal awak)
    function toggleSidebar() {
        document.getElementById("sidebar").classList.toggle("collapsed");
        document.querySelector(".layout").classList.toggle("collapsed");
    }
</script>
</body>
</html>