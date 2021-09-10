package p3;

import p3.dao.AdresDAO;
import p3.dao.ReizigerDAO;
import p3.dao.ReizigerDAOPsql;
import p3.domein.Adres;
import p3.domein.Reiziger;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class Test {
private ReizigerDAO rdao;
private AdresDAO adao;
    public Test(ReizigerDAO rdao, AdresDAO adao) {
        this.rdao = rdao;
        this.adao = adao;
    }
    /**
     * P2. Reiziger DAO: persistentie van een klasse
     *
     * Deze methode test de CRUD-functionaliteit van de Reiziger DAO
     *
     * @throws SQLException
     */
    public void testReizigerDAO() throws SQLException {
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
        Adres huis = new Adres(59, "52AQ", "51", "Janstraat", "Pietersburg");
        sietske.setAdres(huis);
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
        System.out.println();
    }

    public void testAdresDAO() throws SQLException {
        System.out.println("\n---------- Test AdresDAO -------------");

        // Haal alle reizigers op uit de database
        List<Adres> adressen = adao.findAll();
        System.out.println("[Test] AdresDAO.findAll() geeft de volgende adressen:");
        for (Adres a : adressen) {
            System.out.println(a);
        }
        System.out.println();

        // Maak een nieuwe reiziger aan en persisteer deze in de database
        String gbdatum = "1984-01-25";
        Reiziger ben = new Reiziger(83, "B", "", "Paprika", java.sql.Date.valueOf(gbdatum));
        Adres huis = new Adres(59, "52AQ", "51", "Janstraat", "Pietersburg");
        ben.setAdres(huis);
        System.out.print("[Test] Eerst " + adressen.size() + " adressen, na AdresDAO.save() ");
        rdao.save(ben);
        adao.save(huis);

        adressen = adao.findAll();
        System.out.println(adressen.size() + " adressen\n");

        // Voeg aanvullende tests van de ontbrekende CRUD-operaties in.

        Adres huis2 = adao.findById(huis.getId());

        System.out.println("[Test] AdresDAO.findbyID() geeft dit adres: " + huis);
        System.out.println();

        huis.setHuisnummer("42B");
        adao.save(huis);
        System.out.println("[Test] AdresDAO.findbyID() geeft dit adres na update: " + adao.findById(huis.getId()));
        System.out.print("Dit is ");
        if (adao.findById(huis.getId()).toString().equals(huis.toString())) {
            System.out.println("correct.");
        } else {
            System.out.println("onjuist.");
        }
        System.out.println();


        System.out.println("[Test] AdresDAO.findbyReiziger() geeft deze reiziger: " + adao.findByReiziger(ben));
        System.out.println();

        //delete reiziger
        System.out.print("[Test] Eerst " + adressen.size() + " adressen, na AdresDAO.delete() ");
        adao.delete(huis);
        rdao.delete(ben);
        adressen = adao.findAll();
        System.out.println(adressen.size() + " adressen\n");
    }

}
