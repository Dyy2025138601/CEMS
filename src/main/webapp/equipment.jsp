<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Equipment Management</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="eqpstyle.css">

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
    </style>
</head>
<body>

<div class="sidebar">
    <div class="profile-section">
        <a href="account.jsp" class="profile-link">
            <span class="profile-pic-default">
                <img src="icon/user.png" alt="profile_image">
            </span>
        </a>
        <span class="manager-text">Manager</span>
    </div>

    <hr class="divider">

    <nav class="nav-menu">
        <a href="dashboard.jsp" class="nav-item">
            <img src="icon/dashboard.png" class="nav-icon">Dashboard
        </a>
        <a href="equipment.jsp" class="nav-item active">
            <img src="icon/eqp.png" class="nav-icon">Equipment
        </a>
        <a href="ViewEventList.jsp" class="nav-item">
            <img src="icon/event.png" class="nav-icon">Event
        </a>
        <a href="viewPackageList.jsp" class="nav-item">
            <img src="icon/package.png" class="nav-icon">Package
        </a>
        <a href="EClist.jsp" class="nav-item">
            <img src="icon/coordinator.png" class="nav-icon">Coordinator
        </a>
        <a href="viewReportList.jsp" class="nav-item">
            <img src="icon/report.png" class="nav-icon">Report
        </a>
    </nav>

    <div class="logout-section">
        <a href="logout.jsp" class="nav-icon-logout">
            <img src="icon/logout.png"> Log Out
        </a>
    </div>
</div>

<main class="main-content">
    <div class="content-box">
        <h1 class="page-title">List of Equipment</h1>

        <div class="toolbar">
            <div class="filter-group">
                <button class="filter-btn active" onclick="setTab(this)">All</button>
                <button class="filter-btn" onclick="setTab(this)">1: Service</button>
                <button class="filter-btn" onclick="setTab(this)">2: Support</button>
            </div>

            <div class="action-group">
                <button class="add-btn" onclick="openModal()">
                    <span>+</span> Add Equipment
                </button>

                <div class="search-container">
                    <span class="search-icon">
                        <img src="icon/search.png">
                    </span>
                    <input type="text" placeholder="Search" class="search-input">
                </div>
            </div>
        </div>

        <div class="table-wrapper">
            <table class="equipment-table">
                <thead>
                <tr>
                    <th>Eqp ID</th>
                    <th>Image</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Qty</th>
                    <th>In Use</th>
                    <th>Available</th>
                    <th>Damaged</th>
                    <th>Total</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>

                <!-- Static data (can be replaced with JSTL later) -->
                <tr>
                    <td>D001</td>
                    <td><img src="icon/pot.png" class="table-img"></td>
                    <td>Pot Large</td>
                    <td class="type-cell service">2</td>
                    <td>100</td>
                    <td>50</td>
                    <td>50</td>
                    <td>0</td>
                    <td class="total-cell">100</td>
                    <td>
                        <button class="action-edit-btn" onclick="openUpdateModal()">
                            <i class="fas fa-edit"></i>
                        </button>
                    </td>
                </tr>

                <tr>
                    <td>D002</td>
                    <td><img src="icon/wine-glass.jpg" class="table-img"></td>
                    <td>Wine Glass</td>
                    <td class="type-cell support">1</td>
                    <td>5000</td>
                    <td>0</td>
                    <td>4945</td>
                    <td>55</td>
                    <td class="total-cell">4945</td>
                    <td>
                        <button class="action-edit-btn" onclick="openUpdateModal()">
                            <i class="fas fa-edit"></i>
                        </button>
                    </td>
                </tr>

                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Your modals and JavaScript remain the same -->
<!-- No changes needed because JSP supports JS directly -->

<script>
    // (All your JS code remains unchanged)
    function setTab(btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
    }

    function openModal() {
        document.getElementById('equipmentModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('equipmentModal').style.display = 'none';
        document.getElementById('eqpForm').reset();
    }

    function handleTypeChange() {
        const type = document.getElementById('equipmentType').value;
        const serviceDiv = document.getElementById('serviceOptions');
        const supportDiv = document.getElementById('supportOptions');
        const serviceRadios = document.getElementsByName('service');
        const supportRadios = document.getElementsByName('support');

        if (type === 'service') {
            serviceDiv.style.display = 'block';
            supportDiv.style.display = 'none';
            serviceRadios[0].required = true;
            supportRadios[0].required = false;
        } else {
            serviceDiv.style.display = 'none';
            supportDiv.style.display = 'block';
            serviceRadios[0].required = false;
            supportRadios[0].required = true;
        }
    }

    function previewImage(event) {
        const file = event.target.files[0];
        if (!file) return;

        const img = document.getElementById('imagePreview');
        const spanText = document.querySelector('.image-box span');
        const reader = new FileReader();

        reader.onload = () => {
            img.src = reader.result;
            spanText.style.display = 'none'; 
            img.style.width = "100%";
            img.style.height = "100%";
            img.style.opacity = "1";
            img.style.objectFit = "contain"; 
            img.style.marginBottom = "0"; 
        };
        reader.readAsDataURL(file);
    }
    
    // Success Modal Logic
    function showSuccessModal(titleText) {
        document.getElementById('equipmentModal').style.display = 'none';
        document.getElementById('updateModal').style.display = 'none';
        document.getElementById("successTitle").innerHTML = titleText;
        document.getElementById("successModal").style.display = "flex";
    }

    function closeSuccessModal() {
        document.getElementById("successModal").style.display = "none";
        window.location.href = "equipment.html"; 
    }

    function validateAndSubmit() {
        const form = document.getElementById('eqpForm');
        const imageInput = document.getElementById('equipmentImage');
        
        if (!form.checkValidity()) {
            form.reportValidity(); 
            return;
        }

        if (imageInput.files.length === 0) {
            alert("Please upload an image for the equipment.");
            return;
        }

        showSuccessModal("Equipment Successfully<br>Added");
    }

    function openUpdateModal() {
        document.getElementById('updateModal').style.display = 'flex';
    }

    function closeUpdateModal() {
        document.getElementById('updateModal').style.display = 'none';
    }

    function validateAndUpdate() {
        const qtyInput = document.getElementById('updateQty');
        
        if (!qtyInput.checkValidity()) {
            qtyInput.reportValidity();
            return;
        }
        
        showSuccessModal("Equipment Successfully<br>Updated");
    }

    // Close modals when clicking outside the box
    window.onclick = function(event) {
        const addModal = document.getElementById('equipmentModal');
        const updateModal = document.getElementById('updateModal');
        const successModal = document.getElementById('successModal');
        
        if (event.target == addModal) closeModal();
        if (event.target == updateModal) closeUpdateModal();
        if (event.target == successModal) closeSuccessModal();
    }
</script>

</body>
</html>
