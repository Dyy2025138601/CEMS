package cems;

import java.io.Serializable;

public class SupportEquipment extends Equipment implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String eqpFunction;
	
	public SupportEquipment() {}

	public String getEqpFunction() {
		return eqpFunction;
	}

	public void setEqpFunction(String eqpFuntion) {
		this.eqpFunction = eqpFuntion;
	}
}
