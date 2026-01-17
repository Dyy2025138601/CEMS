<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Return Equipment Form</title>
<link rel="stylesheet" href="farah1.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<style>
@import
	url('https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap')
	;
</style>
</head>
<body>
	<div class="layout">
		<div class="sidebar" id="sidebar">
			<div class="sidebar-header">
				<button class="hamburger" onclick="toggleSidebar()">&#9776;</button>
			</div>

			<nav class="nav-menu">
				<a href="dashboardCoordinator.jsp" class="nav-item active"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="viewEventList.jsp" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
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
				<h2 class="welcome-text">Dashboard</h2>
			</div>

			<div class="user-profile">
				<div class="user-info">
					<span class="user-name">Hawa Aqiera</span> <span class="user-role">Coordinator</span>
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
                    <button class="back-link" onclick="window.location.href='EquipmentController?action=list'">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                </div>
				<div class="events-section">
					<div class="events-header">
						<div class="header-text">
							<h1 class="section-title">Equipment Return Form</h1>
							<p class="page-desc">Fill in equipment return quantity.</p>
						</div>
					</div>
					<!-- table -->
					<table class="event-table">
						<colgroup>
							<col style="width: 18%">
							<col style="width: 22%">
							<col style="width: 18%">
							<col style="width: 18%">
							<col style="width: 30%">
						</colgroup>
						<thead>
							<tr>
								<th>ID</th>
								<th>Name</th>
								<th>Serving Set</th>
								<th>Function</th>
								<th>Quantity Return</th>
							</tr>
						</thead>
						<tbody class="body-row">
							<tr>
								<td><a class="id-link"> <strong>E001</strong>
								</a></td>
								<td>Large Pot</td>
								<td class="muted">N/A</td>
								<td>Storage</td>
								<td><input type="number" name="newQty" id="newQty"
									value="11" min="0" class="quantity-input" /></td>
							</tr>
							<tr>
								<td><a class="id-link"> <strong>E002</strong>
								</a></td>
								<td>Buffet</td>
								<td>Guest</td>
								<td class="muted">N/A</td>
								<td><input type="number" name="newQty" id="newQty"
									value="12" min="0" class="quantity-input" /></td>
							</tr>
							<tr>
								<td><a class="id-link"> <strong>E003</strong>
								</a></td>
								<td>Insert</td>
								<td>Guest</td>
								<td class="muted">N/A</td>
								<td><input type="number" name="newQty" id="newQty"
									value="24" min="0" class="quantity-input" /></td>
							</tr>
							<tr>
								<td><a class="id-link"> <strong>E004</strong>
								</a></td>
								<td>Plate</td>
								<td>Guest</td>
								<td class="muted">N/A</td>
								<td><input type="number" name="newQty" id="newQty"
									value="5000" min="0" class="quantity-input" /></td>
							</tr>
						</tbody>
					</table>

					<!-- button -->
					<div class="table-actions">
						<button class="btn btn-reset">Reset</button>
						<button class="btn btn-save" onclick="showModal()">Submit</button>
					</div>
				</div>
			</div>
		</main>
	</div>

	<!-- Success Modal -->
	<div class="modal-overlay" id="successModal">
		<div class="modal-box">
			<button class="modal-close" onclick="closeModal()">×</button>

			<h2>
				Equipment Return Successfully<br>Submitted
			</h2>

			<div class="success-icon">
				<i class="fas fa-check"></i>
			</div>
		</div>
	</div>

	<script>
		  const inputs = document.querySelectorAll('.quantity-input');
		
		  // Store original values
		  inputs.forEach(input => {
		    input.dataset.original = input.value;
		  });
		
		  document.querySelector('.btn-reset').addEventListener('click', () => {
		    inputs.forEach(input => {
		      input.value = input.dataset.original;
		      input.closest('tr').classList.remove('edited');
		    });
		  });
		
		  
	</script>

	<script>
	    function showModal() {
	        document.getElementById("successModal").style.display = "flex";
	    }
	
	    function closeModal() {
	        // hide modal
	        document.getElementById("successModal").style.display = "none";
	
	        // redirect to Event List page
	        window.location.href = "viewAssignedList.jsp";
	    }
	
	    // Close modal when clicking outside
	    document.getElementById("successModal").addEventListener("click", function (e) {
	        if (e.target === this) {
	            closeModal();
	        }
	    });
	</script>

	<script>
		// Sidebar Toggle Logic
		function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
		}
	</script>

</body>
</html>