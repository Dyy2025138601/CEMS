<%@ page import="cems.staffBean"%>
<%@ page import="java.util.List"%>
<%@ page import="cems.Equipment"%>
<%@ page import="cems.ServiceEquipment"%>
<%@ page import="cems.SupportEquipment"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
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
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="style.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap')
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
				<a href="EventController?action=dashboard" class="nav-item"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>

				</a> <a href="EquipmentController?action=list" class="nav-item active">
					<img src="icon/eqp.png" class="nav-icon"> <span
					class="link-text">Equipment</span>

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
				<h2 class="welcome-text">Equipment</h2>
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
							<span class="search-icon"> <img src="icon/search.png"
								style="width: 16px; height: 16px;">
							</span> <input type="text" placeholder="Search" class="search-input"
								id="searchInput">
						</div>
						<a href="EquipmentController?action=insert" class="add-btn"> <span>+</span>
								Create Equipment
							</a>
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
								<th>Quantity Available</th>
                                <th>Total Quantity</th>
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
							<tr class="equipment-row" data-type="<%=type.toUpperCase()%>">
								<td><a
									href="EquipmentController?action=view&id=<%=eqp.getEqpID()%>"
									class="id-link"> <strong><%=eqp.getEqpID()%></strong>
								</a></td>
								<td>
									<div class="item-cell">
										<%-- If image path is null, show default icon --%>
										<img
											src="<%=(eqp.getEqpImage() != null) ? eqp.getEqpImage() : "icon/ImageInsrt.png"%>"
											class="min-img"> <span class="item-name"><%=eqp.getEqpName()%></span>
									</div>
								</td>
								<td style="text-transform: capitalize;"><span class="dot <%=dotClass%>"></span> <%=type%></td>
								<td style="text-transform: capitalize;">
                                    <%= (category != null) ? category : "-" %>
                                </td>
								<td class="text-success"><%= eqp.getTotQtyAvailable() %></td>
								<!--<td><%= eqp.getTotQtyInUse() %></td> -->
                                 <td><%= eqp.getEqpQty() %></td> 
                                <td>
									<button class="edit-btn"
										onclick="window.location.href='EquipmentController?action=edit&id=<%=eqp.getEqpID()%>'">
										<i class="fas fa-edit"></i>
									</button>
								</td>
							</tr>
							<%
							} // end for
							} else {
							%>
							<tr>
								<td colspan="7" style="text-align: center; padding: 20px;">
									No equipment found. <a href="EquipmentController?action=list">Refresh
										List</a>
								</td>
							</tr>
							<%
							}
							%>
						</tbody>
					</table>
					<div class="pagination-container">
						<div class="pagination-info">
							Showing <span id="startRange">0</span> to <span id="endRange">0</span>
							of <span id="totalEntries">0</span> entries
						</div>
						<div class="pagination-controls">
							<button class="pag-btn" id="prevBtn" onclick="changePage(-1)">Previous</button>
							<div id="pageNumbers" class="page-numbers"></div>
							<button class="pag-btn" id="nextBtn" onclick="changePage(1)">Next</button>
						</div>
					</div>
				</div>
			</div>
		</main>
	</div>

	<div class="modal-overlay" id="successModal" style="display: none;">
		<div class="update-modal" style="text-align: center;">
			<h2 id="successTitle" style="margin-bottom: 20px; color: black;">Action
				Successful</h2>
			<div class="success-icon">
				<i class="fas fa-check"></i>
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
    let currentPage = 1;
    const rowsPerPage = 8; // Anda boleh tukar bilangan baris di sini
    let filteredRows = [];

    function toggleSidebar() {
        document.getElementById("sidebar").classList.toggle("collapsed");
        document.querySelector(".layout").classList.toggle("collapsed");
    }

    // Fungsi Utama: Gabungan Filter + Search + Pagination
    function filterEquipment() {
        const query = document.getElementById('searchInput').value.toLowerCase();
        const activeBtn = document.querySelector('.filter-btn.active');
        let activeFilter = "ALL";
        
        if (activeBtn) {
            const btnText = activeBtn.innerText.toUpperCase();
            if (btnText.includes("SERVICE")) activeFilter = "SERVICE";
            if (btnText.includes("SUPPORT")) activeFilter = "SUPPORT";
        }

        const allRows = Array.from(document.querySelectorAll('.equipment-row'));
        
        // Cari baris yang menepati kriteria
        filteredRows = allRows.filter(row => {
            const allRowText = row.innerText.toLowerCase();
            const rowType = row.getAttribute('data-type'); 
            const matchesTab = (activeFilter === "ALL" || rowType === activeFilter);
            const matchesSearch = allRowText.includes(query);
            
            return matchesTab && matchesSearch;
        });

        // Reset ke page 1 bila filter berubah
        currentPage = 1;
        updateTableUI();
    }

    function updateTableUI() {
        const allRows = document.querySelectorAll('.equipment-row');
        // Sembunyikan semua baris dahulu
        allRows.forEach(row => row.style.display = "none");

        // Kira range untuk pagination
        const start = (currentPage - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        const total = filteredRows.length;

        // Tunjukkan baris untuk page semasa sahaja
        const pageRows = filteredRows.slice(start, end);
        pageRows.forEach(row => row.style.display = "");

        // Kemaskini info teks
        document.getElementById('totalEntries').innerText = total;
        document.getElementById('startRange').innerText = total === 0 ? 0 : start + 1;
        document.getElementById('endRange').innerText = Math.min(end, total);

        updatePaginationControls(total);
    }

    function updatePaginationControls(total) {
        const totalPages = Math.ceil(total / rowsPerPage);
        const pageNumbersContainer = document.getElementById('pageNumbers');
        pageNumbersContainer.innerHTML = '';

        document.getElementById('prevBtn').disabled = currentPage === 1;
        document.getElementById('nextBtn').disabled = currentPage === totalPages || totalPages === 0;

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

    function changePage(direction) {
        currentPage += direction;
        updateTableUI();
    }

    function setTab(btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        filterEquipment();
    }

    document.getElementById('searchInput').addEventListener('input', filterEquipment);

    // Jalankan filter/pagination sebaik sahaja page load
    window.onload = function() {
    filterEquipment(); // Inisialisasi pagination

    const urlParams = new URLSearchParams(window.location.search);
    
    // Semak jika status success ada DAN pastikan kita bukan baru nak buat action lain
    if (urlParams.get('status') === 'success' && urlParams.get('action') === 'list') {
        const modal = document.getElementById("successModal");
        if (modal) {
            modal.style.display = "flex";

            // Cuci URL sepenuhnya
            const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname + "?action=list";
            window.history.replaceState({path: cleanUrl}, '', cleanUrl);

            // Tutup modal secara automatik
            setTimeout(() => { 
                modal.style.display = "none"; 
            }, 2000);
        }
    }
};

    function showLogoutModal() { document.getElementById("logoutModal").style.display = "flex"; }
    function closeLogoutModal() { document.getElementById("logoutModal").style.display = "none"; }
</script>

</body>
</html>