<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<%@ page import="cems.staffBean"%>
<%@ page import="cems.EventBean"%>
<%@ page import="java.util.List"%>
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
<title>Update Event Details</title>

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
					
				</a> <a href="EventController?action=list" class="nav-item active"> <img
					src="icon/event.png" class="nav-icon"> <span
					class="link-text">Event</span>
					
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
					
				</a> <a href="staffServlet?action=listCoordinators" class="nav-item"> <img
					src="icon/coordinator.png" class="nav-icon"> <span
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
                    <button class="back-link" onclick="window.location.href='EventController?action=list'">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                </div>
                
                <div class="events-header">
					<div class="header-text">
						<h2 class="section-title">Update Event Details</h2>
				<p class="page-desc">Please enter the required updated
					information.</p>
					</div>
				</div>

				<form id="updateEventForm" action="EventController" method="POST">
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
						<div class="pax-row-message" id="dateHint"></div>
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
								<th>Type</th>
								<th>Category</th>
								<th>Quantity In Use</th>
								</tr>
							</thead>
							<tbody>
							<%
							// 1. Retrieve the list we sent from the Controller
							List<EventBean> myEqpList = (List<EventBean>) request.getAttribute("equipmentList");

							// 2. Check if list is valid
							if (myEqpList != null && !myEqpList.isEmpty()) {

								// 3. START THE LOOP
								for (EventBean eqp : myEqpList) {

									// LOGIC FIX: Determine type based on data (since instanceof won't work here)
									String type = "Support"; // Default
									String category = eqp.getEqpFunction();

									// If serviceSet has data, it's Service equipment
									if (eqp.getServiceSet() != null && !eqp.getServiceSet().equals("-") && !eqp.getServiceSet().isEmpty()) {
								type = "Service";
								category = eqp.getServiceSet();
									}
							%>
							<tr class="equipment-row">
								<td><strong><%=eqp.getEqpID()%></strong></td>
								<td><%=eqp.getEqpName()%></td>
								<td><%=type%></td>
								<td><%=category%></td>

								<td><%=eqp.getTotQtyInUse()%></td>
							</tr>

							<%
							} // End for loop
							} else {
							%>
							<tr>
								<td colspan="8" style="text-align: center;">No equipment
									found for this event.</td>
							</tr>
							<%
							} // End else
							%>
							</tbody>
						</table>
					</div>
					</form>
			</div>
		</main>
	</div>

<div id="updateSuccessModal" class="custom-modal">
    <div class="modal-content">
        <i class="fas fa-check-circle" style="color: #2ecc71; font-size: 40px;"></i>
        <h3>Updated!</h3>
        <p>Event details have been successfully updated.</p>
        <div class="modal-buttons">
            <button class="btn-close" onclick="window.location.href='EventController?action=list'">Back to List</button>
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
    /* ---------------- 1. INITIAL SETTINGS & SIDEBAR ---------------- */
    function toggleSidebar() {
        document.getElementById("sidebar").classList.toggle("collapsed");
        document.querySelector(".layout").classList.toggle("collapsed");
    }

    // Data package dari JSTL (digunakan untuk auto-select)
    const packages = {
        <c:forEach var="pkg" items="${packageList}" varStatus="status">
            "<c:out value='${pkg.packID}'/>": { 
                id: "<c:out value='${pkg.packID}'/>", 
                name: "<c:out value='${pkg.packName}'/>", 
                range: [<c:out value='${pkg.lowPackPax}'/>, <c:out value='${pkg.highPackPax}'/>]
            }<c:if test="${!status.last}">,</c:if>
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
        submitBtn.style.backgroundColor = ""; // Kembali ke warna asal CSS
        hint.style.display = "none";
    }

    /* ---------------- 3. CORE LOGIC (DATE & STOCK CHECK) ---------------- */
    function checkAvailabilityAndPackage() {
        const dateInput = document.getElementById("eventDate");
        const paxInput = document.getElementById("pax");
        const dateHint = document.getElementById("dateHint");
        const selectedDate = dateInput.value;
        const paxValue = parseInt(paxInput.value);

        // A. Check Date Availability (Max 4 Events)
        if (selectedDate) {
            fetch("EventController?action=checkDateAvailability&date=" + selectedDate)
            .then(response => response.text())
            .then(count => {
                const eventCount = parseInt(count);
                if (eventCount >= 4) {
                    dateHint.innerHTML = "* ❌ This date is fully booked (4/4 events).";
                    dateHint.style.display = "block";
                    dateHint.style.color = "red";
                    disableSubmit();
                } else {
                    dateHint.style.display = "none";
                    // Jika tarikh OK, baru check Package & Stock
                    processPackageAndStock(paxValue, selectedDate);
                }
            });
        } else {
            processPackageAndStock(paxValue, null);
        }
    }

    function processPackageAndStock(pax, date) {
        const nameSpan = document.getElementById("packageName");
        const tableBody = document.getElementById("equipmentTableBody");
        const packIdInput = document.getElementById("packID");

        let selectedPkg = null;
        for (let key in packages) {
            let p = packages[key];
            if (pax >= p.range[0] && pax <= p.range[1]) {
                selectedPkg = p;
                break;
            }
        }

        if (selectedPkg) {
            nameSpan.textContent = selectedPkg.name + " (" + selectedPkg.range[0] + "-" + selectedPkg.range[1] + ")";
            packIdInput.value = selectedPkg.id;

            let url = "EventController?action=getEquipment&packID=" + selectedPkg.id;
            if (date) url += "&eventDate=" + date;

            fetch(url)
            .then(response => response.json())
            .then(data => {
                let shortageDetected = false;
                let htmlContent = "";

                data.forEach(eq => {
                    const avail = (eq.avail !== undefined) ? parseInt(eq.avail) : 999;
                    const req = parseInt(eq.qty);
                    const isShortage = (date && avail < req); 
                    if(isShortage) shortageDetected = true;

                    htmlContent += '<tr style="' + (isShortage ? 'background-color: #ffe6e6;' : '') + '">';
                    htmlContent += '<td><strong>' + eq.id + '</strong></td>';
                    htmlContent += '<td>' + eq.name + (isShortage ? '<br><b style="color:red; font-size:10px;">! NO STOCK (Avail: ' + avail + ')</b>' : '') + '</td>';
                    htmlContent += '<td>' + req + '</td>';
                    htmlContent += '<td>' + (eq.serviceSet || "-") + '</td>';
                    htmlContent += '<td>' + (eq.eqpFunction || "-") + '</td>';
                    htmlContent += '</tr>';
                });

                tableBody.innerHTML = htmlContent;

                if(shortageDetected) {
                    disableSubmit("* ❌ STOCK ERROR: Not enough equipment for this date.");
                } else {
                    enableSubmit();
                }
            })
            .catch(err => console.error("Error fetching equipment:", err));
        } else {
            nameSpan.textContent = pax > 0 ? "Invalid Pax Range!" : "Select Pax";
            tableBody.innerHTML = "";
            if(pax > 0) disableSubmit("* ❌ No package matches this pax amount.");
        }
    }

    /* ---------------- 4. FORM SUBMISSION (AJAX) ---------------- */
    document.getElementById('updateEventForm').onsubmit = function(e) {
        e.preventDefault();
        const formData = new URLSearchParams(new FormData(this));

        fetch('EventController', {
            method: 'POST',
            body: formData,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
        .then(response => {
            if (response.ok) {
                document.getElementById('updateSuccessModal').style.display = 'flex';
            } else {
                alert("❌ Update failed. Please try again.");
            }
        })
        .catch(err => alert("System error: " + err));
    };
    
    function checkAvailabilityAndPackage() {
        const dateInput = document.getElementById("eventDate");
        const timeInput = document.getElementById("eventTime");
        const dateHint = document.getElementById("dateHint");
        
        const selectedDate = dateInput.value;
        const selectedTime = timeInput.value; // Ambil value dari dropdown masa

        if (selectedDate) {
            // --- LOGIC SEKAT MASA LEPAS (HANYA UNTUK HARI INI) ---
            const now = new Date();
            const todayStr = now.toISOString().split('T')[0];

            if (selectedDate === todayStr) {
                const [hours, minutes] = selectedTime.split(':');
                const chosenDateTime = new Date();
                chosenDateTime.setHours(parseInt(hours), parseInt(minutes), 0);

                if (chosenDateTime < now) {
                    dateHint.innerHTML = "* ❌ Cannot update to a past time for today.";
                    dateHint.style.display = "block";
                    dateHint.style.color = "red";
                    disableSubmit();
                    return; // Stop logic kat sini, jangan check stok dah
                }
            }
            // ---------------------------------------------------

            // Teruskan dengan check Max 4 Events (Logic sedia ada)
            fetch("EventController?action=checkDateAvailability&date=" + selectedDate)
            .then(response => response.text())
            .then(count => {
                const eventCount = parseInt(count);
                // Nota: Pastikan backend tidak kira eventID semasa dalam count ni
                if (eventCount >= 4) {
                    dateHint.innerHTML = "* ❌ This date is fully booked (4/4 events).";
                    dateHint.style.display = "block";
                    disableSubmit();
                } else {
                    dateHint.style.display = "none";
                    processPackageAndStock(parseInt(document.getElementById("pax").value), selectedDate);
                }
            });
        }
    }

    /* ---------------- 5. INITIALIZATION ---------------- */
   window.onload = function() {
    // --- TAMBAHAN: SEKAT TARIKH LEPAS ---
    const today = new Date().toISOString().split('T')[0];
    const datePicker = document.getElementById('eventDate');
    if (datePicker) {
        datePicker.setAttribute('min', today);
    }
    // ------------------------------------

    checkAvailabilityAndPackage();

    document.getElementById("eventDate").addEventListener("change", checkAvailabilityAndPackage);
    document.getElementById("pax").addEventListener("input", checkAvailabilityAndPackage);
    
    document.getElementById('resetBtn').addEventListener('click', function() {
        setTimeout(() => { 
            datePicker.setAttribute('min', today); // Set balik min date lepas reset
            checkAvailabilityAndPackage(); 
        }, 10);
    });
};
function showLogoutModal() {
    document.getElementById("logoutModal").style.display = "flex";
}

function closeLogoutModal() {
    document.getElementById("logoutModal").style.display = "none";
}
</script>

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
