package cems;

import java.sql.Connection;
import java.sql.DriverManager;

public class ConnectionManager {

    private static final String DB_DRIVER = "org.postgresql.Driver";
    private static final String DB_URL =
            "jdbc:postgresql://localhost:5432/cems";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "postgres";

    public static Connection getConnection() {

        Connection conn = null;

        try {
            Class.forName(DB_DRIVER);
            System.out.println("✅ PostgreSQL driver loaded");

            conn = DriverManager.getConnection(
                    DB_URL,
                    DB_USER,
                    DB_PASSWORD
            );

            conn.setAutoCommit(false);
            System.out.println("✅ Database connected");

        } catch (Exception e) {
            System.out.println("❌ DATABASE CONNECTION FAILED");
            e.printStackTrace();
        }

        return conn;
    }
}
