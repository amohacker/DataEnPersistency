package p3.dao;

import p3.domein.Adres;
import p3.domein.Reiziger;

import java.sql.SQLException;
import java.util.List;

public interface AdresDAO {
    boolean save(Adres adres);
    boolean update(Adres adres);
    boolean delete(Adres adres);
    Adres findById(int id);
    Adres findByReiziger(Reiziger reiziger) throws SQLException;
    List<Adres> findAll() throws SQLException;
}
