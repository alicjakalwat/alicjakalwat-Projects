import java.util.ArrayList;
import java.util.Random;

public class populacja{

    int l=10; // liczba ludzi
    int z=100; // liczba zwierzat

    boolean kwarantanna = true;

    int liczba_ludzi_chorych = 0;
    int liczba_ludzi_zmarlych = 0;
    int liczba_ozdrowiencow = 0;
    int liczba_ludzi_zyjacych = 0;

    int liczba_zwierzat_chorych = 0;
    int liczba_zwierzat_zmarlych = 0;
    int liczba_zwierzat_ozdrowionych= 0;
    int liczba_zwierzat_zyjacych = 0;

    ArrayList<czlowiek> lista_ludzi = new ArrayList<czlowiek>();  //lista ktora zmienia swoja dlugosc
    ArrayList<zwierze> lista_zwierzat = new ArrayList<zwierze>();


    populacja(){

        for(int i = 0; i < l; i++){

            lista_ludzi.add(new czlowiek());
        }

        for(int i = 0; i < z; i++) {

            lista_zwierzat.add(new zwierze());
        }


        Random r = new Random();   // tutaj losujemy jedna chora osobe
        int a = r.nextInt(l);

        czlowiek pierwszy = new czlowiek();
        pierwszy = lista_ludzi.get(a);

        pierwszy.zmiana_stanu(1);

        pierwszy.rokowania_choroby();  //ustalam
        pierwszy.czas_choroby = 1;

        lista_ludzi.set(a, pierwszy);

        liczba_ludzi_chorych = 1;
        liczba_ludzi_zyjacych = l;
        


        Random r2 = new Random();   // tutaj losujemy jednego chorego zwierzaczka
        int b = r2.nextInt(z);

        zwierze pierwsze = new zwierze();
        pierwsze = lista_zwierzat.get(b);

        pierwsze.zmiana_stanu(1);

        pierwsze.rokowania_choroby();
        pierwsze.czas_choroby = 1;

        lista_zwierzat.set(b, pierwsze);

        liczba_zwierzat_chorych = 1;
        liczba_zwierzat_zyjacych = z;
    }


    populacja(int ludzie, int zwierzeta){

        l = ludzie;
        z = zwierzeta;


        for(int i = 0; i < l; i++) {

            lista_ludzi.add(new czlowiek());
        }

        for(int j = 0; j < z; j++) {

            lista_zwierzat.add(new zwierze());
        }

        Random r = new Random();
        int a = r.nextInt(l);


        czlowiek pierwszy = new czlowiek();
        pierwszy = lista_ludzi.get(a);

        pierwszy.zmiana_stanu(1);

        pierwszy.rokowania_choroby();
        pierwszy.czas_choroby = 1;
        

        lista_ludzi.set(a, pierwszy);

        liczba_ludzi_chorych = 1;
        liczba_ludzi_zyjacych = l;
        


        Random r2 = new Random();
        int b = r2.nextInt(z);

        zwierze pierwsze = new zwierze();
        pierwsze = lista_zwierzat.get(b);

        pierwsze.zmiana_stanu(1);

        pierwsze.rokowania_choroby();
        pierwsze.czas_choroby = 1;

        lista_zwierzat.set(b, pierwsze);

        liczba_zwierzat_chorych = 1;
        liczba_zwierzat_zyjacych = z;
    }


    void przemieszczenieludzi(){

        for (int i = 0; i < l; i++) {

            czlowiek obiekt = lista_ludzi.get(i);


            if((obiekt.stan == 1 || obiekt.stan == 3) && kwarantanna){
            }else{
                obiekt.przemieszczenie();
                lista_ludzi.set(i, obiekt);
            }
        }
    }

    void przemieszczeniezwierzat(){

        zwierze obiekt = new zwierze();

        for (int i = 0; i < z; i++) {

            obiekt = lista_zwierzat.get(i);
            obiekt.przemieszczenie();

            lista_zwierzat.set(i, obiekt);}}



    int losowy_czlowiek_indeks(){

        int indeks;

        do {
            Random r = new Random();
            indeks = r.nextInt(l);

        }while(lista_ludzi.get(indeks).stan == 3);

        return indeks;
    }


    int losowe_zwierze_indeks(){

        int indeks;

        do {
            Random r = new Random();
            indeks = r.nextInt(z);

        }while(lista_zwierzat.get(indeks).stan == 3);

        return indeks;
    }


}