package p4.postgres;

import p4.dao.AdresDAO;
import p4.dao.ReizigerDAO;
import p4.domein.OVChipkaart;
import p4.domein.Reiziger;
import p4.postgres.AdresDAOPsql;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReizigerDAOPsql implements ReizigerDAO {
    private final Connection conn;

    public ReizigerDAOPsql(Connection conn) {
        this.conn = conn;
    }

    @Override
    public boolean save(Reiziger reiziger) {
        if (reiziger.getId() == 0) {
            throw new NullPointerException();
        }
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO reiziger " +
                    "(reiziger_id, voorletters, tussenvoegsel, achternaam, geboortedatum) " +
                    "VALUES(?, ?, ?, ?, ?);");
            ps.setInt(1, reiziger.getId());
            ps.setString(2, reiziger.getVoorletters());
            ps.setString(3, reiziger.getTussenvoegsel());
            ps.setString(4, reiziger.getAchternaam());
            ps.setDate(5, new Date(reiziger.getGeboortedatum().getTime()));
            if (ps.executeUpdate() == 0) {
                return update(reiziger);
            }
            if (reiziger.getAdres() != null) {
                new AdresDAOPsql(conn).save(reiziger.getAdres());
            }
            return update(reiziger);

        } catch (SQLException e){
            return update(reiziger);
        }
    }

    @Override
    public boolean update(Reiziger reiziger) {
        if (reiziger.getId() == 0) {
            throw new NullPointerException();
        }
        try {
            PreparedStatement ps = conn.prepareStatement("UPDATE reiziger " +
                    "SET voorletters=?, tussenvoegsel=?, achternaam=?, geboortedatum=? " +
                    "WHERE reiziger_id=?; ");
            ps.setString(1, reiziger.getVoorletters());
            ps.setString(2, reiziger.getTussenvoegsel());
            ps.setString(3, reiziger.getAchternaam());
            ps.setDate(4, new Date(reiziger.getGeboortedatum().getTime()));
            ps.setInt(5, reiziger.getId());

                AdresDAOPsql adao = new AdresDAOPsql(conn);
                if (reiziger.getAdres() != null)
                    adao.save(reiziger.getAdres());
                else
                    adao.delete(adao.findByReiziger(reiziger));

            new OVChipkaartDAOPsql(conn).update(reiziger);
            if (ps.executeUpdate() == 0) {
                return false;
            }
            return true;
        } catch (SQLException e){
            return false;
        }
    }

    @Override
    public boolean delete(Reiziger reiziger) {
        try {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM reiziger " +
                    "WHERE reiziger_id=?;");
            ps.setInt(1, reiziger.getId());
            for (OVChipkaart ov : reiziger.getOvChipkaartList()) {
                new OVChipkaartDAOPsql(conn).delete(ov);
            }
            if (reiziger.getAdres() != null) {
                new AdresDAOPsql(conn).delete(reiziger.getAdres());
            }
            if (ps.executeUpdate() == 0) {
                return false;
            }
            return true;
        } catch (SQLException e){
            return false;
        }
    }

    @Override
    public Reiziger findById(int id) {

        try {
            PreparedStatement ps = conn.prepareStatement("SELECT reiziger_id, voorletters, tussenvoegsel, achternaam, geboortedatum " +
                    "FROM reiziger " +
                    "WHERE reiziger_id=?;");
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            rs.next();
            Reiziger reiziger = new Reiziger(
                    rs.getInt("reiziger_id"),
                    rs.getString("voorletters"),
                    rs.getString("tussenvoegsel"),
                    rs.getString("achternaam"),
                    rs.getDate("geboortedatum")
            );
            reiziger.setAdres(new AdresDAOPsql(conn).findByReiziger(reiziger));
            reiziger.setOvChipkaartList(new OVChipkaartDAOPsql(conn).findByReiziger(reiziger));
            return reiziger;
        } catch (SQLException e) {
            return null;
        }

    }

    @Override
    public List<Reiziger> findByGbdatum(String date) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("SELECT reiziger_id, voorletters, tussenvoegsel, achternaam, geboortedatum " +
                "FROM reiziger " +
                "WHERE geboortedatum=?;");
        ps.setDate(1, Date.valueOf(date));
        ResultSet rs = ps.executeQuery();
        List<Reiziger> list = new ArrayList();
        while (rs.next()) {
            Reiziger reiziger = new Reiziger(
                    rs.getInt("reiziger_id"),
                    rs.getString("voorletters"),
                    rs.getString("tussenvoegsel"),
                    rs.getString("achternaam"),
                    rs.getDate("geboortedatum")
            );
            reiziger.setAdres(new AdresDAOPsql(conn).findByReiziger(reiziger));
            list.add(reiziger);
        }
        return list;
    }

    @Override
    public List<Reiziger> findAll() throws SQLException {
        Statement st = conn.createStatement ();
        ResultSet rs = st.executeQuery("SELECT reiziger_id, voorletters, tussenvoegsel, achternaam, geboortedatum\n" +
                "FROM reiziger;");
        List<Reiziger> list = new ArrayList();
        while (rs.next()) {
            Reiziger reiziger = new Reiziger(
                    rs.getInt("reiziger_id"),
                    rs.getString("voorletters"),
                    rs.getString("tussenvoegsel"),
                    rs.getString("achternaam"),
                    rs.getDate("geboortedatum")
            );
                reiziger.setAdres(new AdresDAOPsql(conn).findByReiziger(reiziger));
            list.add(reiziger);
        }
        return list;
    }
}
