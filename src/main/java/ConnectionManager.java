package cems;

import java.sql.Connection;
import java.sql.DriverManager;

public class ConnectionManager {

    private static final String DB_DRIVER = "org.postgresql.Driver";

    private static final String DB_URL =
        "jdbc:postgresql://c3v5n5ajfopshl.cluster-czrs8kj4isg7.us-east-1.rds.amazonaws.com:5432/dubdf986cmc3n";

    private static final String DB_USER = "udq3kr6kb5d95m";

    private static final String DB_PASSWORD =
        "p7d05481b5598901f9dc6b0cfefeed76e924796d37cf086fe9a23f6d81e36ee68";

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
            System.out.println("✅ PostgreSQL connected successfully");

        } catch (Exception e) {
            System.out.println("❌ DATABASE CONNECTION FAILED");
            e.printStackTrace();
        }

        return conn;
    }
}
