package cems;

import java.io.Serializable;

public class ServiceEquipment extends Equipment implements Serializable{
	private static final long serialVersionUID = 1L;
	
	private String serviceSet;
	
	public ServiceEquipment() {}

	public String getServiceSet() {
		return serviceSet;
	}

	public void setServiceSet(String serviceSet) {
		this.serviceSet = serviceSet;
	}
	
}
