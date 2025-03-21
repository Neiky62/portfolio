package fr.iutlittoral.events;

import com.badlogic.ashley.signals.Listener;
import com.badlogic.ashley.signals.Signal;

import fr.iutlittoral.components.spawntypes.BonusBoxSpawnType;
import fr.iutlittoral.components.spawntypes.SimpleBoxSpawnType;
import fr.iutlittoral.systems.spawners.BonusSpawnerSystem;

public class Bonus implements Listener<TargetDestroyed> {
    private boolean bonus;

    public Bonus(){
        this.bonus = false;
    }

    @Override
    public void receive(Signal<TargetDestroyed> signal, TargetDestroyed object) {
        if (object.getEntity().getComponent(BonusBoxSpawnType.class) != null){
            this.bonus = true;
        }
    }

    public boolean getBonus(){
        return this.bonus;
    }


    public void add(Signal<TargetDestroyed> targetDestroyedSignal) {
        targetDestroyedSignal.add(this); 
    }

    public void setBonus(){
        bonus = false;
    }

    

}
    
