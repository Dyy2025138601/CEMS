<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Update Event Details</title>

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
				</a> <a href="equipmentList.jsp" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
				</a> <a href="EventController?action=list" class="nav-item active">
					<img src="icon/event.png" class="nav-icon"> <span
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
				<h2 class="section-title">Update Event Details</h2>
				<p class="page-desc">Please enter the required updated
					information.</p>

				<form action="EventController" method="POST">
					<input type="hidden" name="action" value="update"> <input
						type="hidden" name="eventStatus" value="${event.eventStatus}">
					<input type="hidden" name="staffID" value="${event.staffID}">
					<input type="hidden" name="packID" id="packID"
						value="${event.packID}">

					<div class="event-details-card" id="eventFormCard">
						<div class="event-details-row">
							<div class="event-field-inline">
								<label for="eventId">Event ID:</label> <input type="text"
									id="eventId" name="eventID" value="${event.eventID}"
									class="field-input highlight-readonly" readonly>
							</div>
							<div class="event-field-inline">
								<fmt:formatDate value="${event.eventDate}" pattern="yyyy-MM-dd"
									var="isoDate" />
								<label for="eventDate">Event Date:</label> <input type="date"
									id="eventDate" name="eventDate" value="${isoDate}"
									class="field-input" required>
							</div>
							<div class="event-field-inline">
								<fmt:formatDate value="${event.eventTime}" pattern="HH:mm:ss"
									var="isoTime" />
								<label for="eventTime">Event Time:</label> <select
									id="eventTime" name="eventTime" class="field-input" required>
									<option value="08:00:00"
										${isoTime == '08:00:00' ? 'selected' : ''}>8:00 AM</option>
									<option value="09:00:00"
										${isoTime == '09:00:00' ? 'selected' : ''}>9:00 AM</option>
									<option value="12:00:00"
										${isoTime == '12:00:00' ? 'selected' : ''}>12:00 PM</option>
									<option value="14:00:00"
										${isoTime == '14:00:00' ? 'selected' : ''}>2:00 PM</option>
									<option value="16:00:00"
										${isoTime == '16:00:00' ? 'selected' : ''}>4:00 PM</option>
									<option value="22:00:00"
										${isoTime == '22:00:00' ? 'selected' : ''}>10:00 PM</option>
								</select>
							</div>
						</div>

						<div class="event-details-row">
							<div class="event-field-inline">
								<label for="eventName">Event Name:</label> <input type="text"
									id="eventName" name="eventName" value="${event.eventName}"
									class="field-input" required>
							</div>
							<div class="event-field-inline">
								<label for="venue">Venue:</label> <input type="text" id="venue"
									name="eventVenue" value="${event.eventVenue}"
									class="field-input" required>
							</div>
							<div class="event-field-inline">
								<label for="pax">No of Pax:</label> <input type="number"
									id="pax" name="eventPax" value="${event.eventPax}"
									class="field-input" min="1" required>
							</div>
						</div>

						<div class="pax-row-message" id="paxHint"></div>
						<div class="pax-row-message" id="dateHint">* Maximum 4
							events limit alert</div>
					</div>

					<div class="package-wrapper" id="packageSection">
						<div class="package-header-row">
							<h3>
								Package Selected : <span class="orange-text" id="packageName">${event.packName}</span>
							</h3>
							<div class="assign-coordinator">
								<label>Coordinator Assigned :</label> <span class="orange-text">${event.staffName}</span>
							</div>
						</div>
					</div>

					<div class="events-section">
						<div class="events-header">
							<p class="page-desc">Equipment Included:</p>
						</div>
						<table class="equipment-table">
							<thead>
								<tr>
									<th>Equipment ID</th>
									<th>Equipment Name</th>
									<th>Quantity</th>
									<th>Serving Set</th>
									<th>Function</th>
								</tr>
							</thead>
							<tbody id="equipmentTableBody">
								<c:forEach var="item" items="${equipmentList}">
									<tr>
										<td><strong>${item.eqpID}</strong></td>
										<td>${item.eqpName}</td>
										<td>${item.totQtyInUse}</td>
										<td>${item.serviceSet}</td>
										<td>${item.eqpFunction}</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>

					<div class="form-buttons">
						<button type="reset" id="resetBtn" class="reset-btn">Reset</button>
						<button type="submit" class="submit-btn">Save Changes</button>
					</div>
			</div>
		</main>
	</div>


	<script>
    // Sidebar Toggle Logic
    function toggleSidebar() {
        document.getElementById("sidebar").classList.toggle("collapsed");
        document.querySelector(".layout").classList.toggle("collapsed");
    }
    
    // RESET BUTTON
    document.getElementById('resetBtn').addEventListener('click', function() {
        const inputs = document.querySelectorAll('#eventFormCard .field-input');
        inputs.forEach(input => {
            if (!input.hasAttribute('readonly')) input.value = '';
        });
    });
    
    // Sediakan data package
    const packages = {
        <c:forEach var="pkg" items="${packageList}" varStatus="status">
            "<c:out value='${pkg.packID}'/>": { 
                id: "<c:out value='${pkg.packID}'/>", 
                name: "<c:out value='${pkg.packName}'/>", 
                range: [<c:out value='${pkg.lowPackPax}'/>, <c:out value='${pkg.highPackPax}'/>]
            }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    };

    function autoSelectPackage() {
        var val = parseInt(document.getElementById("pax").value);
        var eventDate = document.getElementById("eventDate").value;
        var nameSpan = document.getElementById("packageName");
        var tableBody = document.getElementById("equipmentTableBody");
        var packIdInput = document.getElementById("packID");
        var hint = document.getElementById("paxHint");

        var selectedPkg = null;
        for (var key in packages) {
            var p = packages[key];
            if (val >= p.range[0] && val <= p.range[1]) {
                selectedPkg = p;
                break;
            }
        }

        hint.style.display = "none";

        if (selectedPkg) {
            nameSpan.textContent = selectedPkg.name + " (" + selectedPkg.range[0] + "-" + selectedPkg.range[1] + ")";
            nameSpan.style.color = "#ff6b00";
            packIdInput.value = selectedPkg.id;

            // Guna string biasa, tiada simbol dollar
            var url = "EventController?action=getEquipment&packID=" + selectedPkg.id;
            if (eventDate) url += "&eventDate=" + eventDate;

            fetch(url)
            .then(response => response.json())
            .then(data => {
                var shortageDetected = false;
                var htmlContent = "";

                data.forEach(eq => {
                    var avail = (eq.avail !== undefined) ? parseInt(eq.avail) : 0;
                    var req = parseInt(eq.qty);
                    var isShortage = (eventDate && avail < req); 
                    if(isShortage) shortageDetected = true;

                    var serviceSet = eq.serviceSet ? eq.serviceSet : "-";
                    var eqpFunction = eq.eqpFunction ? eq.eqpFunction : "-";

                    // Bina HTML guna penyambungan string biasa (+)
                    htmlContent += '<tr style="' + (isShortage ? 'background-color: #ffe6e6;' : '') + '">';
                    htmlContent += '<td><strong>' + eq.id + '</strong></td>';
                    htmlContent += '<td>' + eq.name;
                    if(isShortage) {
                        htmlContent += '<br><b style="color:red; font-size:10px;">! NOT ENOUGH STOCK (Avail: ' + avail + ')</b>';
                    }
                    htmlContent += '</td>';
                    htmlContent += '<td>' + req + '</td>';
                    htmlContent += '<td>' + serviceSet + '</td>';
                    htmlContent += '<td>' + eqpFunction + '</td>';
                    htmlContent += '</tr>';
                });

                tableBody.innerHTML = htmlContent;

                if(shortageDetected) {
                    disableSubmit("* ❌ STOCK ERROR: Not enough stock for selected date.");
                } else {
                    enableSubmit();
                }
            })
            .catch(err => console.error("Error:", err));
        } else if (val > 0) {
            nameSpan.textContent = "Invalid Pax Range!";
            tableBody.innerHTML = "";
            disableSubmit("* ❌ No package available.");
        }
    }

    function disableSubmit(msg) {
        var submitBtn = document.querySelector(".submit-btn");
        var hint = document.getElementById("paxHint");
        submitBtn.disabled = true;
        submitBtn.style.backgroundColor = "#ccc";
        if(msg) {
            hint.innerHTML = msg;
            hint.style.display = "block";
        }
    }

    function enableSubmit() {
        var submitBtn = document.querySelector(".submit-btn");
        var hint = document.getElementById("paxHint");
        submitBtn.disabled = false;
        submitBtn.style.backgroundColor = "";
        hint.style.display = "none";
    }

    function validateAndCheckDate() {
        var dateInput = document.getElementById("eventDate");
        var selectedDate = dateInput.value;
        var dateHint = document.getElementById("dateHint");

        if (selectedDate) {
            fetch("EventController?action=checkDateAvailability&date=" + selectedDate)
            .then(response => response.text())
            .then(count => {
                var eventCount = parseInt(count);
                if (eventCount >= 4) {
                    dateInput.value = "";
                    dateHint.innerHTML = "* ❌ Date fully booked (Max 4).";
                    dateHint.style.display = "block";
                    dateHint.style.color = "red";
                    disableSubmit();
                } else {
                    dateHint.style.display = "none";
                    enableSubmit();
                    autoSelectPackage();
                }
            });
        }
    }

    document.getElementById("eventDate").addEventListener("change", validateAndCheckDate);
    document.getElementById("pax").addEventListener("input", autoSelectPackage);

    window.onload = function() {
        autoSelectPackage();
    };
</script>

<script>
/* ---------------- 5. COMPANY AVAILABILITY (MAX 4 EVENTS) ---------------- */
	function checkCompanyAvailability() {
	    const date = document.getElementById("eventDate").value;
	    const dateHint = document.getElementById("dateHint");
	    const submitBtn = document.querySelector(".submit-btn");

	    if (date) {
	        fetch("EventController?action=checkDateAvailability&date=" + date)
	        .then(response => response.text())
	        .then(count => {
	        	console.log("Jumlah event hari ni: " + count); // Tengok kat console (F12)
	            const eventCount = parseInt(count);
	            
	            if (eventCount >= 4) {
	                // Tunjuk amaran dan disable butang submit
	                dateHint.innerHTML = "❌ Maximum 4 events reached for this date (" + eventCount + "/4). Please pick another date.";
	                dateHint.style.display = "block";
	                dateHint.style.color = "red";
	                submitBtn.disabled = true;
	                submitBtn.style.backgroundColor = "#ccc";
	            } else {
	                // Sembunyi amaran
	                dateHint.style.display = "none";
	                // Jangan terus enable submit, biar logic lain (stok/coord) yang tentukan
	            }
	        });
	    }
	}
</script>
</body>
</html>
