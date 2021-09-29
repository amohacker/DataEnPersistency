package p5.postgres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static Connection connection;

    public static Connection getInstance() throws SQLException {
        if (connection != null) {
            return connection;
        }
        String url = System.getenv("url");
        String username = System.getenv("username");
        String password = System.getenv("password");
        connection = DriverManager.getConnection(url, username, password);
        return connection;
    }

    public static void close() throws SQLException {
        connection.close();
    }
}
