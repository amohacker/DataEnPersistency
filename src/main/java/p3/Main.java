package p3;

import p3.dao.AdresDAOPsql;
import p3.dao.DBConnection;
import p3.dao.ReizigerDAOPsql;

import java.sql.Connection;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) {
        {
            try {
                Connection conn = DBConnection.getInstance();
                ReizigerDAOPsql rdao = new ReizigerDAOPsql(conn);
                AdresDAOPsql adao = new AdresDAOPsql(conn);
                Test test = new Test(rdao, adao);
                test.testReizigerDAO();
                test.testAdresDAO ();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
