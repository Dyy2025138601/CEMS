package cems;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionManager {
    static Connection con;
    private static final String DB_DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String DB_CONNECTION = "jdbc:oracle:thin:@//localhost:1521/freepdb1";
    private static final String DB_USER = "CEMS";
    private static final String DB_PASSWORD = "oracle";

    public static Connection getConnection() {
        try {
            Class.forName(DB_DRIVER);
            con = DriverManager.getConnection(DB_CONNECTION, DB_USER, DB_PASSWORD);
            con.setAutoCommit(true); // Tukar ke true dulu untuk mudahkan testing data masuk
            System.out.println("Connected successfully.");
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error Connection: " + e.getMessage());
            e.printStackTrace();
        }
        return con;
    }

    // MAIN METHOD MESTI KAT DALAM NI
    public static void main(String[] args) {
        Connection test = ConnectionManager.getConnection();
        if (test != null) {
            System.out.println("Memang cun, connection lepas!");
        } else {
            System.out.println("Masih fail bro.");
        }
    }
}