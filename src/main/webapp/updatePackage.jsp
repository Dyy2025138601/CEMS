
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Package Details</title>
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
				<a href="dashboardManager.jsp" class="nav-item"> <img
					src="icon/dashboard.png" alt="Dashboard" class="nav-icon"> <span
					class="link-text">Dashboard</span>
				</a> <a href="equipmentList.jsp" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
				</a> <a href="viewEventList.jsp" class="nav-item"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item active">
					<img src="icon/package.png" class="nav-icon"> <span
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
				<h2 class="welcome-text">Package</h2>
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

		<!-- main content page -->
		<main class="main">
			<div class="content-box">
				<h1 class="page-title">${packageCatering.packName}</h1>

				<div class="page-info">
					<div class="info-group">
						<p class="package-id">Package ID: ${packageCatering.packID}</p>
						<p class="package-pax">Pax: ${packageCatering.lowPackPax} -
							${packageCatering.highPackPax}</p>
					</div>
				</div>

				<form action="PackageController" method="post">
					<input type="hidden" name="action" value="updateQty">
    				<input type="hidden" name="packID" value="${packageCatering.packID}">
    				
					<!-- table -->
					<div class="table-group">
						<h1 class="table-title">Equipment Included</h1>
					</div>
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
								<th>Eqp ID</th>
								<th>Name</th>
								<th>Serving Set</th>
								<th>Function</th>
								<th>Quantity Required</th>
							</tr>
						</thead>
						<tbody class="body-row">
							<c:forEach items="${contentList}" var="item">
								<tr>
									<td>${item.eqpID}<input type="hidden" name="eqpID"
										value="${item.eqpID}">
									</td>
									<td>${item.eqpName}</td>
									<td class="muted">N/A</td>
									<td>Storage</td>
									<td><input type="number" name="qtyRequired" id="newQty"
										value="${item.qtyRequired}" min="0" class="quantity-input" />
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
					<!-- button -->
					<div class="table-actions">
						<button type="button" class="btn btn-reset">Reset</button>
						<button class="btn btn-save">Submit</button>
					</div>

				</form>
			</div>

		</main>
	</div>
	<!-- Success Modal -->
	<div class="modal-overlay" id="successModal">
		<div class="modal-box">
			<button class="modal-close" onclick="closeModal()">×</button>

			<h2>
				Package Successfully<br>Updated
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
			
		  /*
		  document.querySelector('.btn-save').addEventListener('click', () => {
		    const updatedData = [];
		
		    inputs.forEach(input => {
		      updatedData.push({
		        eqpId: input.closest('tr').children[0].innerText,
		        quantity: input.value
		      });
		    });
		
		    console.log('Saved data:', updatedData);
		    alert('Changes saved successfully!');
		  });*/
	</script>

	<script>
	    function showModal() {
	        document.getElementById("successModal").style.display = "flex";
	    }
	
	    function closeModal() {
	        // hide modal
	        document.getElementById("successModal").style.display = "none";
	
	        // redirect to Event List page
	        window.location.href = "viewPackageList.jsp";
	    }
	
	    // Close modal when clicking outside
	    document.getElementById("successModal").addEventListener("click", function (e) {
	        if (e.target === this) {
	            closeModal();
	        }
	    });
	</script>

	<script>
    // 1. Check URL for "success=true"
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('success') === 'true') {
            document.getElementById("successModal").style.display = "flex";
        }
    };

    // 2. Close Modal Logic
    function closeModal() {
        document.getElementById("successModal").style.display = "none";
        // Optional: Clean the URL so the modal doesn't pop up again on refresh
        window.history.replaceState(null, null, window.location.pathname + window.location.search.replace("&success=true", ""));
    }

    // 3. Close when clicking outside
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