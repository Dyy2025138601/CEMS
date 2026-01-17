<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create New Event</title>

<link
	href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="farah1.css">

<style>
.pax-row-message {
	font-size: 0.8rem;
	color: #ff4d4d;
	display: none; /* Sorok secara default */
	margin-top: 5px;
}

.error-visible {
	display: block !important; /* Tunjuk bila logic JS panggil */
}
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
				</a> <a href="EquipmentController?action=list" class="nav-item"> <img
					src="icon/eqp.png" class="nav-icon"> <span class="link-text">Equipment</span>
				</a> <a href="EventController?action=list" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="ECController?action=list" class="nav-item"> <img
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

		<!-- MAIN CONTENT -->
		<main class="main">
			<div class="content-box">

			<div class="header-text">
				<h2 class="section-title">Create New Event</h2>
				<p class="page-desc">Please enter required information.</p>
			</div>
			
				<c:if test="${not empty errorMessage}">
					<div
						style="color: red; background-color: #ffe6e6; padding: 10px; border: 1px solid red; margin-bottom: 15px;">
						<strong>Error:</strong> ${errorMessage}
					</div>
				</c:if>

				<!-- Event Info Form Card -->
				<form action="EventController" method="post" 
				onsubmit="return !document.querySelector('.submit-btn').disabled;">
					<input type="hidden" name="action" value="add">
					
					<div class="event-details-card" id="eventFormCard">
						<div class="event-details-row">
							<div class="event-field-inline">
								<label for="eventId">Event ID:</label> <input type="text"
									id="eventId" name="eventID" value="${nextEventID}"
									class="field-input highlight-readonly" readonly>
							</div>
							<div class="event-field-inline">
								<label for="eventDate">Event Date:</label> <input type="date"
									id="eventDate" name="eventDate" class="field-input" required>
							</div>
							<div class="event-field-inline">
								<label for="eventTime">Event Time:</label> <select
									id="eventTime" name="eventTime" class="field-input" required>
									<option value="">-- Select Time --</option>
									<option value="08:00:00">8:00 AM</option>
									<option value="09:00:00">9:00 AM</option>
									<option value="12:00:00">12:00 PM</option>
									<option value="14:00:00">2:00 PM</option>
									<option value="16:00:00">4:00 PM</option>
									<option value="22:00:00">10:00 PM</option>
								</select>
							</div>

						</div>

						<div class="event-details-row">
							<div class="event-field-inline">
								<label for="eventName">Event Name:</label> <input type="text"
									id="eventName" name="eventName" class="field-input"
									placeholder="Enter event name" required>
							</div>

							<div class="event-field-inline">
								<label for="venue">Venue:</label> <input type="text" id="venue"
									name="eventVenue" class="field-input"
									placeholder="Enter event venue" required>
							</div>

							<div class="event-field-inline">
								<label for="pax">No of Pax:</label> <input type="number"
									id="pax" name="eventPax" class="field-input" min="1" required>
							</div>
						</div>

						<div class="pax-row-message" id="paxHint"></div>
						<div class="pax-row-message" id="dateHint">* Maximum 4
							events can be held on the selected date</div>
						<div class="pax-row-message" id="coordHint">* Selected
							coordinator is not available for this date and time</div>

						<input type="hidden" name="packID" id="packID">
					</div>

					<!-- PACKAGE SECTION -->
					<div class="package-wrapper" id="packageSection">
						<div class="package-header-row">
							<h3>
								Package Selected : <span class="orange-text" id="packageName">None</span>
							</h3>
							<div class="assign-coordinator">
								<label for="coordinator">Assign Coordinator :</label> <select
									id="coordinator" name="staffID" class="coordinator-select" 
									disabled required>
									<option value="">Select date & time first</option>
									<c:forEach var="coord" items="${coordinatorList}">
										<option value="${coord.staffID}"
											data-original-name="${coord.staffName}">
											${coord.staffName}</option>
									</c:forEach>
								</select>
							</div>
						</div>
					</div>

					<div class="events-section">
						<div class="events-header">
							<p class="page-desc">Equipment Included:</p>
						</div>
						<table class="table">
							<thead>
								<tr>
									<th>Equipment ID</th>
									<th>Equipment Name</th>
									<th>Quantity</th>
									<th>Serving Set</th>
									<th>Function</th>
								</tr>
							</thead>
							<tbody id="equipmentTableBody"></tbody>
						</table>
					</div>

					<!-- Buttons -->
					<div class="form-buttons">
						<button type="reset" id="resetBtn" class="reset-btn">Reset</button>
						<button type="submit" class="submit-btn">Submit</button>
					</div>
				</form>
			</div>
		</main>
	</div>

<script>
	/* ---------------- 1. SIDEBAR & HELPERS ---------------- */
	function toggleSidebar() {
	    const sidebar = document.getElementById("layout");
	    if (sidebar) sidebar.classList.toggle("collapsed");
	}

	const packages = {
	    <c:forEach var="pkg" items="${packageList}" varStatus="status">
	        "${pkg.packID}": { 
	            id: "${pkg.packID}", 
	            name: "${pkg.packName}", 
	            range: [${pkg.lowPackPax}, ${pkg.highPackPax}]
	        }${!status.last ? ',' : ''}
	    </c:forEach>
	};

	/* ---------------- 2. AUTO SELECT PACKAGE & EQUIPMENT ---------------- */
function autoSelectPackage() {
    const val = parseInt(document.getElementById("pax").value);
    const eventDate = document.getElementById("eventDate").value;
    const nameSpan = document.getElementById("packageName");
    const tableBody = document.getElementById("equipmentTableBody");
    const packIdInput = document.getElementById("packID");
    const hint = document.getElementById("paxHint");

    let selectedPkg = null;
    for (let key in packages) {
        let p = packages[key];
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

        let url = `EventController?action=getEquipment&packID=\${selectedPkg.id}`;
        if (eventDate) url += `&eventDate=\${eventDate}`;

        fetch(url)
        .then(response => response.json())
        .then(data => {
            let shortageDetected = false;
            tableBody.innerHTML = data.map(eq => {
                const avail = (eq.avail !== undefined) ? parseInt(eq.avail) : 0;
                const req = parseInt(eq.qty);
                const isShortage = (eventDate && avail < req); 
                if(isShortage) shortageDetected = true;

                // Ambil data serviceSet dan eqpFunction dari JSON
                const serviceSet = eq.serviceSet ? eq.serviceSet : "-";
                const eqpFunction = eq.eqpFunction ? eq.eqpFunction : "-";

                return `
                <tr style="\${isShortage ? 'background-color: #ffe6e6;' : ''}">
                    <td><strong>\${eq.id}</strong></td>
                    <td>
                        \${eq.name} 
                        \${isShortage ? '<br><b style="color:red; font-size:10px;">! NOT ENOUGH STOCK (Avail: ' + avail + ')</b>' : ''}
                    </td>
                    <td>\${req}</td>
                    <td>\${serviceSet}</td>
                    <td>\${eqpFunction}</td>
                </tr>`;
            }).join('');

            if(shortageDetected) {
                disableSubmit("* ❌ STOCK ERROR: Some equipment is not enough for the selected date.");
            } else {
                enableSubmit();
            }
        });
    } else if (val > 0) {
        nameSpan.textContent = "Invalid Pax Range!";
        nameSpan.style.color = "orange";
        tableBody.innerHTML = ""; // Kosongkan table jika range salah
        disableSubmit("* ❌ No package available for " + val + " pax.");
    }
}

	function disableSubmit(msg) {
	    const submitBtn = document.querySelector(".submit-btn");
	    const hint = document.getElementById("paxHint");
	    submitBtn.disabled = true;
	    submitBtn.style.backgroundColor = "#ccc";
	    if(msg) {
	        hint.innerHTML = msg;
	        hint.style.display = "block";
	    }
	}

	function enableSubmit() {
	    const submitBtn = document.querySelector(".submit-btn");
	    const hint = document.getElementById("paxHint");
	    submitBtn.disabled = false;
	    submitBtn.style.backgroundColor = "";
	    hint.style.display = "none";
	}

	/* ---------------- 3. RULE BARU: TAPIS COORDINATOR IKUT TARIKH ---------------- */
	function checkCoordAvailability() {
	    const date = document.getElementById("eventDate").value;
	    const coordSelect = document.getElementById("coordinator");

	    if (date) {
	        // PENTING: Enable balik dropdown bila tarikh dah dipilih
	        coordSelect.disabled = false;
	        coordSelect.options[0].textContent = "-- Select Coordinator --";

	        // Betulkan syntax template literal `...&date=${date}`
	        fetch("EventController?action=getBusyStaff&date=" + date)
	        .then(response => response.json())
	        .then(busyStaffIds => {
	            console.log("Staff Busy pada tarikh " + date + ": ", busyStaffIds);
	            
	            Array.from(coordSelect.options).forEach(option => {
	                if (option.value === "") return;

	                // Semak jika ID staff ada dalam list busy dari server
	                const isBusy = busyStaffIds.includes(option.value);
	                
	                if (isBusy) {
	                    option.style.display = "none"; // 
	                    option.disabled = true;        // Disable supaya tak boleh pilih guna keyboard
	                    
	                    // Jika Siti Aminah sedang terpilih, kita unselect dia
	                    if (coordSelect.value === option.value) {
	                        coordSelect.value = "";
	                    }
	                } else {
	                    option.style.display = "block"; // Munculkan staff yang free
	                    option.disabled = false;
	                }
	            });
	        })
	        .catch(err => console.error("Error fetching staff:", err));
	    }
	}
	
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

	/* ---------------- 5. LOCK & VALIDATE DATE (MAIN) ---------------- */
	function validateAndCheckDate() {
	    const dateInput = document.getElementById("eventDate");
	    const selectedDate = dateInput.value;
	    const dateHint = document.getElementById("dateHint");
	    const submitBtn = document.querySelector(".submit-btn");

	    if (selectedDate) {
	        // Kita guna satu fetch sahaja untuk check jumlah event
	        fetch("EventController?action=checkDateAvailability&date=" + selectedDate)
	        .then(response => response.text())
	        .then(count => {
	            const eventCount = parseInt(count);
	            console.log("Validation - Event Count for " + selectedDate + ": " + eventCount);

	            if (eventCount >= 4) {
	                // Jika dah penuh (4 atau lebih)
	                //alert("❌ SORRY! This date is already fully booked (Max 4 events). Please choose another date.");
	                dateInput.value = ""; // Padam tarikh
	                dateInput.classList.add("shake-input");
	                setTimeout(() => dateInput.classList.remove("shake-input"), 1000);
	                dateHint.innerHTML = "* ❌ Maximum 4 events reached for this date. Please pick another date.";
	                dateHint.style.display = "block";
	                dateHint.style.color = "red";
	                disableSubmit();
	            } else {
	                // Jika belum penuh
	                dateHint.style.display = "none";
	                enableSubmit();
	                
	                // Teruskan dengan check coordinator & stok equipment
	                checkCoordAvailability();
	                autoSelectPackage();
	            }
	        })
	        .catch(err => console.error("Error validating date:", err));
	    }
	}

	/* ---------------- 4. EVENT LISTENERS (KEMAS) ---------------- */
	// Hanya panggil validateAndCheckDate untuk tarikh
	document.getElementById("eventDate").addEventListener("change", validateAndCheckDate);
	
	document.getElementById("pax").addEventListener("input", autoSelectPackage);
	
	document.getElementById("eventTime").addEventListener("change", checkCoordAvailability);

	document.getElementById("resetBtn").addEventListener("click", () => {
	    document.getElementById("packageName").textContent = "None";
	    document.getElementById("equipmentTableBody").innerHTML = "";
	    document.getElementById("dateHint").style.display = "none";
	    enableSubmit();
	});
</script>

</body>
</html>