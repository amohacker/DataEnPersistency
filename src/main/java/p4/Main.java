package p4;

import p4.dao.*;
import p4.postgres.AdresDAOPsql;
import p4.postgres.DBConnection;
import p4.postgres.OVChipkaartDAOPsql;
import p4.postgres.ReizigerDAOPsql;

import java.sql.Connection;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) {
        {
            try {
                Connection conn = DBConnection.getInstance();
                ReizigerDAO rdao = new ReizigerDAOPsql(conn);
                AdresDAO adao = new AdresDAOPsql(conn);
                OVChipkaartDAO odao = new OVChipkaartDAOPsql(conn);
                Test test = new Test(rdao, adao, odao);
                test.testReizigerDAO();
                test.testAdresDAO ();
                test.testOVChipkaartDAO();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
