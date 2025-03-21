package fr.iutlittoral.events;
import com.badlogic.ashley.core.Entity;
public class TargetDestroyed {
    public final int score;
    public double x;
    public double y;
    private Entity targetEntity;  // Ajout de l'entité cible détruite

    public TargetDestroyed(int score, double x, double y,Entity targetEntity) {
        this.score = score;
        this.x = x;
        this.y = y;
        this.targetEntity = targetEntity;
    }

    public int getScore(){
        return score;
    }

    public Entity getEntity(){
        return targetEntity;
    }
}
