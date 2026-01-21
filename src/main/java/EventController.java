package cems;

import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/EventController")
public class EventController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public EventController() {
        super();
    }

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
                return;
                
            case "getAvailableCoordinators":
                String dateForCoord = request.getParameter("date");
                
                // Call DAO to get only staff who are NOT busy on this date
                List<staffBean> availableStaff = EventDAO.getAvailableCoordinators(dateForCoord);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Manually construct JSON: [{"staffID":"S01", "staffName":"Ali"}, ...]
                StringBuilder jsonCoord = new StringBuilder("[");
                for (int i = 0; i < availableStaff.size(); i++) {
                    staffBean s = availableStaff.get(i);
                    jsonCoord.append(String.format("{\"staffID\":\"%s\", \"staffName\":\"%s\"}", 
                        s.getStaffID(), s.getStaffName()));
                    
                    if (i < availableStaff.size() - 1) {
                        jsonCoord.append(",");
                    }
                }
                jsonCoord.append("]");
                
                response.getWriter().write(jsonCoord.toString());
                return;
                
            case "getBusyStaff":
                String dateBusy = request.getParameter("date");
                List<String> busyStaffIds = EventDAO.getBusyStaffIds(dateBusy);
                String jsonStaff = "[\"" + String.join("\",\"", busyStaffIds) + "\"]";
                if (busyStaffIds.isEmpty()) jsonStaff = "[]";
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(jsonStaff);
                return;

            case "getEquipment":
                String pID = request.getParameter("packID");
                String eDate = request.getParameter("eventDate");
                String paxStr = request.getParameter("pax");
                int currentPax = (paxStr != null && !paxStr.isEmpty()) ? Integer.parseInt(paxStr) : 0;
                
                List<EventBean> availList = EventDAO.checkEquipmentAvailability(pID, eDate, currentPax);
                
                StringBuilder jsonEq = new StringBuilder("[");
                for (int i = 0; i < availList.size(); i++) {
                    EventBean eb = availList.get(i);
                    
                    jsonEq.append("{");
                    jsonEq.append("\"id\":\"").append(eb.getEqpID()).append("\",");
                    jsonEq.append("\"name\":\"").append(eb.getEqpName()).append("\",");
                    jsonEq.append("\"qty\":").append(eb.getTotQtyInUse()).append(",");
                    jsonEq.append("\"avail\":").append(eb.getTotQtyAvailable()).append(",");
                    
                    String sSet = (eb.getServiceSet() == null) ? "-" : eb.getServiceSet();
                    String eFunc = (eb.getEqpFunction() == null) ? "-" : eb.getEqpFunction();
                    
                    jsonEq.append("\"serviceSet\":\"").append(sSet).append("\",");
                    jsonEq.append("\"eqpFunction\":\"").append(eFunc).append("\"");
                    
                    jsonEq.append("}");
                    
                    if (i < availList.size() - 1) jsonEq.append(",");
                }
                jsonEq.append("]");
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
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
                if (fullDates.isEmpty()) jsonDates = "[]";
                response.setContentType("application/json");
                response.getWriter().write(jsonDates);
                return;

            case "list":
                listEvents(request, response);
                return;

            case "delete":
                deleteEvent(request, response);
                return;

            case "edit":
                showEditForm(request, response);
                return;

            case "view":
                viewEventDetails(request, response);
                return;

            case "viewReturnForm":
                String rEventID = request.getParameter("eventID");
                List<EventEquipment> rEquipmentList = EventDAO.getEventEquipmentList(rEventID);
                
                if (rEquipmentList == null || rEquipmentList.isEmpty()) {
                    EventBean event = EventDAO.getEventById(rEventID);
                    List<EventBean> formulaItems = EventDAO.getEquipmentByPackage(event.getPackID(), event.getEventPax());
                    
                    rEquipmentList = new ArrayList<>();
                    for (EventBean eb : formulaItems) {
                        EventEquipment ee = new EventEquipment();
                        ee.setEventID(rEventID);
                        ee.setEqpID(eb.getEqpID());
                        ee.setEqpName(eb.getEqpName());
                        ee.setQtyInUse(eb.getTotQtyInUse()); 
                        ee.setQtyReturn(0); 
                        ee.setQtyDamage(0);
                        ee.setQtyLost(0);
                        ee.setServiceSet(eb.getServiceSet());
                        ee.setEqpFunction(eb.getEqpFunction());
                        rEquipmentList.add(ee);
                    }
                }
                java.time.LocalDate today = java.time.LocalDate.now();
                request.setAttribute("equipmentList", rEquipmentList);
                request.setAttribute("eventID", rEventID);
                request.setAttribute("displayReturnDate", today);
                request.getRequestDispatcher("returnEquipment.jsp").forward(request, response);
                return;

            case "listCoordinatorEvents":
                listCoordinatorEvents(request, response);
                return;

            case "viewCoordinatorEvent":
                viewCoordinatorEventDetails(request, response);
                return;

            case "dashboard":
                // 1. Data Ringkasan
                request.setAttribute("pendingCount", EventDAO.getPendingReturnsCount());
                request.setAttribute("eventCount", EventDAO.getTotalEventsCount());
                request.setAttribute("eqpCount", EquipmentDAO.getTotalEquipmentCount());
                request.setAttribute("returnRate", String.format("%.1f", EventDAO.getPendingReturnRate()));
                request.setAttribute("eventGrowth", String.format("%.1f", EventDAO.getEventGrowthRate()));
                request.setAttribute("lossRate", String.format("%.1f", EquipmentDAO.getEquipmentLossRate()));
                
                // 2. Data Chart Peralatan dengan Extra Safety
                String rawChartData = EquipmentDAO.getCategorizedConditionStats();
                
                // Inisialisasi nilai default jika data kosong supaya JSP tidak crash
                request.setAttribute("chartLabels", "");
                request.setAttribute("chartGood", "0");
                request.setAttribute("chartDamaged", "0");
                request.setAttribute("chartLost", "0");

                if (rawChartData != null && rawChartData.contains("|")) {
                    String[] parts = rawChartData.split("\\|");
                    // Pastikan array 'parts' mempunyai sekurang-kurangnya 4 elemen sebelum akses
                    if (parts.length >= 4) {
                        request.setAttribute("chartLabels", parts[0]);
                        request.setAttribute("chartGood", parts[1]);
                        request.setAttribute("chartDamaged", parts[2]);
                        request.setAttribute("chartLost", parts[3]);
                    }
                }
                
                // 3. Data Chart Status Event
                int[] evStats = EventDAO.getEventStatusStats();
                // Safety check jika array evStats kosong
                if (evStats != null && evStats.length >= 3) {
                    request.setAttribute("evChartData", evStats[0] + "," + evStats[1] + "," + evStats[2]);
                } else {
                    request.setAttribute("evChartData", "0,0,0");
                }
                
                // 4. List Upcoming Events
                List<EventBean> upcoming = EventDAO.getUpcomingEvents();
                if (upcoming == null) {
                    upcoming = new ArrayList<>();
                }
                request.setAttribute("events", upcoming);
                
                request.getRequestDispatcher("dashboardManager.jsp").forward(request, response);
                return;
                
            case "dashboardCoordinator":
                HttpSession session = request.getSession();
                staffBean currentStaff = (staffBean) session.getAttribute("staff");
                if (currentStaff != null) {
                    String sID = currentStaff.getStaffID();
                    request.setAttribute("pendingCount", EventDAO.getPendingReturnsByStaff(sID));
                    request.setAttribute("eventCount", EventDAO.getEventCountByStaff(sID));
                    request.setAttribute("evChartData", EventDAO.getEvChartDataByStaff(sID));
                    List<EventBean> myEvents = EventDAO.getUpcomingEventsByStaff(sID);
                    request.setAttribute("assignedEvents", myEvents);
                    double returnRateCoord = EventDAO.getReturnRateByStaffMonth(sID);
                    double growthRateCoord = EventDAO.getEventGrowthByStaffMonth(sID);
                    request.setAttribute("returnRate", String.format("%.1f", returnRateCoord));
                    request.setAttribute("eventGrowth", String.format("%.1f", growthRateCoord));
                    request.getRequestDispatcher("dashboardCoordinator.jsp").forward(request, response);
                } else {
                    response.sendRedirect("login.jsp");
                }
                return;
                
            case "generateReport":
                String start = request.getParameter("startDate");
                String end = request.getParameter("endDate");
                try {
                    List<EventBean> eventList = EventDAO.getEventReport(start, end);
                    int totalItems = eventList.size();
                    long totalGuests = 0;
                    List<Map<String, Object>> details = new ArrayList<>();
                    for (EventBean e : eventList) {
                        totalGuests += e.getEventPax();
                        Map<String, Object> row = new HashMap<>();
                        row.put("id", e.getEventID());
                        row.put("date", new java.text.SimpleDateFormat("yyyy/MM/dd").format(e.getEventDate()));
                        row.put("time", new java.text.SimpleDateFormat("hh:mm a").format(e.getEventTime()));
                        row.put("pax", e.getEventPax());
                        row.put("venue", e.getEventVenue());
                        row.put("coordinator", e.getStaffName());
                        row.put("issues", EventDAO.getIssuesForEvent(e.getEventID()));
                        details.add(row);
                    }
                    Map<String, Object> reportData = new HashMap<>();
                    reportData.put("totalItems", totalItems);
                    reportData.put("totalGuests", totalGuests);
                    reportData.put("details", details);
                    request.setAttribute("reportData", reportData);
                    request.setAttribute("startDate", start);
                    request.setAttribute("endDate", end);
                    request.setAttribute("reportType", "Event");
                    request.getRequestDispatcher("viewReport.jsp").forward(request, response);
                } catch (SQLException e) {
                    throw new ServletException(e);
                }
                return;

            default:
                listEvents(request, response);
                return;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                addEvent(request, response);
            } else if ("update".equals(action)) {
                updateEvent(request, response);
            } else if ("returnEquipment".equals(action)) {
                processEquipmentReturn(request, response);
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
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String eventID = request.getParameter("eventID");
        EventBean existingEvent = EventDAO.getEventById(eventID);
        request.setAttribute("event", existingEvent);
        request.setAttribute("packageList", PackageDAO.getAllPackages());
        List<EventBean> equipmentList = EventDAO.getEquipmentByPackage(existingEvent.getPackID(), existingEvent.getEventPax());
        request.setAttribute("equipmentList", equipmentList);
        request.getRequestDispatcher("UpdateEventDetails.jsp").forward(request, response);
    }

    private void viewEventDetails(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String eventID = request.getParameter("eventID");
        EventBean event = EventDAO.getEventById(eventID);
        if (event != null) {
            List<EventBean> equipmentList = EventDAO.getEquipmentByPackage(event.getPackID(), event.getEventPax());
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
        String paxStr = request.getParameter("eventPax");
        int eventPax = (paxStr != null && !paxStr.isEmpty()) ? Integer.parseInt(paxStr) : 0;
        String eventStatus = request.getParameter("eventStatus");
        String staffID = request.getParameter("staffID");
        String packID = request.getParameter("packID");

        try {
            // 1. Daily Event Limit Check
            if (EventDAO.countEventsByDate(eventDate) >= 4) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Limit Reached");
                return;
            }

            // 2. Equipment Availability Validation
            List<EventBean> requiredEquipment = EventDAO.getEquipmentByPackage(packID, eventPax);
            EquipmentDAO eqDAO = new EquipmentDAO(); 

            for (EventBean eq : requiredEquipment) {
                String eqpID = eq.getEqpID();
                int qtyNeeded = eq.getTotQtyInUse(); 
                int totalStock = eqDAO.getEquipmentStock(eqpID);
                int currentlyBooked = eqDAO.getBookedQtyOnDate(eqpID, eventDate);
                int available = totalStock - currentlyBooked;

                if (qtyNeeded > available) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("Shortage: Item ID " + eqpID + " only has " + available + " left.");
                    return; 
                }
            }

            // 3. Save Event
            EventBean event = new EventBean();
            event.setEventID(eventID);
            event.setEventName(eventName);
            event.setEventDate(java.sql.Date.valueOf(eventDate));
            String fullTime = (eventTime.length() == 5) ? eventTime + ":00" : eventTime;
            event.setEventTime(java.sql.Timestamp.valueOf(eventDate + " " + fullTime));
            event.setEventVenue(eventVenue);
            event.setEventPax(eventPax);
            event.setEventStatus(eventStatus);
            event.setStaffID(staffID);
            event.setPackID(packID);

            EventDAO.addEvent(event);

            // 4. Save Equipment List
            for (EventBean eq : requiredEquipment) {
                EventDAO.insertEventEquipment(eventID, eq.getEqpID(), eq.getTotQtyInUse());
            }

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Success");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error: " + e.getMessage());
        }
    }

    private void updateEvent(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        try {
            String eventID = request.getParameter("eventID");
            String eventDateStr = request.getParameter("eventDate");
            String eventTimeStr = request.getParameter("eventTime");
            EventBean event = new EventBean();
            event.setEventID(eventID);
            event.setEventName(request.getParameter("eventName"));
            event.setEventDate(java.sql.Date.valueOf(eventDateStr));
            String fullTime = (eventTimeStr.length() == 5) ? eventTimeStr + ":00" : eventTimeStr;
            event.setEventTime(java.sql.Timestamp.valueOf(eventDateStr + " " + fullTime));
            event.setEventVenue(request.getParameter("eventVenue"));
            event.setEventPax(Integer.parseInt(request.getParameter("eventPax")));
            event.setEventStatus(request.getParameter("eventStatus"));
            event.setStaffID(request.getParameter("staffID"));
            event.setPackID(request.getParameter("packID"));
            EventDAO.updateEvent(event);
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Success");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void listCoordinatorEvents(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        HttpSession session = request.getSession(false);
        staffBean staff = (session != null) ? (staffBean) session.getAttribute("staff") : null;
        if (staff == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String staffID = staff.getStaffID();
        EventDAO eventDao = new EventDAO();
        List<EventBean> eventList = eventDao.getEventsByStaff(staffID);
        request.setAttribute("eventList", eventList);
        request.getRequestDispatcher("viewAssignedList.jsp").forward(request, response);
    }

    private void viewCoordinatorEventDetails(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        HttpSession session = request.getSession(false);
        staffBean currentStaff = (session != null) ? (staffBean) session.getAttribute("staff") : null;

        if (currentStaff == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String eventID = request.getParameter("eventID");
        EventBean event = EventDAO.getEventById(eventID);

        if (event == null) {
            response.sendRedirect("EventController?action=listCoordinatorEvents&error=notfound");
            return;
        }

        List<EventEquipment> equipmentList = EventDAO.getEventEquipmentList(eventID);
        
        if (equipmentList == null || equipmentList.isEmpty()) {
            List<EventBean> formulaItems = EventDAO.getEquipmentByPackage(event.getPackID(), event.getEventPax());
            equipmentList = new ArrayList<>();
            for (EventBean eb : formulaItems) {
                EventEquipment ee = new EventEquipment();
                ee.setEventID(eventID);
                ee.setEqpID(eb.getEqpID());
                ee.setEqpName(eb.getEqpName());
                ee.setQtyInUse(eb.getTotQtyInUse()); 
                ee.setQtyReturn(eb.getTotQtyInUse()); 
                ee.setServiceSet(eb.getServiceSet());
                ee.setEqpFunction(eb.getEqpFunction());
                equipmentList.add(ee);
            }
        }
        request.setAttribute("event", event);
        request.setAttribute("equipmentList", equipmentList);
        request.getRequestDispatcher("viewAssignedDetails.jsp").forward(request, response);
    }
    
    private void processEquipmentReturn(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String eventID = request.getParameter("eventID");
        String[] eqpIDs = request.getParameterValues("eqpID");
        String[] qtyInUses = request.getParameterValues("qtyInUse");
        String[] qtyReturns = request.getParameterValues("qtyReturn");
        String[] qtyLosts = request.getParameterValues("qtyLost");
        String[] qtyDamages = request.getParameterValues("qtyDamage");
        
        EventDAO eventDAO = new EventDAO();
        boolean allSuccess = true;

        if (eqpIDs != null) {
            for (int i = 0; i < eqpIDs.length; i++) {
                String currentEqpID = eqpIDs[i];
                if (currentEqpID == null || currentEqpID.trim().isEmpty()) continue; 

                EventEquipment data = new EventEquipment();
                data.setEventID(eventID);
                data.setEqpID(currentEqpID);
                data.setQtyInUse(safeGet(qtyInUses, i));
                data.setQtyReturn(safeGet(qtyReturns, i));
                data.setQtyLost(safeGet(qtyLosts, i));
                data.setQtyDamage(safeGet(qtyDamages, i));

                if (!eventDAO.processEquipmentReturn(data)) {
                    allSuccess = false;
                }
            }
        }

        if (allSuccess) {
            EventDAO.finalizeEventReturn(eventID);
            response.sendRedirect("EventController?action=listCoordinatorEvents&status=success");
        } else {
            response.sendRedirect("EventController?action=viewReturnForm&eventID=" + eventID + "&error=db_fail");
        }
    }

    private int safeGet(String[] array, int index) {
        if (array != null && index < array.length) {
            String val = array[index];
            if (val != null && !val.trim().isEmpty()) {
                try {
                    return Integer.parseInt(val.trim());
                } catch (NumberFormatException e) {
                    return 0;
                }
            }
        }
        return 0;
    }
}