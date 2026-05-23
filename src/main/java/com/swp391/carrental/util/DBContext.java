package com.swp391.carrental.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

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
            if (input == null) {
                throw new RuntimeException(
                        "Cannot find db.properties on classpath. "
                        + "Make sure src/main/resources/db.properties exists.");
            }
            props.load(input);

            String server = props.getProperty("db.server", "localhost");
            String port   = props.getProperty("db.port", "1433");
            String dbName = props.getProperty("db.name", "CarRentalDB");
            String user   = props.getProperty("db.user", "car_rental_user");
            String pass   = props.getProperty("db.password", "");
            String encrypt = props.getProperty("db.encrypt", "true");
            String trustCert = props.getProperty("db.trustServerCertificate", "true");

            connectionUrl = "jdbc:sqlserver://" + server + ":" + port
                    + ";databaseName=" + dbName
                    + ";user=" + user
                    + ";password=" + pass
                    + ";encrypt=" + encrypt
                    + ";trustServerCertificate=" + trustCert;

            // Load the SQL Server JDBC driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        } catch (IOException e) {
            throw new RuntimeException("Failed to load db.properties: " + e.getMessage(), e);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                    "SQL Server JDBC driver not found. "
                    + "Make sure mssql-jdbc is in pom.xml dependencies.", e);
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
