package p2;

import p2.Reiziger;
import p2.ReizigerDAO;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class Test {

    /**
     * P2. Reiziger DAO: persistentie van een klasse
     *
     * Deze methode test de CRUD-functionaliteit van de Reiziger DAO
     *
     * @throws SQLException
     */
    public static void testReizigerDAO(ReizigerDAO rdao) throws SQLException {
        System.out.println("\n---------- Test ReizigerDAO -------------");

        // Haal alle reizigers op uit de database
        List<Reiziger> reizigers = rdao.findAll();
        System.out.println("[Test] ReizigerDAO.findAll() geeft de volgende reizigers:");
        for (Reiziger r : reizigers) {
            System.out.println(r);
        }
        System.out.println();

        // Maak een nieuwe reiziger aan en persisteer deze in de database
        String gbdatum = "1981-03-14";
        Reiziger sietske = new Reiziger(77, "S", "", "Boers", java.sql.Date.valueOf(gbdatum));
        System.out.print("[Test] Eerst " + reizigers.size() + " reizigers, na ReizigerDAO.save() ");
        rdao.save(sietske);
        reizigers = rdao.findAll();
        System.out.println(reizigers.size() + " reizigers\n");

        // Voeg aanvullende tests van de ontbrekende CRUD-operaties in.

        //findbyGBdatum
        reizigers = rdao.findByGbdatum(gbdatum);
        System.out.println("[Test] ReizigerDAO.findbyGBdatum() geeft de volgende reizigers:");
        for (Reiziger r : reizigers) {
            System.out.println(r);
        }
        System.out.println();
        reizigers = rdao.findAll();

        System.out.println("[Test] ReizigerDAO.findbyID() geeft deze reiziger: " + rdao.findById(sietske.getId()));
        System.out.println();

        //delete reiziger
        System.out.print("[Test] Eerst " + reizigers.size() + " reizigers, na ReizigerDAO.delete() ");
        rdao.delete(sietske);
        reizigers = rdao.findAll();
        System.out.println(reizigers.size() + " reizigers\n");
    }
}
