package p5.dao;

import p5.domein.Adres;
import p5.domein.Product;
import p5.domein.Reiziger;

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
