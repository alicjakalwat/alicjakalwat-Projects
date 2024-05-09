import java.util.Random;

public class czlowiek extends zwierze {


    czlowiek(){}


    void rokowania_choroby() {
        przewidywany_czas_choroby = Math.abs(new Random().nextGaussian() * 3 + 14);  //srednia 14, odchylenie 3

        double z;

        do{
            z = new Random().nextGaussian() * 0.25 + 0.15;

        }while(0 > z || z > 1);

        prawd_zgonu = z;
    }


}