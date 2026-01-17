<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Report</title>
<link rel="stylesheet" href="farah1.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap">

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
				</a> <a href="PackageController?action=list" class="nav-item"> <img
					src="icon/package.png" class="nav-icon"> <span
					class="link-text">Package</span>
				</a> <a href="viewCoordinatorList.jsp" class="nav-item"> <img
					src="icon/coordinator.png" class="nav-icon"> <span
					class="link-text">Coordinator</span>
				</a> <a href="viewReportList.jsp" class="nav-item active"> <img
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
				<h2 class="welcome-text">Report</h2>
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
				<h1 class="section-title">Generate Report</h1>
				<p class="page-desc">Fill in form to generate report.</p>

				<div class="form-box">
					<div class="form-section">
						<h3 class="type-title">Select Report Type</h3>
						<label><input type="radio" name="report" value="Event">
							Event Report</label> <label><input type="radio" name="report"
							value="Report"> Equipment Report</label>
					</div>

					<div class="form-section">
						<h3 class="date-title">Select Date Range</h3>
						<p>Please select the date range:</p>
						<div class="date-picker-wrapper">
							<div class="date-range">
								<input type="text" id="fromDate" placeholder="From" readonly
									style="cursor: pointer;"> <span>–</span> <input
									type="text" id="toDate" placeholder="Until" readonly
									style="cursor: pointer;">
							</div>

							<div id="calendar" class="calendar hidden">
								<div class="calendar-header">
									<button id="prevMonth">‹</button>
									<span id="monthYear"></span>
									<button id="nextMonth">›</button>
								</div>

								<div class="calendar-days">
									<div>Sun</div>
									<div>Mon</div>
									<div>Tue</div>
									<div>Wed</div>
									<div>Thu</div>
									<div>Fri</div>
									<div>Sat</div>
								</div>
								<div id="calendarDates" class="calendar-dates"></div>
								<!-- Footer Buttons -->
								<div class="calendar-footer">
									<!-- Quick range buttons -->
									<div class="quick-ranges">
										<button type="button" onclick="selectToday()">Today</button>
										<button type="button" onclick="selectThisWeek()">This
											Week</button>
										<button type="button" onclick="selectThisMonth()">This
											Month</button>
									</div>

									<!-- Action buttons -->
									<div class="calendar-actions">
										<button type="button" id="resetBtn" class="reset">Reset</button>
										<button type="button" id="applyBtn" class="apply">Apply</button>
									</div>
								</div>

							</div>
						</div>
					</div>
					<div class="button-wrapper">
						<button class="generate-btn" onclick="validateAndGenerate()">Generate
							Report</button>
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
				Report Successfully<br>Generated
			</h2>

			<div class="success-icon">
				<i class="fas fa-check"></i>
			</div>
		</div>
	</div>

	<script>
		function showModal() {
			document.getElementById("successModal").style.display = "flex";
		}

		function closeModal() {
			// hide modal
			document.getElementById("successModal").style.display = "none";

			// redirect to Event List page
			window.location.href = "viewReportList.jsp";
		}

		// Close modal when clicking outside
		document.getElementById("successModal").addEventListener("click",
				function(e) {
					if (e.target === this) {
						closeModal();
					}
				});
	</script>

	<script>
		// 1. Element Selectors
		var calendar = document.getElementById("calendar");
		var calendarDates = document.getElementById("calendarDates");
		var monthYear = document.getElementById("monthYear");
		var fromInput = document.getElementById("fromDate");
		var toInput = document.getElementById("toDate");
		var resetBtn = document.getElementById("resetBtn");
		var applyBtn = document.getElementById("applyBtn");

		// 2. State Variables
		var currentDate = new Date();
		var tempStart = null;
		var tempEnd = null;

		// 3. Open Calendar when clicking inputs
		[ fromInput, toInput ].forEach(function(input) {
			input.onclick = function(e) {
				e.stopPropagation();
				calendar.classList.remove("hidden");
				renderCalendar();
			};
		});

		// 4. Navigate months
		document.getElementById("prevMonth").onclick = function() {
			currentDate.setMonth(currentDate.getMonth() - 1);
			renderCalendar();
		};
		document.getElementById("nextMonth").onclick = function() {
			currentDate.setMonth(currentDate.getMonth() + 1);
			renderCalendar();
		};

		// 5. Reset
		resetBtn.onclick = function() {
			tempStart = null;
			tempEnd = null;
			fromInput.value = "";
			toInput.value = "";
			renderCalendar();
		};

		// 6. Apply Selection
		applyBtn.onclick = function() {
			if (!tempStart) {
				alert("Please select a date first.");
				return;
			}

			// If only one date is selected, range is same-day
			var finalStart = tempStart;
			var finalEnd = tempEnd ? tempEnd : tempStart;

			// Convert to strings
			var startValue = formatDate(finalStart);
			var endValue = formatDate(finalEnd);

			// PUSH TO UI
			fromInput.value = startValue;
			toInput.value = endValue;

			calendar.classList.add("hidden");
		};

		// 7. Core Functions
		function renderCalendar() {
			calendarDates.innerHTML = "";
			var year = currentDate.getFullYear();
			var month = currentDate.getMonth();

			monthYear.textContent = currentDate.toLocaleString("default", {
				month : "long",
				year : "numeric"
			});

			var firstDay = new Date(year, month, 1).getDay();
			var daysInMonth = new Date(year, month + 1, 0).getDate();

			for (var i = 0; i < firstDay; i++) {
				calendarDates.appendChild(document.createElement("div"));
			}

			for (var day = 1; day <= daysInMonth; day++) {
				var dateDiv = document.createElement("div");
				// Use a closure to capture the correct date for the click event
				(function(d) {
					var dateObj = new Date(year, month, d);
					dateDiv.textContent = d;

					if (tempStart && sameDate(dateObj, tempStart))
						dateDiv.classList.add("selected");
					if (tempEnd && sameDate(dateObj, tempEnd))
						dateDiv.classList.add("selected");
					if (tempStart && tempEnd && dateObj > tempStart
							&& dateObj < tempEnd)
						dateDiv.classList.add("in-range");

					dateDiv.onclick = function() {
						selectDate(dateObj);
					};
				})(day);

				calendarDates.appendChild(dateDiv);
			}
		}

		function selectDate(date) {
			var selected = normalizeDate(date);
			if (!tempStart || (tempStart && tempEnd)) {
				tempStart = selected;
				tempEnd = null;
			} else if (selected < tempStart) {
				tempStart = selected;
				tempEnd = null;
			} else {
				tempEnd = selected;
			}
			renderCalendar();
		}

		// --- FIX: ULTRA-COMPATIBLE FORMATTING ---
		function formatDate(date) {
			if (!date)
				return "";
			var y = date.getFullYear();
			// The logic below works in ALL browsers (even very old ones)
			// It adds a "0" to the front, then slices the last 2 digits.
			// e.g., Month 1 becomes "01", Month 11 becomes "011" -> slices to "11"
			var m = ("0" + (date.getMonth() + 1)).slice(-2);
			var d = ("0" + date.getDate()).slice(-2);

			return y + "-" + m + "-" + d;
		}

		function normalizeDate(date) {
			return new Date(date.getFullYear(), date.getMonth(), date.getDate());
		}

		function sameDate(a, b) {
			return a.toDateString() === b.toDateString();
		}

		// Quick range helpers
		window.selectToday = function() {
			tempStart = normalizeDate(new Date());
			tempEnd = tempStart;
			renderCalendar();
		};

		window.selectThisMonth = function() {
			var now = new Date();
			tempStart = new Date(now.getFullYear(), now.getMonth(), 1);
			tempEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0);
			renderCalendar();
		};

		window.selectThisWeek = function() {
			var curr = new Date();
			var first = curr.getDate() - curr.getDay();
			var last = first + 6;

			// Create new date objects to avoid mutation issues
			var startDay = new Date(curr);
			startDay.setDate(first);

			var endDay = new Date(curr);
			endDay.setDate(last);

			tempStart = normalizeDate(startDay);
			tempEnd = normalizeDate(endDay);
			renderCalendar();
		};
	</script>

	<script>
		function validateAndGenerate() {
			// 1. Get the Date values
			var startDate = document.getElementById("fromDate").value;
			var endDate = document.getElementById("toDate").value;

			// 2. Get the Radio button value
			var reportType = null;
			var radios = document.getElementsByName("report");
			for (var i = 0; i < radios.length; i++) {
				if (radios[i].checked) {
					reportType = radios[i].value;
					break;
				}
			}

			// 3. Validation Logic
			if (startDate === "" || endDate === "") {
				alert("Please select a date range first.");
				return; // Stop here
			}

			if (reportType === null) {
				alert("Please select a Report Type (Event or Equipment).");
				return; // Stop here
			}

			// 4. If everything is good:
			// Ideally, here you would send data to the server (AJAX/Fetch).
			// For now, we just assume success and show the modal.
			showModal();
		}
	</script>
</body>
</html>