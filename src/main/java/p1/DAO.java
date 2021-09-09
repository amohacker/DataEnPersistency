package p1;

import java.sql.*;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;

public class DAO {
    private static Connection connection;

    public static Connection getConnection() throws SQLException {
        if (connection != null) {
            return connection;
        }
        String url = System.getenv("url");
        String username = System.getenv("username");
        String password = System.getenv("password");
        connection = DriverManager.getConnection(url, username, password);
        return connection;
    }

    public static ArrayList getAlleReizigers() throws SQLException {
        Connection conn = getConnection();
        Statement st = connection.createStatement();

        ResultSet rs = st.executeQuery("select * from reiziger");

        ArrayList<Hashtable> array = new ArrayList<>();
        while (rs.next()) {
            Hashtable<String, String> row = new Hashtable<>();
            row.put("reiziger_id", rs.getString("reiziger_id"));
            row.put("voorletters", rs.getString("voorletters"));
            try {
                row.put("tussenvoegsel", rs.getString("tussenvoegsel"));
            } catch (NullPointerException e){
                row.put("tussenvoegsel", "");
            }
            row.put("achternaam", rs.getString("achternaam"));
            try {
                row.put("geboortedatum", rs.getString("geboortedatum"));
            } catch (NullPointerException e) {
                row.put("geboortedatum", "");
            }
            array.add(row);
        }
        return array;
    }
}
