package cems;

import java.io.Serializable;
import java.sql.Date;

public class EventEquipment implements Serializable {
	private static final long serialVersionUID = 1L;

	private String eventID;
	private String eqpID;
	private int qtyInUse;
	private char returnStatus;
	private Date returnDate;
	private int qtyReturn;
	private int qtyNotReturn;

	public String getEventID() {
		return eventID;
	}

	public void setEventID(String eventID) {
		this.eventID = eventID;
	}

	public String getEqpID() {
		return eqpID;
	}

	public void setEqpID(String eqpID) {
		this.eqpID = eqpID;
	}

	public int getQtyInUse() {
		return qtyInUse;
	}

	public void setQtyInUse(int qtyInUse) {
		this.qtyInUse = qtyInUse;
	}

	public char getReturnStatus() {
		return returnStatus;
	}

	public void setReturnStatus(char returnStatus) {
		this.returnStatus = returnStatus;
	}

	public Date getReturnDate() {
		return returnDate;
	}

	public void setReturnDate(Date returnDate) {
		this.returnDate = returnDate;
	}

	public int getQtyReturn() {
		return qtyReturn;
	}

	public void setQtyReturn(int qtyReturn) {
		this.qtyReturn = qtyReturn;
	}

	public int getQtyNotReturn() {
		return qtyNotReturn;
	}

	public void setQtyNotReturn(int qtyNotReturn) {
		this.qtyNotReturn = qtyNotReturn;
	}

}
