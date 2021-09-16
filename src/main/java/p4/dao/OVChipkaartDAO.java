package p4.dao;

import p4.domein.OVChipkaart;
import p4.domein.Reiziger;

import java.sql.SQLException;
import java.util.List;

public interface OVChipkaartDAO {
    List<OVChipkaart> findByReiziger(Reiziger reiziger);
    boolean save(OVChipkaart ovChipkaart);
    boolean update(Reiziger reiziger);  // mogelijke aanpakken, lijst van alle ov's ophalen, de lijst vergelijken met de lokale lijst en dan alle ov's verwijderen die niet in de lijst staan
                                        // delete where reiziger_id = reizigerid and not kaart_nummer in (kaartnummer, andere kaartnummers)
    boolean update(OVChipkaart ovChipkaart);
    boolean delete(OVChipkaart ovChipkaart);
    OVChipkaart findByID(int id);
    List<OVChipkaart> findAll() throws SQLException;
}
