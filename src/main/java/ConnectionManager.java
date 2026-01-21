package cems;

import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;

public class ConnectionManager {

    public static Connection getConnection() {

        Connection conn = null;

        try {
            String databaseUrl = System.getenv("DATABASE_URL");

            if (databaseUrl != null) {
                // =====================
                // HEROKU ENVIRONMENT
                // =====================
                URI dbUri = new URI(databaseUrl);

                String username = dbUri.getUserInfo().split(":")[0];
                String password = dbUri.getUserInfo().split(":")[1];

                String dbUrl =
                        "jdbc:postgresql://" +
                        dbUri.getHost() +
                        ":" + dbUri.getPort() +
                        dbUri.getPath() +
                        "?sslmode=require";

                conn = DriverManager.getConnection(dbUrl, username, password);

                System.out.println("✅ Connected to Heroku PostgreSQL");

            } else {
                // =====================
                // LOCAL DEVELOPMENT
                // =====================
                String dbUrl = "jdbc:postgresql://localhost:5432/cems";
                String user = "postgres";
                String pass = "postgres";

                conn = DriverManager.getConnection(dbUrl, user, pass);

                System.out.println("✅ Connected to Local PostgreSQL");
            }

            conn.setAutoCommit(true);

        } catch (Exception e) {
            System.out.println("❌ DATABASE CONNECTION FAILED");
            e.printStackTrace();
        }

        return conn;
    }
}
