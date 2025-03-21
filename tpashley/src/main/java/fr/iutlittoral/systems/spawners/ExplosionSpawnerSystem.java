package fr.iutlittoral.systems.spawners;

import com.badlogic.ashley.core.Entity;

import fr.iutlittoral.components.*;
import fr.iutlittoral.components.spawntypes.ExplosionBoxSpawnType;
import javafx.scene.paint.Color;
import java.util.Random; 

public class ExplosionSpawnerSystem extends AbstractSpawnerSystem {

    private Color color;
    private Random random;
    public ExplosionSpawnerSystem(Color color) {
        super(ExplosionBoxSpawnType.class);
        this.color = color;
        this.random = new Random();
    }

    @Override
    public void spawn(double x, double y) {
        for(int i = 0;i < 10;i++){
            Entity entity = new Entity();
            entity.add(new Position(x, y));
            entity.add(new BoxShape(5, 5));
            entity.add(new Shade(color));
            entity.add(new LimitedLifespan(0.5));
            entity.add(new AlphaDecay());
            double velocityX = this.random.nextDouble() * 200 - 100; 
            double velocityY = this.random.nextDouble() * 200 - 100; 
            entity.add(new Velocity(velocityX, velocityY));
            getEngine().addEntity(entity);
        } 
    }
}
