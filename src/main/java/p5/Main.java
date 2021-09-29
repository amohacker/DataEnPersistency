package p5;

import p5.dao.AdresDAO;
import p5.dao.OVChipkaartDAO;
import p5.dao.ProductDAO;
import p5.dao.ReizigerDAO;
import p5.postgres.*;

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
                ProductDAO pdao = new ProductDAOPsql(conn);
                Test test = new Test(rdao, adao, odao, pdao);
                test.testReizigerDAO();
                test.testAdresDAO ();
                test.testOVChipkaartDAO();
                test.testProductDAO();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
