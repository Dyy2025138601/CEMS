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
<link rel="stylesheet" href="style.css">
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
response.setHeader("Pragma", "no-cache"); // HTTP 1.0
response.setDateHeader("Expires", 0); // Proxies
%>

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
				<div class="detail-header-stack">
					<button class="back-link"
						onclick="window.location.href='EventController?action=list'">
						<i class="fas fa-arrow-left"></i> Back
					</button>
				</div>
				<div class="events-header">
					<div class="header-text">
						<h2 class="section-title">Create New Event</h2>
						<p class="page-desc">Please enter required information.</p>
					</div>
				</div>

				<form id="createEventForm">
					<input type="hidden" name="action" value="add"> <input
						type="hidden" name="eventStatus" value="In-progress"> <input
						type="hidden" name="managerID" value="S001">

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
									<option value="">Select date &amp; time first</option>

									<c:forEach var="coord" items="${coordinatorList}">
										<%-- Filter: Only show if role is COORDINATOR --%>
										<c:if test="${coord.staffRole eq 'COORDINATOR'}">
											<option value="${coord.staffID}"
												data-original-name="${coord.staffName}">
												${coord.staffName}</option>
										</c:if>
									</c:forEach>

								</select>
							</div>
						</div>

					</div>

					<div class="events-section">
						<div class="events-header">
							<p class="page-desc">Equipment Included:</p>
							<div class="form-buttons">
								<button type="reset" id="resetBtn" class="reset-btn">Reset</button>
								<button type="submit" class="submit-btn">Submit</button>
							</div>
						</div>
						<table class="table">
							<thead>
								<tr>
									<th>ID</th>
									<th>Name</th>
									<th>Quantity Use</th>
									<th>Type</th>
									<th>Category</th>
								</tr>
							</thead>
							<tbody id="equipmentTableBody"></tbody>
						</table>
					</div>

					<!-- Buttons -->
				</form>
			</div>
		</main>
	</div>

	<div id="createSuccessModal" class="custom-modal">
		<div class="modal-content">
			<i class="fas fa-check-circle"
				style="color: #2ecc71; font-size: 40px;"></i>
			<h3>Success!</h3>
			<p>New Event has been successfully created.</p>
			<div class="modal-buttons">
				<button class="btn-close"
					onclick="window.location.href='EventController?action=list'">Go
					to Event List</button>
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
	/* ---------------- 1. SIDEBAR & HELPERS ---------------- */
	function toggleSidebar() {
			document.getElementById("sidebar").classList.toggle("collapsed");
			document.querySelector(".layout").classList.toggle("collapsed");
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

	/* ---------------- 2. HELPER FUNCTIONS ---------------- */
	function disableSubmit(msg) {
	    const submitBtn = document.querySelector(".submit-btn");
	    const hint = document.getElementById("paxHint");
	    submitBtn.disabled = true;
	    submitBtn.style.backgroundColor = "#ccc";
	    if(msg) {
	        hint.innerHTML = msg;
	        hint.style.display = "block";
            hint.style.color = "red";
	    }
	}

	function enableSubmit() {
	    const submitBtn = document.querySelector(".submit-btn");
	    const hint = document.getElementById("paxHint");
	    submitBtn.disabled = false;
	    submitBtn.style.backgroundColor = "";
	    hint.style.display = "none";
	}
	
	/* ---------------- 3. AUTO SELECT PACKAGE & STOCK CHECK ---------------- */
	/* ---------------- 3. AUTO SELECT PACKAGE & STOCK CHECK ---------------- */
function autoSelectPackage() {
    const paxInput = document.getElementById("pax");
    const val = parseInt(paxInput.value) || 0; 
    
    const eventDate = document.getElementById("eventDate").value;
    const nameSpan = document.getElementById("packageName");
    const tableBody = document.getElementById("equipmentTableBody");
    const packIdInput = document.getElementById("packID");

    let selectedPkg = null;

    // Find the matching package based on the pax range
    for (let key in packages) {
        let p = packages[key];
        if (val >= p.range[0] && val <= p.range[1]) {
            selectedPkg = p;
            break;
        }
    }

    if (selectedPkg) {
        // Update UI
        nameSpan.textContent = selectedPkg.name + " (" + selectedPkg.range[0] + "-" + selectedPkg.range[1] + ")";
        nameSpan.style.color = "#ff6b00";
        packIdInput.value = selectedPkg.id;

        // Construct URL
        let url = "EventController?action=getEquipment&packID=" + selectedPkg.id + "&pax=" + val;
        
        if (eventDate) {
            url += "&eventDate=" + eventDate;
        }

        console.log("Fetching URL:", url);

        // --- FETCH JSON ---
        fetch(url)
            .then(response => response.json()) // Use .json() again!
            .then(data => {
                let shortageDetected = false;
                
                const rows = data.map(eq => {
                    const avail = (eq.avail !== undefined) ? parseInt(eq.avail) : 0;
                    const req = (eq.qty !== undefined) ? parseInt(eq.qty) : 0;
                    const isShortage = (eventDate && avail < req); 
                    if(isShortage) shortageDetected = true;

                    // Handle Type/Category Logic in JS now
                    let typeDisplay = "-";
                    let categoryDisplay = "-";

                    // Check Service Set
                    if (eq.serviceSet && eq.serviceSet !== "-" && eq.serviceSet !== "null") {
                        typeDisplay = "Service";
                        categoryDisplay = eq.serviceSet;
                    } 
                    // Check Eqp Function
                    else if (eq.eqpFunction && eq.eqpFunction !== "-" && eq.eqpFunction !== "null") {
                        typeDisplay = "Support";
                        categoryDisplay = eq.eqpFunction;
                    }

                    return `
                    <tr style="\${isShortage ? 'background-color: #ffe6e6;' : ''}">
                        <td><strong>\${eq.id}</strong></td>
                        <td>
                            \${eq.name} 
                            \${isShortage ? '<br><b style="color:red; font-size:10px;">! NOT ENOUGH STOCK (Avail: ' + avail + ')</b>' : ''}
                        </td>
                        <td>\${req}</td>
                        <td>\${typeDisplay}</td>
                        <td>\${categoryDisplay}</td>
                    </tr>`;
                }).join('');

                tableBody.innerHTML = rows;

                if(shortageDetected) {
                    disableSubmit("* ❌ STOCK ERROR: Equipment shortage for selected date.");
                } else {
                    enableSubmit();
                }
            })
            .catch(error => console.error("Error:", error));

    } else if (val > 0) {
        // Invalid Range
        nameSpan.textContent = "Invalid Pax Range";
        tableBody.innerHTML = "";
        disableSubmit("* ❌ No package matches this pax.");
    }
}

	/* ---------------- 4. COORDINATOR AVAILABILITY ---------------- */
	function checkCoordAvailability() {
    const date = document.getElementById("eventDate").value;
    const coordSelect = document.getElementById("coordinator");

    if (date && coordSelect) {
        coordSelect.disabled = false;
        
        // Fetch list of busy staff IDs for this date
        fetch("EventController?action=getBusyStaff&date=" + date)
        .then(response => response.json())
        .then(busyStaffIds => {
            let allBusy = true; // Flag to check if everyone is busy
            
            Array.from(coordSelect.options).forEach(option => {
                // Skip the default "-- Select --" option
                if (option.value === "") return;

                const isBusy = busyStaffIds.includes(option.value);
                
                // Hide if busy, Show if free
                option.style.display = isBusy ? "none" : "block";
                option.disabled = isBusy;

                // If currently selected option is now busy, reset selection
                if (isBusy && coordSelect.value === option.value) {
                    coordSelect.value = "";
                }
                
                if (!isBusy) allBusy = false; // Found at least one free staff
            });
            // Optional: Show hint if everyone is busy
        })
        .catch(error => console.error("Error:", error));
    }
}

	/* ---------------- 5. MAIN DATE VALIDATION (MAX 4 & PAST DATE) ---------------- */
	function validateAndCheckDate() {
    const dateInput = document.getElementById("eventDate");
    const timeInput = document.getElementById("eventTime");
    const selectedDate = dateInput.value;
    const dateHint = document.getElementById("dateHint");

    if (selectedDate) {
        // 1. Check jika tarikh penuh (Max 4)
        fetch("EventController?action=checkDateAvailability&date=" + selectedDate)
        .then(response => response.text())
        .then(count => {
            const eventCount = parseInt(count);
            
            // Dapatkan masa sekarang
            const now = new Date();
            const todayStr = now.toISOString().split('T')[0];
            
            // Semak jika Tarikh Penuh
            if (eventCount >= 4) {
                dateHint.innerHTML = "* ❌ This date is fully booked (4/4 events).";
                dateHint.style.display = "block";
                disableSubmit();
            } 
            // Semak jika user pilih masa yang dah lepas untuk HARI INI
            else if (selectedDate === todayStr) {
                checkTimeAvailability(); // Panggil function check masa
            }
            else {
                dateHint.style.display = "none";
                enableSubmit();
                checkCoordAvailability();
                autoSelectPackage();
            }
        });
    }
}
	
	function checkTimeAvailability() {
	    const timeSelect = document.getElementById("eventTime");
	    const dateInput = document.getElementById("eventDate");
	    const dateHint = document.getElementById("dateHint");
	    
	    const now = new Date();
	    const todayStr = now.toISOString().split('T')[0];
	    
	    // Jika tarikh dipilih adalah hari ini
	    if (dateInput.value === todayStr) {
	        const selectedTime = timeSelect.value; // Format "22:00:00"
	        const [hours, minutes] = selectedTime.split(':');
	        
	        // Bina objek Date untuk masa yang dipilih hari ini
	        const chosenDateTime = new Date();
	        chosenDateTime.setHours(parseInt(hours), parseInt(minutes), 0);

	        if (chosenDateTime < now) {
	            dateHint.innerHTML = "* ❌ Cannot select a past time for today.";
	            dateHint.style.display = "block";
	            dateHint.style.color = "red";
	            disableSubmit();
	        } else {
	            dateHint.style.display = "none";
	            enableSubmit();
	        }
	    }
	}

window.onload = function() {
    // A. Sekat Tarikh Lepas & Hari Ini (Set min date to Tomorrow)
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1); // Add 1 day
    
    const minDate = tomorrow.toISOString().split('T')[0]; // Format YYYY-MM-DD
    
    const datePicker = document.getElementById('eventDate');
    if (datePicker) {
        datePicker.setAttribute('min', minDate);
    }

    // B. Event Listeners
    document.getElementById("eventDate").addEventListener("change", validateAndCheckDate);
    document.getElementById("pax").addEventListener("input", autoSelectPackage);
    document.getElementById("eventTime").addEventListener("change", checkCoordAvailability);

    // C. Form Submit
    document.getElementById('createEventForm').onsubmit = function(e) {
        e.preventDefault();
        const formData = new URLSearchParams(new FormData(this));
        fetch('EventController', {
            method: 'POST',
            body: formData,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
        .then(response => {
            if (response.ok) document.getElementById('createSuccessModal').style.display = 'flex';
            else alert("❌ Failed to create event.");
        })
        .catch(err => alert("System Error"));
    };

    // D. Reset Button
    document.getElementById("resetBtn").addEventListener("click", () => {
        setTimeout(() => {
            // Re-apply the min date after reset
            datePicker.setAttribute('min', minDate);
            document.getElementById("packageName").textContent = "None";
            document.getElementById("equipmentTableBody").innerHTML = "";
            document.getElementById("dateHint").style.display = "none";
            enableSubmit();
        }, 10);
    });
};
    
 // Tambah ini dalam window.onload
    document.getElementById("eventTime").addEventListener("change", () => {
        checkTimeAvailability();
        checkCoordAvailability(); // Maintain logic sedia ada
    });
    function showLogoutModal() {
	    document.getElementById("logoutModal").style.display = "flex";
	}

	function closeLogoutModal() {
	    document.getElementById("logoutModal").style.display = "none";
	}
</script>

</body>
</html>