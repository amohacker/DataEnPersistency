package p4.postgres;

import p4.dao.OVChipkaartDAO;
import p4.domein.OVChipkaart;
import p4.domein.Reiziger;

import java.sql.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class OVChipkaartDAOPsql implements OVChipkaartDAO {
    Connection conn;
    public OVChipkaartDAOPsql(Connection connection){
        this.conn = connection;
    }

    @Override
    public List<OVChipkaart> findByReiziger(Reiziger reiziger) {
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT kaart_nummer, geldig_tot, klasse, saldo FROM ov_chipkaart " +
                    "WHERE reiziger_id = ?");
            ps.setInt(1, reiziger.getId());
            ResultSet rs = ps.executeQuery();
            List<OVChipkaart> list = new ArrayList<>();
            while (rs.next()) {
                list.add(new OVChipkaart(
                        rs.getInt("kaart_nummer"),
                        rs.getDate("geldig_tot"),
                        rs.getInt("klasse"),
                        rs.getFloat("saldo"),
                        reiziger
                ));
            }
            return list;
        } catch (SQLException throwables) {
            return null;
        }
    }

    @Override
    public int save(OVChipkaart ovChipkaart) throws SQLException {
        try {
            String kaart_nummer_statement;
            if (ovChipkaart.getKaartNummer() == 0) {
                kaart_nummer_statement = "(SELECT max(kaart_nummer)+1 FROM ov_chipkaart)";
            } else {
                kaart_nummer_statement = "?";
            }
            PreparedStatement ps = conn.prepareStatement("INSERT INTO ov_chipkaart (geldig_tot, klasse, saldo, reiziger_id, kaart_nummer) " +
                    "VALUES(?, ?, ?, ?, " + kaart_nummer_statement + ") " +
                    "RETURNING kaart_nummer;");
            ps.setDate(1, new Date(ovChipkaart.getGeldigTot().getTime()));
            ps.setInt(2, ovChipkaart.getKlasse());
            ps.setFloat(3, ovChipkaart.getSaldo());
            ps.setInt(4, ovChipkaart.getReiziger().getId());
            try {
                ps.setInt(5, ovChipkaart.getKaartNummer());
            } catch (SQLException e){}
            ResultSet rs = ps.executeQuery();
            rs.next();
            System.out.println(rs.getRow());
            ps.executeQuery();
            return rs.getInt("kaart_nummer");

        } catch (SQLException throwables) {
            return update(ovChipkaart);
        }
    }

    @Override
    public boolean update(Reiziger reiziger) {
        try {
            if (reiziger.getOvChipkaartList().isEmpty())
                return false;
            StringBuilder sb = new StringBuilder();
            Iterator iterator = reiziger.getOvChipkaartList().listIterator();
            while (iterator.hasNext()){
                sb.append(((OVChipkaart) iterator.next()).getKaartNummer());
                if (iterator.hasNext())
                    sb.append(", ");
            }
            PreparedStatement ps = conn.prepareStatement("DELETE FROM ov_chipkaart WHERE reiziger_id = ? AND not kaart_nummer IN (" + sb + ");");
            ps.setInt(1, reiziger.getId());

            ps.executeUpdate();

            reiziger.getOvChipkaartList().forEach((ovchipkaart) -> {
                try {
                    ovchipkaart.setKaartNummer(save(ovchipkaart));
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            });
            return true;
        } catch (SQLException throwables) {
            throwables.printStackTrace();
            return false;
        }
    }

    @Override
    public int update(OVChipkaart ovChipkaart) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("UPDATE ov_chipkaart SET geldig_tot=?, klasse=?, saldo=?, reiziger_id=? WHERE kaart_nummer=?;");
        ps.setDate(1, new Date(ovChipkaart.getGeldigTot().getTime()));
        ps.setInt(2, ovChipkaart.getKlasse());
        ps.setFloat(3, ovChipkaart.getSaldo());
        ps.setInt(4, ovChipkaart.getReiziger().getId());
        ps.setInt(5, ovChipkaart.getKaartNummer());
        return ovChipkaart.getKaartNummer();
    }

    @Override
    public boolean delete(OVChipkaart ovChipkaart) {
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement("DELETE from ov_chipkaart WHERE kaart_nummer=?");
            ps.setInt(1, ovChipkaart.getKaartNummer());
            if (ps.executeUpdate() == 0)
                return false;
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    @Override
    public OVChipkaart findByID(int id) {
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT kaart_nummer, geldig_tot, klasse, saldo, reiziger_id FROM ov_chipkaart " +
                    "WHERE kaart_nummer = ?");
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            rs.next();
        return new OVChipkaart(
                rs.getInt("kaart_nummer"),
                rs.getDate("geldig_tot"),
                rs.getInt("klasse"),
                rs.getFloat("saldo"),
                new ReizigerDAOPsql(conn).findById(rs.getInt("reiziger_id"))
        );
        } catch (SQLException e) {
            return null;
        }
    }

    @Override
    public List<OVChipkaart> findAll() throws SQLException {
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT kaart_nummer, geldig_tot, klasse, saldo, reiziger_id FROM ov_chipkaart ");
            ResultSet rs = ps.executeQuery();
            List<OVChipkaart> list = new ArrayList<>();
            while (rs.next()) {
                list.add(new OVChipkaart(
                        rs.getInt("kaart_nummer"),
                        rs.getDate("geldig_tot"),
                        rs.getInt("klasse"),
                        rs.getFloat("saldo"),
                        new ReizigerDAOPsql(conn).findById(rs.getInt("reiziger_id"))
                ));
            }
            return list;
        } catch (SQLException throwables) {
            return null;
        }
    }
}
