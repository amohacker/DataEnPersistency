package p5.postgres;

import p5.domein.Adres;
import p5.domein.Reiziger;
import p5.dao.AdresDAO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdresDAOPsql implements AdresDAO {
    Connection conn;
    public AdresDAOPsql(Connection connection){
        this.conn = connection;
    }

    @Override
    public boolean save(Adres adres) {
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO adres " +
                    "(adres_id, postcode, huisnummer, straat, woonplaats, reiziger_id) " +
                    "VALUES(?, ?, ?, ?, ?, ?);");
            ps.setInt(1, adres.getId());
            ps.setString(2, adres.getPostcode());
            ps.setString(3, adres.getHuisnummer());
            ps.setString(4, adres.getStraat());
            ps.setString(5, adres.getWoonplaats());
            ps.setInt(6, adres.getReiziger().getId());
            if (ps.executeUpdate() == 0)
                return update(adres);
            return true;
        } catch (SQLException e){
            return update(adres);
        }
    }

    @Override
    public boolean update(Adres adres) {
        try {
            PreparedStatement ps = conn.prepareStatement("UPDATE adres " +
                    "SET postcode=?, huisnummer=?, straat=?, woonplaats=?, reiziger_id=? " +
                    "WHERE adres_id=?;");
            ps.setString(1, adres.getPostcode());
            ps.setString(2, adres.getHuisnummer());
            ps.setString(3, adres.getStraat());
            ps.setString(4, adres.getWoonplaats());
            ps.setInt(5, adres.getReiziger().getId());
            ps.setInt(6, adres.getId());
            if (ps.executeUpdate() == 0) {
                return false;
            }
            return true;
        } catch (SQLException e){
            return false;
        }
    }

    @Override
    public boolean delete(Adres adres) {
        if (adres == null)
            return false;
        try {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM adres " +
                    "WHERE adres_id=?;");
            ps.setInt(1, adres.getId());
            if (ps.executeUpdate() == 0) {
                return false;
            }
            return true;
        } catch (SQLException e){
            return false;
        }
    }

    @Override
    public Adres findById(int id) {
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT adres_id, postcode, huisnummer, straat, woonplaats, reiziger_id FROM adres WHERE adres_id=?;");
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            rs.next();
            return new Adres(
                    rs.getInt("adres_id"),
                    rs.getString("postcode"),
                    rs.getString("huisnummer"),
                    rs.getString("straat"),
                    rs.getString("woonplaats"),
                    new ReizigerDAOPsql(conn).findById(rs.getInt("reiziger_id"))
            );
        } catch (SQLException e) {
            return null;
        }
    }

    @Override
    public Adres findByReiziger(Reiziger reiziger) {
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT adres_id, postcode, huisnummer, straat, woonplaats, reiziger_id FROM adres WHERE reiziger_id=?;");
            ps.setInt(1, reiziger.getId());
            ResultSet rs = ps.executeQuery();
            rs.next();
            return new Adres(
                    rs.getInt("adres_id"),
                    rs.getString("postcode"),
                    rs.getString("huisnummer"),
                    rs.getString("straat"),
                    rs.getString("woonplaats"),
                    reiziger
            );
        } catch (SQLException throwables) {
            return null;
        }
    }

    @Override
    public List<Adres> findAll() throws SQLException {
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT adres_id, postcode, huisnummer, straat, woonplaats, reiziger_id FROM adres;");
        List<Adres> list = new ArrayList();
        while (rs.next()) {
            list.add(new Adres(
                    rs.getInt("adres_id"),
                    rs.getString("postcode"),
                    rs.getString("huisnummer"),
                    rs.getString("straat"),
                    rs.getString("woonplaats"),
                    new ReizigerDAOPsql(conn).findById(rs.getInt("reiziger_id"))
            ));
        }
        return list;
    }
}
