package cems;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionManager {

    static Connection con;

    // PostgreSQL Driver
    private static final String DB_DRIVER = "org.postgresql.Driver";

    // AWS RDS PostgreSQL connection
    private static final String DB_CONNECTION =
            "jdbc:postgresql://c3v5n5ajfopshl.cluster-czr8kj4isg7.us-east-1.rds.amazonaws.com:5432/dubdf986cmc3n";

    private static final String DB_USER = "udq3kr6kb5d95m";
    private static final String DB_PASSWORD = "p7d05481b5598901f9dc6b0cfeeed76e924796d37cf086fe9a23f6d81e36ee68";

    public static Connection getConnection() {
        try {
            Class.forName(DB_DRIVER);

            con = DriverManager.getConnection(
                    DB_CONNECTION,
                    DB_USER,
                    DB_PASSWORD
            );

            con.setAutoCommit(false);

            System.out.println("✅ Connected to PostgreSQL (AWS RDS)");

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }

        return con;
    }
}
