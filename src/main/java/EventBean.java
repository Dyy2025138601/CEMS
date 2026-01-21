package cems;

import java.sql.Date;
import java.sql.Timestamp;
import java.io.Serializable;

public class EventBean implements Serializable {
    private static final long serialVersionUID = 1L; 

	private String eventID;
	private String eventName;
	private Date eventDate;
	private Timestamp eventTime;
	private String eventVenue;
	private int eventPax;
	private String eventStatus;
	private String staffID;
	private String staffName;
	private String packID;
	private String packName;
	private String eqpID;
	private String eqpName;
	private int totQtyInUse;
	private String serviceSet;
	private String eqpFunction;
	private int LowPackPax;
	private int HighPackPax;
	private int totQtyAvailable;
	
	public String getEventID() {
		return eventID;
	}

	public void setEventID(String eventID) {
		this.eventID = eventID;
	}

	public String getEventName() {
		return eventName;
	}

	public void setEventName(String eventName) {
		this.eventName = eventName;
	}

	public Date getEventDate() {
		return eventDate;
	}

	public void setEventDate(Date eventDate) {
		this.eventDate = eventDate;
	}

	public Timestamp getEventTime() {
		return eventTime;
	}

	public void setEventTime(Timestamp eventTime) {
		this.eventTime = eventTime;
	}

	public String getEventVenue() {
		return eventVenue;
	}

	public void setEventVenue(String eventVenue) {
		this.eventVenue = eventVenue;
	}

	public int getEventPax() {
		return eventPax;
	}

	public void setEventPax(int eventPax) {
		this.eventPax = eventPax;
	}

	public String getEventStatus() {
		return eventStatus;
	}

	public void setEventStatus(String eventStatus) {
		this.eventStatus = eventStatus;
	}

	public String getStaffID() {
		return staffID;
	}

	public void setStaffID(String staffID) {
		this.staffID = staffID;
	}
	public String getStaffName() {
		return staffName;
	}

	public void setStaffName(String staffName) {
		this.staffName = staffName;
	}

	public String getPackID() {
		return packID;
	}

	public void setPackID(String packID) {
		this.packID = packID;
	}

	public String getPackName() {
		return packName;
	}

	public void setPackName(String packName) {
		this.packName = packName;
	}
	public String getEqpID() {
		return eqpID;
	}

	public void setEqpID(String eqpID) {
		this.eqpID = eqpID;
	}

	public String getEqpName() {
		return eqpName;
	}

	public void setEqpName(String eqpName) {
		this.eqpName = eqpName;
	}

	public int getTotQtyInUse() {
		return totQtyInUse;
	}

	public int getLowPackPax() {
		return LowPackPax;
	}

	public void setLowPackPax(int lowPackPax) {
		LowPackPax = lowPackPax;
	}

	public int getHighPackPax() {
		return HighPackPax;
	}

	public void setHighPackPax(int highPackPax) {
		HighPackPax = highPackPax;
	}

	public void setTotQtyInUse(int totQtyInUse) {
		this.totQtyInUse = totQtyInUse;
	}

	public String getServiceSet() {
		return serviceSet;
	}

	public void setServiceSet(String serviceSet) {
		this.serviceSet = serviceSet;
	}

	public String getEqpFunction() {
		return eqpFunction;
	}

	public void setEqpFunction(String eqpFunction) {
		this.eqpFunction = eqpFunction;
	}

	public int getTotQtyAvailable() {
		return totQtyAvailable;
	}

	public void setTotQtyAvailable(int totQtyAvailable) {
		this.totQtyAvailable = totQtyAvailable;
	}

}