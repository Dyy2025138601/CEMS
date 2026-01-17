package cems;

import java.io.Serializable;
import java.util.List;

public class PackageCatering implements Serializable{
	private static final long serialVersionUID = 1L;
	private String packID;
	private String packName;
	private int lowPackPax;
	private int highPackPax;
	private char packAvailability;
	private char companyAvailability;
	
	public PackageCatering() {}

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
	
	public int getLowPackPax() {
		return lowPackPax;
	}
	
	public void setLowPackPax(int lowPackPax) {
		this.lowPackPax = lowPackPax;
	}
	
	public int getHighPackPax() {
		return highPackPax;
	}
	
	public void setHighPackPax(int highPackPax) {
		this.highPackPax = highPackPax;
	}
	
	public char getPackAvailability() {
		return packAvailability;
	}
	
	public void setPackAvailability(char packAvailability) {
		this.packAvailability = packAvailability;
	}
	
	public char getCompanyAvailability() {
		return companyAvailability;
	}
	
	public void setCompanyAvailability(char companyAvailability) {
		this.companyAvailability = companyAvailability;
	}
	
	//for event
	private List<EquipmentPackage> equipmentList;

    public List<EquipmentPackage> getEquipmentList() {
        return equipmentList;
    }

    public void setEquipmentList(List<EquipmentPackage> equipmentList) {
        this.equipmentList = equipmentList;
    }
}
