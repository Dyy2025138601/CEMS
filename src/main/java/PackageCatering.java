package cems;

import java.io.Serializable;
import java.util.List;

public class PackageCatering implements Serializable {
    private static final long serialVersionUID = 1L;
    private String packID;
    private String packName;
    private int lowPackPax;
    private int highPackPax;
    private char packAvailability;
    private char companyAvailability;
    
    // For date-specific checks
    private String availabilityOnDate;
    
    // For event details (optional)
    private List<EquipmentPackage> equipmentList;

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
    
    public List<EquipmentPackage> getEquipmentList() {
        return equipmentList;
    }

    public void setEquipmentList(List<EquipmentPackage> equipmentList) {
        this.equipmentList = equipmentList;
    }
    
    // --- HELPER METHOD FOR JSP ---
    // Use this in JSP: ${p.availabilityString}
    public String getAvailabilityString() {
        return String.valueOf(this.packAvailability);
    }
    
    public String getAvailabilityOnDate() {
        return availabilityOnDate;
    }

    public void setAvailabilityOnDate(String availabilityOnDate) {
        this.availabilityOnDate = availabilityOnDate;
    }
}