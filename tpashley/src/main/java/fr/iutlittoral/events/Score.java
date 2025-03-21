package fr.iutlittoral.events;

import com.badlogic.ashley.signals.Listener;
import com.badlogic.ashley.signals.Signal;

public class Score implements Listener<TargetDestroyed> {
    private int score;

    public Score(int score){
        this.score = score;
    }

    @Override
    public void receive(Signal<TargetDestroyed> signal, TargetDestroyed object) {
        System.out.println("signal reçu");
        score++;
    }

    public int getScore() {
        return score;
    }
    public void add(Signal<TargetDestroyed> targetDestroyedSignal) {
        targetDestroyedSignal.add(this); 
    }

    

}
    
