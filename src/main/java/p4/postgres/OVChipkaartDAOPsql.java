package p4.postgres;

import p4.dao.OVChipkaartDAO;
import p4.domein.OVChipkaart;
import p4.domein.Reiziger;

import java.sql.*;
import java.util.ArrayList;
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
    public boolean save(OVChipkaart ovChipkaart) {
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO ov_chipkaart (kaart_nummer, geldig_tot, klasse, saldo, reiziger_id) VALUES(?, ?, ?, ?, ?);");
            ps.setInt(1, ovChipkaart.getKaartNummer());
            ps.setDate(2, new Date(ovChipkaart.getGeldigTot().getTime()));
            ps.setInt(3, ovChipkaart.getKlasse());
            ps.setFloat(4, ovChipkaart.getSaldo());
            ps.setInt(5, ovChipkaart.getReiziger().getId());
            if (ps.executeUpdate() == 0)
                return update(ovChipkaart);
            return true;

        } catch (SQLException throwables) {
            return update(ovChipkaart);
        }
    }

    @Override
    public boolean update(Reiziger reiziger) {
        try {
            List<Integer> list = new ArrayList<>();
            for (OVChipkaart ovChipkaart : reiziger.getOvChipkaartList()){
                list.add (ovChipkaart.getKaartNummer());
            }
            PreparedStatement ps = conn.prepareStatement("DELETE FROM ov_chipkaart WHERE reiziger_id = ? AND not kaart_nummer IN ?");
            ps.setArray(1, conn.createArrayOf("int", list.toArray()));
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean update(OVChipkaart ovChipkaart) {
        try {
            PreparedStatement ps = conn.prepareStatement("UPDATE ov_chipkaart SET geldig_tot=?, klasse=?, saldo=?, reiziger_id=? WHERE kaart_nummer=?;");
            ps.setDate(1, new Date(ovChipkaart.getGeldigTot().getTime()));
            ps.setInt(2, ovChipkaart.getKlasse());
            ps.setFloat(3, ovChipkaart.getSaldo());
            ps.setInt(4, ovChipkaart.getReiziger().getId());
            ps.setInt(5, ovChipkaart.getKaartNummer());
            if (ps.executeUpdate() == 0)
                return false;
            return true;

        } catch (SQLException throwables) {
            return false;
        }
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
