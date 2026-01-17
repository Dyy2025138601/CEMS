package cems;

import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.sql.Timestamp;

@WebServlet("/EventController")
public class EventController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public EventController() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String action = request.getParameter("action");

		if (action == null)
			action = "list";

		try {
			switch (action) {
			case "create":
				request.setAttribute("nextEventID", EventDAO.getLastID());
				request.setAttribute("packageList", PackageDAO.getAllPackages());
				request.setAttribute("coordinatorList", staffDAO.getAllStaff());
				request.getRequestDispatcher("createEvent.jsp").forward(request, response);
				break;

			case "getBusyStaff":
				String dateBusy = request.getParameter("date");
				List<String> busyStaffIds = EventDAO.getBusyStaffIds(dateBusy);

				// Bina JSON secara manual
				String jsonStaff = "[\"" + String.join("\",\"", busyStaffIds) + "\"]";
				if (busyStaffIds.isEmpty())
					jsonStaff = "[]";

				response.setContentType("application/json");
				response.setCharacterEncoding("UTF-8");
				response.getWriter().write(jsonStaff);
				return;

			case "getEquipment":
				String pID = request.getParameter("packID");
				String eDate = request.getParameter("eventDate");
				List<EventBean> availList = EventDAO.checkEquipmentAvailability(pID, eDate);

				StringBuilder jsonEq = new StringBuilder("[");
				for (int i = 0; i < availList.size(); i++) {
					EventBean eb = availList.get(i);
					// Tambah property "category" dalam JSON
					jsonEq.append(String.format(
							"{\"id\":\"%s\", \"name\":\"%s\", \"qty\":%d, \"avail\":%d, \"serviceSet\":\"%s\", \"eqpFunction\":\"%s\"}",
							eb.getEqpID(), eb.getEqpName(), eb.getTotQtyInUse(), eb.getTotQtyAvailable(),
							eb.getServiceSet(), // Tambah ni (Pastikan ada dalam EventBean)
							eb.getEqpFunction() // Tambah ni (Pastikan ada dalam EventBean)
					));
					if (i < availList.size() - 1)
						jsonEq.append(",");
				}
				jsonEq.append("]");
				response.setContentType("application/json");
				response.getWriter().write(jsonEq.toString());
				return;

			case "checkDateAvailability":
				String d = request.getParameter("date");
				int totalEvents = EventDAO.countEventsByDate(d);
				response.setContentType("text/plain");
				response.getWriter().write(String.valueOf(totalEvents));
				return;

			case "getFullDates":
				List<String> fullDates = EventDAO.getFullDates();
				String jsonDates = "[\"" + String.join("\",\"", fullDates) + "\"]";
				if (fullDates.isEmpty())
					jsonDates = "[]";

				response.setContentType("application/json");
				response.getWriter().write(jsonDates);
				return;

			case "list":
				listEvents(request, response);
				break;

				// Dalam EventController.java (doGet)

			case "delete":
			    deleteEvent(request, response);
			    return; 

			case "edit":
				showEditForm(request, response);
				break;

			case "view":
				viewEventDetails(request, response);
				break;

			default:
				listEvents(request, response);
				break;
			}
		} catch (SQLException ex) {
			throw new ServletException(ex);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// It is safer to use the 'action' parameter if available, otherwise check ID
		String action = request.getParameter("action");
		String eventID = request.getParameter("eventID");

		try {
			if ("add".equals(action)) {
				addEvent(request, response);
			} else if ("update".equals(action)) {
				updateEvent(request, response);
			} else {
				response.sendRedirect("EventController?action=list");
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw new ServletException(e);
		}
	}

	private void listEvents(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, ServletException, IOException {
		List<EventBean> eventList = EventDAO.getAllEvents();
		request.setAttribute("events", eventList);
		request.getRequestDispatcher("viewEventList.jsp").forward(request, response);
	}

	// 2. DELETE a event
	private void deleteEvent(HttpServletRequest request, HttpServletResponse response)
	        throws SQLException, IOException {
	    String eventID = request.getParameter("eventID");

	    try {
	        EventDAO.deleteEvent(eventID);

	        response.setContentType("text/plain");
	        response.setCharacterEncoding("UTF-8");
	        response.setStatus(HttpServletResponse.SC_OK);
	        response.getWriter().write("Success");
	    } catch (Exception e) {
	      
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	        response.getWriter().write("Error: " + e.getMessage());
	        e.printStackTrace();
	    }
	}

	// 3. SHOW edit form for a event
	private void showEditForm(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, ServletException, IOException {

		String eventID = request.getParameter("eventID");
		EventBean existingEvent = EventDAO.getEventById(eventID);

// 1. Data event asal
		request.setAttribute("event", existingEvent);

		// 2. WAJIB: Hantar list package supaya JavaScript boleh kira range Pax
		request.setAttribute("packageList", PackageDAO.getAllPackages());

		// 3. Ambil peralatan asal untuk paparan pertama
		List<EventBean> equipmentList = EventDAO.getEquipmentByPackage(existingEvent.getPackID());
		request.setAttribute("equipmentList", equipmentList);

		request.getRequestDispatcher("UpdateEventDetails.jsp").forward(request, response);
	}

private void viewEventDetails(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, ServletException, IOException {
		String eventID = request.getParameter("eventID");
		EventBean event = EventDAO.getEventById(eventID);
		if (event != null) {
			List<EventBean> equipmentList = EventDAO.getEquipmentByPackage(event.getPackID());
			request.setAttribute("event", event);
			request.setAttribute("equipmentList", equipmentList);
		}
		request.getRequestDispatcher("viewEventDetails.jsp").forward(request, response);
	}

	private void addEvent(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
		String eventID = request.getParameter("eventID");
		String eventName = request.getParameter("eventName");
		String eventDate = request.getParameter("eventDate");
		String eventTime = request.getParameter("eventTime");
		String eventVenue = request.getParameter("eventVenue");
		int eventPax = Integer.parseInt(request.getParameter("eventPax"));
		String eventStatus = request.getParameter("eventStatus");
		String staffID = request.getParameter("staffID");
		String packID = request.getParameter("packID");

		// --- SEMAKAN KESELAMATAN (BACKEND VALIDATION) ---

		// 1. Check Had Syarikat (Max 4)
		if (EventDAO.countEventsByDate(eventDate) >= 4) {
			response.sendRedirect("EventController?action=create&error=limitReached");
			return;
		}

		// 2. Check Staff Busy
		if (EventDAO.isStaffBusy(staffID, eventDate)) {
			response.sendRedirect("EventController?action=create&error=coordBusy");
			return;
		}

		// 3. Check Stok Equipment
		List<EventBean> availCheck = EventDAO.checkEquipmentAvailability(packID, eventDate);
		for (EventBean eq : availCheck) {
			if (eq.getTotQtyAvailable() < eq.getTotQtyInUse()) {
				response.sendRedirect("EventController?action=create&error=outOfStock");
				return;
			}
		}

		// --- PROSES SIMPAN ---
		try {
			EventBean event = new EventBean();
			event.setEventID(eventID);
			event.setEventName(eventName);
			event.setEventDate(java.sql.Date.valueOf(eventDate));
			event.setEventTime(java.sql.Timestamp.valueOf(eventDate + " " + eventTime));
			event.setEventVenue(eventVenue);
			event.setEventPax(eventPax);
			event.setEventStatus(eventStatus);
			event.setStaffID(staffID);
			event.setPackID(packID);

			// Simpan Main Event
			EventDAO.addEvent(event);

			// Simpan Mapping Equipment (Logik sedia ada)
			List<EventBean> requiredEquipment = EventDAO.getEquipmentByPackage(packID);
			for (EventBean eq : requiredEquipment) {
				EventDAO.insertEventEquipment(eventID, eq.getEqpID(), eq.getTotQtyInUse());
			}

			response.sendRedirect("EventController?action=list");
		} catch (IllegalArgumentException e) {
			// Jika format date/time salah
			response.sendRedirect("EventController?action=create&error=invalidFormat");
		}
	}

	private void updateEvent(HttpServletRequest request, HttpServletResponse response)
			throws SQLException, IOException {
		// Ambil data dan update (sama seperti sebelumnya)
		String eventID = request.getParameter("eventID");
		String eventDateStr = request.getParameter("eventDate");
		String eventTimeStr = request.getParameter("eventTime");

		EventBean event = new EventBean();
		event.setEventID(eventID);
		event.setEventName(request.getParameter("eventName"));
		event.setEventDate(java.sql.Date.valueOf(eventDateStr));
		event.setEventTime(java.sql.Timestamp.valueOf(eventDateStr + " " + eventTimeStr));
		event.setEventVenue(request.getParameter("eventVenue"));
		event.setEventPax(Integer.parseInt(request.getParameter("eventPax")));
		event.setEventStatus(request.getParameter("eventStatus"));
		event.setStaffID(request.getParameter("staffID"));
		event.setPackID(request.getParameter("packID"));

		EventDAO.updateEvent(event);
		response.sendRedirect("EventController?action=list");
	}
}