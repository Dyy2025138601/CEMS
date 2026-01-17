package cems;

import java.io.Serializable;

public class EquipmentPackage implements Serializable {
	private static final long serialVersionUID = 1L;

	private String eqpID;
	private String packID;
	private int qtyRequired;
	
	private String eqpName;
	private String packName;
	
	private String serviceSet;
    private String eqpFunction;

	public String getEqpID() {
		return eqpID;
	}

	public void setEqpID(String eqpID) {
		this.eqpID = eqpID;
	}

	public String getPackID() {
		return packID;
	}

	public void setPackID(String packID) {
		this.packID = packID;
	}

	public int getQtyRequired() {
		return qtyRequired;
	}

	public void setQtyRequired(int qtyRequired) {
		this.qtyRequired = qtyRequired;
	}

	public String getEqpName() {
		return eqpName;
	}

	public void setEqpName(String eqpName) {
		this.eqpName = eqpName;
	}

	public String getPackName() {
		return packName;
	}

	public void setPackName(String packName) {
		this.packName = packName;
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
	
	public int getQtyInUse() {
	    return this.qtyRequired; 
	}
}
