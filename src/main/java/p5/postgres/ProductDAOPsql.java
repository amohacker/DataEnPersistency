package p5.postgres;

import p5.dao.ProductDAO;
import p5.domein.OVChipkaart;
import p5.domein.Product;
import p5.domein.Reiziger;

import javax.xml.transform.Result;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAOPsql implements ProductDAO {

    Connection conn;
    public ProductDAOPsql(Connection connection){
        this.conn = connection;
    }

    @Override
    public boolean save(Product product) {
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO product (product_nummer, naam, beschrijving, prijs) VALUES (?, ?, ?, ?)");
            ps.setInt(1, product.getProduct_nummer());
            ps.setString(2, product.getNaam());
            ps.setString(3, product.getBeschrijving());
            ps.setFloat(4, product.getPrijs());
            if (ps.executeUpdate() != 0)
                return true;
        } catch (SQLException e) {}
        return update(product);
    }

    @Override
    public boolean update(Product product) {
        try {
            PreparedStatement ps = conn.prepareStatement("UPDATE product " +
                    "SET naam=?, beschrijving=?, prijs=? " +
                    "WHERE product_nummer=?");
            ps.setString(1, product.getNaam());
            ps.setString(2, product.getBeschrijving());
            ps.setFloat(3, product.getPrijs());
            ps.setInt(4, product.getProduct_nummer());
            if (ps.executeUpdate() != 0)
                return true;
        } catch (SQLException throwables) {
        }
        return false;
    }

    @Override
    public Product findByID(int id) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT product_nummer, naam, beschrijving, prijs " +
                "FROM product " +
                "WHERE product_nummer=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        rs.next();
        Product product = new Product(
            rs.getInt("product_nummer"),
            rs.getString("naam"),
            rs.getString("beschrijving"),
            rs.getFloat("prijs")
        );
        return product;
    }

    @Override
    public boolean addOV(int kaartnummer, int productnummer) {
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO ov_chipkaart_product(kaart_nummer, product_nummer, last_update) " +
                    "VALUES (?, ?, ?)");
            ps.setInt(1, kaartnummer);
            ps.setInt(2, productnummer);
            ps.setDate(3, new Date(new java.util.Date().getTime()));
            if (ps.executeUpdate() != 0)
                return true;
        } catch (SQLException throwables) {
        }
        return false;
    }

    @Override
    public boolean removeOV(int kaartnummer, int productnummer) {
        try {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM ov_chipkaart_product " +
                    "WHERE kaartnummer=? AND productnummer=?;");
            ps.setInt(1, kaartnummer);
            ps.setInt(2, productnummer);
            if (ps.executeUpdate() != 0)
                return true;
        } catch (SQLException e) {
        }
        return false;

    }

    @Override
    public List<Product> findByOVChipkaart(OVChipkaart ovChipkaart) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("select p.product_nummer, p.naam, p.beschrijving, p.prijs " +
                "from product p, ov_chipkaart_product ocp " +
                "where ocp.kaart_nummer = ? and ocp.product_nummer = p.product_nummer;");
        ps.setInt(1, ovChipkaart.getKaartNummer());
        ResultSet rs = ps.executeQuery();
        List<Product> list = new ArrayList<Product>();
        while (rs.next()) {
            list.add(new Product(
                    rs.getInt("product_nummer"),
                    rs.getString("naam"),
                    rs.getString("beschrijving"),
                    rs.getFloat("prijs")));
        }
        return list;
    }

    @Override
    public List<OVChipkaart> findOVCHipkaartenByProduct(Product product) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT kaart_nummer" +
                "FROM ov_chipkaart_product ovp " +
                "WHERE ovp.product_nummer = ?;");
        ps.setInt(1, product.getProduct_nummer());
        ResultSet rs = ps.executeQuery();
        List<OVChipkaart> list = new ArrayList<OVChipkaart>();
/*        while (rs.next()) {
            list.add(new OVChipkaart(
                    rs.getInt("kaart_nummer"),
                    rs.("naam"),
                    rs.getString("beschrijving"),
                    rs.getFloat("prijs")
            ));
        }*/
        return list;
    }
}
