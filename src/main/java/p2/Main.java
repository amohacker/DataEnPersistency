package p2;

import java.sql.Connection;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) {
        {
            try {
                Connection conn = DBConnection.getInstance();
                ReizigerDAOPsql daop = new ReizigerDAOPsql(conn);
                Test.testReizigerDAO (daop);
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
