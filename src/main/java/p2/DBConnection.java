package p2;

import java.sql.*;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;

public class DBConnection {
    private static java.sql.Connection connection;

    public static java.sql.Connection getInstance() throws SQLException {
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
