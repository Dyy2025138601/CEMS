package cems;

import java.io.Serializable;

public class staffBean implements Serializable {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	// 1. Private attributes
    private String staffID;
    private String staffName;
    private String staffEmail;
    private String staffPhoneNum;
    private String staffPassword;
    private String staffRole;
    private String managerId;

    // 2. Default Constructor
    public staffBean() {
    }

    // 3. Parameterized Constructor
    public staffBean(String staffID, String staffName, String staffEmail, String staffPhoneNum, 
                 String staffPassword, String staffRole) {
    	this.staffID = staffID;
    	this.staffName = staffName;
        this.staffEmail = staffEmail;
        this.staffPhoneNum = staffPhoneNum;
        this.staffPassword = staffPassword;
        this.staffRole = staffRole;
    }

    // 4. Getters and Setters
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

    public String getStaffEmail() {
        return staffEmail;
    }

    public void setStaffEmail(String staffEmail) {
        this.staffEmail = staffEmail;
    }

    public String getStaffPhoneNum() {
        return staffPhoneNum;
    }

    public void setStaffPhoneNum(String staffPhoneNum) {
        this.staffPhoneNum = staffPhoneNum;
    }

    public String getStaffPassword() {
        return staffPassword;
    }

    public void setStaffPassword(String staffPassword) {
        this.staffPassword = staffPassword;
    }

    public String getStaffRole() {
        return staffRole;
    }

    public void setStaffRole(String staffRole) {
        this.staffRole = staffRole;
    }

    public String getManagerId() {
        return managerId;
    }

    public void setManagerId(String managerId) {
        this.managerId = managerId;
    }

	public String hashedPassword() {
		// TODO Auto-generated method stub
		return null;
	}
}