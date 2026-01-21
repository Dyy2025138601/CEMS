package cems;

import java.io.Serializable;

public class EventEquipment implements Serializable {
	private static final long serialVersionUID = 1L;

	private String eventID;
	private String eqpID;
	private int qtyInUse;
	private char returnStatus;
	private int qtyReturn;
	private int qtyLost;
	private int qtyDamage;
	
	private String eqpName;
	private String serviceSet;
	private String eqpFunction;

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
	
	public int getQtyReturn() {
		return qtyReturn;
	}

	public void setQtyReturn(int qtyReturn) {
		this.qtyReturn = qtyReturn;
	}

	public int getQtyLost() {
		return qtyLost;
	}

	public void setQtyLost(int qtyLost) {
		this.qtyLost = qtyLost;
	}

	public int getQtyDamage() {
		return qtyDamage;
	}

	public void setQtyDamage(int qtyDamage) {
		this.qtyDamage = qtyDamage;
	}

	public String getEqpName() {
		return eqpName;
	}

	public String getServiceSet() {
		return serviceSet;
	}

	public String getEqpFunction() {
		return eqpFunction;
	}

	public void setEqpName(String eqpName) {
		this.eqpName = eqpName;
	}

	public void setServiceSet(String serviceSet) {
		this.serviceSet = serviceSet;
	}

	public void setEqpFunction(String eqpFunction) {
		this.eqpFunction = eqpFunction;
	}

}
