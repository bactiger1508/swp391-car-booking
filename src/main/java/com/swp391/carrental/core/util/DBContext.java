package com.swp391.carrental.core.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import com.swp391.carrental.user.model.User;

/*
 * Name: DBContext
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles business logic and operations for DBContext.
 */


/**
 * Database connection utility.
 * Loads configuration from db.properties on the classpath
 * and provides SQL Server connections via JDBC.
 */
public class DBContext {

    private static final Properties props = new Properties();
    private static String connectionUrl;

    static {
        try (InputStream input = DBContext.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input != null) {
                props.load(input);
            } else {
                System.out.println("Warning: db.properties not found on classpath, relying entirely on Environment Variables.");
            }

            String server = System.getenv("DB_SERVER") != null ? System.getenv("DB_SERVER") : props.getProperty("db.server", "localhost");
            String port   = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : props.getProperty("db.port", "1433");
            String dbName = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : props.getProperty("db.name", "CarRentalDB");
            String user   = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : props.getProperty("db.user", "sa");
            String pass   = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : props.getProperty("db.password", "123");
            String encrypt = System.getenv("DB_ENCRYPT") != null ? System.getenv("DB_ENCRYPT") : props.getProperty("db.encrypt", "true");
            String trustCert = System.getenv("DB_TRUST_CERT") != null ? System.getenv("DB_TRUST_CERT") : props.getProperty("db.trustServerCertificate", "true");

            connectionUrl = "jdbc:sqlserver://" + server + ":" + port
                    + ";databaseName=" + dbName
                    + ";user=" + user
                    + ";password=" + pass
                    + ";encrypt=" + encrypt
                    + ";trustServerCertificate=" + trustCert;

            // Load the SQL Server JDBC driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        } catch (IOException e) {
            System.err.println("Warning: Failed to load db.properties: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("SQL Server JDBC Driver not found.", e);
        }
    }

    /**
     * Returns a new database connection.
     * Callers are responsible for closing the connection.
     *
     * @return a java.sql.Connection to CarRentalDB
     * @throws SQLException if a connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(connectionUrl);
            return conn;
        } catch (SQLException e) {
            throw new SQLException(
                    "Failed to connect to database. Check your SQL Server is running "
                    + "and db.properties is configured correctly. Error: " + e.getMessage(), e);
        }
    }
}
