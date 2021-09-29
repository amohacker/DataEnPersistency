package p5.dao;

import p5.domein.OVChipkaart;
import p5.domein.Product;
import p5.domein.Reiziger;

import java.sql.SQLException;
import java.util.List;

public interface ProductDAO {
    boolean save(Product product);
    boolean update(Product product);
    Product findByID(int id) throws SQLException;
    boolean addOV(int kaartnummer, int productnummer);
    boolean removeOV(int kaartnummer, int productnummer);
    List<Product> findByOVChipkaart(OVChipkaart ovChipkaart) throws SQLException;
    List<OVChipkaart> findOVCHipkaartenByProduct(Product product);
