import java.util.Random;

public class zwierze {
    double wspx = new Random().nextDouble() * 1000;
    double wspy = new Random().nextDouble() * 1000;
    int stan = 0; // 0-zdrowy, 1-chory, 2-ozdrowieniec, 3-niezywy

    double przewidywany_czas_choroby;   // wyznaczany z rozkladu normalnego
    int czas_choroby = 0;

    double prawd_zgonu; // z rokladu normalnego


    zwierze(){}

    void wyswietl(){
        System.out.println(wspx + ", " + wspy);
    }

    void przemieszczenie(){

        wspx = new Random().nextDouble() * 1000;
        wspy = new Random().nextDouble() * 1000;
    }


    double odleglosc(zwierze z){

        double d, pom1, pom2;
        pom1 = (wspx - z.wspx) * (wspx - z.wspx);
        pom2 = (wspy - z.wspy) * (wspy - z.wspy);

        d = Math.sqrt(pom1 + pom2);

        return d;
    }

    void zmiana_stanu(int s){
        stan = s;
    }



    void rokowania_choroby() {
        przewidywany_czas_choroby = Math.abs(new Random().nextGaussian() * 4 + 20);  //srednia 20, odchylenie 4

        double z;

        do{
            z = new Random().nextGaussian() * 0.30 + 0.06;

        }while(0 > z || z > 1);

        prawd_zgonu = z;
    }


}