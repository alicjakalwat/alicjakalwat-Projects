import java.lang.Thread;
import java.util.Random;


public class populacja_main {
    public static void main(String[] args){


        int liczba_symulacji = 3;


        double p1 = 0.4; //prawdopodobienstwo zarazenia czlowieka od czlowieka (odleglosc)
        double p2 = 0.6; //prawdopodobienstwo zarazenia zwierzecia od zwierzecia (odleglosc)
        double p3 = 0.75; //prawdopobienstwo ze czlowiek umie wybrac zdrowe zwierze
        boolean K = true;  //kwarantanna
        int odleglosc = 5;
        int odleglosc_zwierzeta = 10;

        int ile_ludzi = 130;
        int ile_zwierzat = 5000;

        int iteracje = 700;
        int sukces;


        populacja test = new populacja();
        
        int var;  //dzieki tej zmiennej mozemy wyjsc z ogolnej petli
        int przebieg;  //liczba iteracji ktore sie wykonuje


        float suma_dlugosc_trwania = 0;  //koniec epidemii
        float suma_nr_iteracji_pik = 0;   //suma iteracji gdzie najwiecej chorych
        int nr_iteracji_pik;
        int pik_chorych = 0;    //najwieksza liczba chorych w symulacji

        test.kwarantanna = K;




        for(int s = 0; s < liczba_symulacji; s++) {

        	        	        	
            var = 0;
            przebieg = 0;
            sukces = 0;
            nr_iteracji_pik = 0;
            pik_chorych = 0;   //dla kazdej nowej symulacji trzeba wyzerowac

            test = new populacja(ile_ludzi,ile_zwierzat);
            
            while (var >= 0) {

                //ponizej w kazdej iteracji sprawdzam odleglosc miedzy kazdymi dwoma ludzmi, jak jeden chory - drugi sie zaraza
                for (int j = 0; j < test.l; j++) {
                    for (int k = 0; k < test.l; k++) {


                        czlowiek obiekt_j = test.lista_ludzi.get(j);
                        czlowiek obiekt_k = test.lista_ludzi.get(k);        //tworzymy te obiekty zeby moc operowac nimi i listami w petlach

                        if(obiekt_j.stan != 3 && obiekt_k.stan != 3) {


                            if (obiekt_j.odleglosc(obiekt_k) < odleglosc) {


                                if (obiekt_j.stan == 1) {


                                    Random r = new Random();
                                    double a = r.nextDouble(); // losowa liczba od 0 do 1

                                    if (a <= p1) {  //z prawdopodobienstwem p1

                                        if (obiekt_k.stan != 1) {

                                            obiekt_k.zmiana_stanu(1);
                                            obiekt_k.rokowania_choroby();

                                            test.lista_ludzi.set(k, obiekt_k);

                                            test.liczba_ludzi_chorych++;
                                        }
                                    }
                                } else if (obiekt_k.stan == 1) {

                                    Random r = new Random();
                                    double a = r.nextDouble();

                                    if (a <= p1) {

                                        if (obiekt_j.stan != 1) {
                                            obiekt_j.zmiana_stanu(1);
                                            obiekt_j.rokowania_choroby();

                                            test.lista_ludzi.set(j, obiekt_j);

                                            test.liczba_ludzi_chorych++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                //ponizej w kazdej iteracji sprawdzam odleglosc miedzy kazdymi dwoma zwierzetami, jak jeden chory - drugi sie zaraza
                for (int z = 0; z < test.z; z++) {
                    for (int w = 0; w < test.z; w++) {


                        zwierze obiekt_z = test.lista_zwierzat.get(z);
                        zwierze obiekt_w = test.lista_zwierzat.get(w);

                        if(obiekt_z.stan != 3 && obiekt_w.stan != 3) {

                            if (obiekt_z.odleglosc(obiekt_w) < odleglosc_zwierzeta) {


                                if (obiekt_z.stan == 1) {

                                    Random r = new Random();
                                    double a = r.nextDouble();

                                    if (a <= p2) {  //z prawdopodobienstwem p2

                                        if (obiekt_w.stan != 1) {
                                            obiekt_w.zmiana_stanu(1);
                                            obiekt_w.rokowania_choroby();

                                            test.lista_zwierzat.set(w, obiekt_w);

                                            test.liczba_zwierzat_chorych++;
                                        }
                                    }

                                } else if (obiekt_w.stan == 1) {

                                    Random r = new Random();
                                    double a = r.nextDouble();

                                    if (a <= p2) {

                                        if (obiekt_z.stan != 1) {
                                            obiekt_z.zmiana_stanu(1);
                                            obiekt_z.rokowania_choroby();

                                            test.lista_zwierzat.set(z, obiekt_z);

                                            test.liczba_zwierzat_chorych++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                int zz = test.liczba_ludzi_zyjacych / 5; // to samo co floor(test.l/5)

                if (test.liczba_ludzi_zyjacych > 0 && test.liczba_ludzi_zyjacych < 5) zz = 1;

                for (int j = 0; j < zz; j++) {   //zjadanie zwierzat przez ludzi

                    if (test.liczba_zwierzat_zyjacych > 0) {  //zeby mialo sens

                        int losowy_czlowiek_indeks = test.losowy_czlowiek_indeks();
                        int losowe_zwierze_indeks = test.losowe_zwierze_indeks();

                        zwierze obiekt_zwierze = new zwierze();
                        czlowiek obiekt = test.lista_ludzi.get(losowy_czlowiek_indeks);


                        Random r = new Random();
                        double a = r.nextDouble();

                        if (a <= p3) {  //prawd p3 ze czlowiek bedzie umial wybrac zdrowe zwierze do zjedzenia

                            int q = 0;
                            while (q < test.z) {
                                if (test.lista_zwierzat.get(q).stan == 0 || test.lista_zwierzat.get(q).stan == 2) {    //pierwsze niechore zwierze

                                    test.liczba_zwierzat_zmarlych++;
                                    test.liczba_zwierzat_zyjacych--;

                                    if (test.lista_zwierzat.get(q).stan == 2) test.liczba_zwierzat_ozdrowionych--;

                                    obiekt_zwierze = test.lista_zwierzat.get(q);
                                    obiekt_zwierze.zmiana_stanu(3);
                                    test.lista_zwierzat.set(q, obiekt_zwierze);

                                    q = test.z;
                                }
                                q++;
                            }


                        } else {  // nie umie wybrac zdrowego, wiec zjada od razu


                            if (test.lista_zwierzat.get(losowe_zwierze_indeks).stan == 1) {  // jak zwierze chore, to sie zaraza


                                if (obiekt.stan != 1) {

                                    if (obiekt.stan == 2) test.liczba_ozdrowiencow--;

                                    obiekt.zmiana_stanu(1);
                                    test.liczba_ludzi_chorych++;

                                    obiekt.rokowania_choroby();

                                    test.lista_ludzi.set(losowy_czlowiek_indeks, obiekt);

                                }

                                test.liczba_zwierzat_chorych--;

                            }

                            test.liczba_zwierzat_zmarlych++;


                            obiekt_zwierze = test.lista_zwierzat.get(losowe_zwierze_indeks);

                            if(obiekt_zwierze.stan == 2) test.liczba_zwierzat_ozdrowionych--;

                            obiekt_zwierze.zmiana_stanu(3);
                            test.lista_zwierzat.set(losowe_zwierze_indeks, obiekt_zwierze);
                            test.liczba_zwierzat_zyjacych--;

                        }
                    }
                }


                for (int i = 0; i < test.l; i++) {   //choroba, zwiekszanie czasu lub wyzdrowienie/smierc

                    czlowiek obiekt = test.lista_ludzi.get(i);

                    if(obiekt.stan != 3) {

                        if (obiekt.stan == 1) {  //jesli czlowiek chory to wchodzi dalej

                            if (obiekt.czas_choroby >= obiekt.przewidywany_czas_choroby) {  //minal czas choroby, wiec albo wyzdrowieje albo umrze

                                double a = new Random().nextDouble();
                                if (a <= obiekt.prawd_zgonu) {

                                    obiekt.zmiana_stanu(3);

                                    test.liczba_ludzi_zmarlych++;
                                    test.liczba_ludzi_chorych--;
                                    test.liczba_ludzi_zyjacych--; 

                                } else {

                                    obiekt.zmiana_stanu(2);
                                    test.liczba_ozdrowiencow++;

                                    obiekt.czas_choroby = 0;   //zeruje czas chorowania;

                                    test.liczba_ludzi_chorych--;
                                }

                            } else obiekt.czas_choroby++;

                            test.lista_ludzi.set(i, obiekt);

                        }
                    }
                }


                for (int i = 0; i < test.z; i++) {  // to samo tylko u zwierzat

                    zwierze obiekt2 = test.lista_zwierzat.get(i);

                    if(obiekt2.stan != 3) {

                        if (obiekt2.stan == 1) {

                            if (obiekt2.czas_choroby >= obiekt2.przewidywany_czas_choroby) {  //minal czas choroby, wiec albo wyzdrowieje albo umrze

                                double a = new Random().nextDouble();
                                if (a <= obiekt2.prawd_zgonu) {

                                    obiekt2.zmiana_stanu(3);

                                    test.liczba_zwierzat_zmarlych++;
                                    test.liczba_zwierzat_chorych--;
                                    test.liczba_zwierzat_zyjacych--;

                                } else {

                                    obiekt2.zmiana_stanu(2);
                                    test.liczba_zwierzat_ozdrowionych++;

                                    obiekt2.czas_choroby = 0;


                                    test.liczba_zwierzat_chorych--;
                                }

                            } else obiekt2.czas_choroby++;

                            test.lista_zwierzat.set(i, obiekt2);
                          

                        }
                    }
                }


                test.przemieszczenieludzi();  // -> po sprawdzeniu odleglosci robie przemieszczenie kazdego czlowieka
                test.przemieszczeniezwierzat();

                przebieg++;

                try {  //dzieki temu wyswietlaja sie powoli iteracje
                    Thread.sleep(10);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }

                if (przebieg == iteracje) var = -1; //wykonano wszystkie iteracje
                if (test.l - test.liczba_ludzi_zmarlych > 0 && test.liczba_ludzi_chorych == 0 && test.liczba_zwierzat_chorych == 0) {  //pozostali sami zdrowi 
                    sukces = 1;
                    var = -1;
                } 
                if (test.l == test.liczba_ludzi_zmarlych) var = -1;   // wszyscy ludzie sa zmarli
                





                if(test.liczba_ludzi_chorych > pik_chorych) {  //gdy liczba chorych jest wieksza niz aktualny pik, to zamien

                    pik_chorych = test.liczba_ludzi_chorych;
                    nr_iteracji_pik = przebieg;  //zapamietaj dla ktorego nr iteracji byl pik
                }

//                System.out.println("Nr iteracji: " + przebieg + ", chorzy ludzie/wszyscy ludzie: " + test.liczba_ludzi_chorych + "/" + test.l +
//                     ", chore zwierzeta/wszystkie zwierzeta: " + test.liczba_zwierzat_chorych + "/" + test.z);

/*              System.out.println("Nr iteracji: " + przebieg + ",Ludzie - żyjżcy/chorzy/ozdrowieńcy/wszyscy: " + test.liczba_ludzi_zyjacych +"/"+ test.liczba_ludzi_chorych + "/" + test.liczba_ozdrowiencow + "/" + test.l +
              "Zwierzęta - żyjący/chorzy/ozdrowieńcy/wszyscy: " + test.liczba_zwierzat_zyjacych +"/"+ test.liczba_zwierzat_chorych + "/" + test.liczba_zwierzat_ozdrowionych + "/" + test.z);

 */               


///*
                //System.out.print("Nr iteracji: " + przebieg + ", Liczba chorych: " + test.liczba_ludzi_chorych + " ");
                System.out.format("Nr iteracji: %4d Liczba chorych: %3d  ", przebieg, test.liczba_ludzi_chorych);
                for(int m = 0; m < test.l; m++){
                    System.out.print(test.lista_ludzi.get(m).stan);
                }
                System.out.println();
//*/


    /*
          System.out.print("chore zwierzeta: " + test.liczba_zwierzat_chorych + ", ");

            for(int n = 0; n < test.z; n++){
                System.out.print(test.lista_zwierzat.get(n).stan);
            }
    */



            }

            System.out.println();
            System.out.println("Liczba iteracji: " + przebieg + ", sukces: " + sukces);
            System.out.println("Największa liczba chorych (pik): " + pik_chorych  + " w " + nr_iteracji_pik + "-ej iteracji");


            suma_dlugosc_trwania += przebieg;
            suma_nr_iteracji_pik += nr_iteracji_pik;



            System.out.println();
            System.out.println("******************************************************************************************************");
            System.out.println();

        }



        float sredni_nr_iteracji_pik = suma_nr_iteracji_pik / liczba_symulacji;
        float srednia_dlugosc_trwania = suma_dlugosc_trwania / liczba_symulacji;


//        System.out.println("Średnia długość trwania epidemii z " + liczba_symulacji + " symulacji to: " + srednia_dlugosc_trwania);
//        System.out.println("Średnia liczba iteracji z " + liczba_symulacji + " symulacji, w której wystąpił 'pik' zachorowań: " + sredni_nr_iteracji_pik);
        System.out.format("Średnia długość trwania epidemii z %d symulacji to: %10.2f\n", liczba_symulacji, srednia_dlugosc_trwania);
        System.out.format("Średni numer iteracji na %d symulacji, w której wystąpił 'pik' zachorowań: %10.2f\n", liczba_symulacji, sredni_nr_iteracji_pik);
//        System.out.println();
    }
}