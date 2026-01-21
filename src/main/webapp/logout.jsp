<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Logout</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<link rel="stylesheet" href="logout.css">
</head>
<body>

	<div class="modal-overlay">
		<div class="modal-content">
			<h3>Logout Confirmation</h3>
			<p>Are you sure you want to end your session?</p>

			<div class="modal-buttons"
				style="display: flex; gap: 15px; justify-content: center;">
				<button onclick="closeLogout()" class="btn-cancel">Cancel</button>

				<a href="staffServlet?action=logout" style="text-decoration: none;">
					<button class="btn-logout">Log Out</button>
				</a>
			</div>
		</div>
	</div>

</body>
</html>