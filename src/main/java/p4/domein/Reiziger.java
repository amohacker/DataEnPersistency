package p4.domein;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Reiziger {
    private int id;
    private String voorletters;
    private String tussenvoegsel;
    private String achternaam;
    private Date geboortedatum;
    private Adres adres;
    private List<OVChipkaart> ovChipkaartList = new ArrayList<>();

    public Reiziger (int id, String voorletters, String tussenvoegsel, String achternaam, Date geboortedatum){
        this.id = id;
        this.voorletters = voorletters;
        this.tussenvoegsel = tussenvoegsel;
        this.achternaam = achternaam;
        this.geboortedatum = geboortedatum;
    }

    public Reiziger (String voorletters, String tussenvoegsel, String achternaam, Date geboortedatum) {
        this(0, voorletters, tussenvoegsel, achternaam, geboortedatum);
    }

    public Reiziger (int id, String voorletters, String tussenvoegsel, String achternaam, Date geboortedatum, Adres adres){
        this(id, voorletters, tussenvoegsel, achternaam, geboortedatum);
        this.adres = adres;
    }

    public Reiziger (int id, String voorletters, String tussenvoegsel, String achternaam){
        this(id, voorletters, tussenvoegsel, achternaam, null);
    }

    public Reiziger (int id, String voorletters, String achternaam, Date geboortedatum){
        this(id,voorletters, null, achternaam,geboortedatum);
    }

    public Reiziger (int id, String voorletters, String achternaam){
        this(id,voorletters, null, achternaam);
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getVoorletters() {
        return voorletters;
    }

    public void setVoorletters(String voorletters) {
        this.voorletters = voorletters;
    }

    public String getAchternaam() {
        return achternaam;
    }

    public void setAchternaam(String achternaam) {
        this.achternaam = achternaam;
    }

    public String getTussenvoegsel() {
        return tussenvoegsel;
    }

    public void setTussenvoegsel(String tussenvoegsel) {
        this.tussenvoegsel = tussenvoegsel;
    }

    public Date getGeboortedatum() {
        return geboortedatum;
    }

    public void setGeboortedatum(Date geboortedatum) {
        this.geboortedatum = geboortedatum;
    }

    public String getNaam(){
        return voorletters + " " + tussenvoegsel + " " + achternaam;
    }

    public Adres getAdres() {
        return adres;
    }

    public void setAdres(Adres adres) {
        if (adres != null) {
            this.adres = adres;
            this.adres.setReiziger(this);
        }
    }

    public List<OVChipkaart> getOvChipkaartList() {
        return ovChipkaartList;
    }

    public void setOvChipkaartList(List<OVChipkaart> ovChipkaartList) {
        this.ovChipkaartList = ovChipkaartList;
    }

    public void addOvChipkaart(OVChipkaart ovChipkaart){
        ovChipkaart.setReiziger(this);
        this.ovChipkaartList.add(ovChipkaart);
    }

    public void removeOvChipkaart(OVChipkaart ovChipkaart){
        this.ovChipkaartList.remove(ovChipkaart);
    }

    public void removeOvChipkaartByKaartNummer(int id){
        for (OVChipkaart ov : this.ovChipkaartList) {
            if (ov.getKaartNummer() == id)
                this.ovChipkaartList.remove(ov);
        }
    }

    @Override
    public String toString() {
        return "Reiziger {" +
                "#" + id +
                " " + voorletters + ". " +
                " " + tussenvoegsel + " " +
                " " + achternaam +
                ", geb. " + geboortedatum +
                ", " + adres + ", \n" +
                ovChipkaartList + "}";
    }

}
