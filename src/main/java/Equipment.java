package cems;

import java.io.Serializable;

public class Equipment implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String eqpID;
    private String eqpName;
    private int eqpQty;
    private int totQtyInUse;
    private int totQtyAvailable;
    private int eqpTotQty;
    private int eqpTotDamage;
    private int eqpTotLost;
    private String eqpImage;
    private String staffID;

    public Equipment() {}

    // Getters and Setters
    public String getEqpID() { return eqpID; }
    public void setEqpID(String eqpID) { this.eqpID = eqpID; }

    public String getEqpName() { return eqpName; }
    public void setEqpName(String eqpName) { this.eqpName = eqpName; }

    public int getEqpQty() { return eqpQty; }
    public void setEqpQty(int eqpQty) { this.eqpQty = eqpQty; }

    public int getTotQtyInUse() { return totQtyInUse; }
    public void setTotQtyInUse(int totQtyInUse) { this.totQtyInUse = totQtyInUse; }

    public int getTotQtyAvailable() { return totQtyAvailable; }
    public void setTotQtyAvailable(int totQtyAvailable) { this.totQtyAvailable = totQtyAvailable; }

    public int getEqpTotQty() { return eqpTotQty; }
    public void setEqpTotQty(int eqpTotQty) { this.eqpTotQty = eqpTotQty; }

    public int getEqpTotDamage() { return eqpTotDamage; }
    public void setEqpTotDamage(int eqpTotDamage) { this.eqpTotDamage = eqpTotDamage; }

    public int getEqpTotLost() { return eqpTotLost; }
    public void setEqpTotLost(int eqpTotLost) { this.eqpTotLost = eqpTotLost; }

    public String getEqpImage() { return eqpImage; }
    public void setEqpImage(String eqpImage) { this.eqpImage = eqpImage; }

    public String getStaffID() { return staffID; }
    public void setStaffID(String staffID) { this.staffID = staffID; }
    
}