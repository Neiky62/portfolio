package fr.iutlittoral.systems.spawners;

import java.util.Random;

import com.badlogic.ashley.core.Entity;

import fr.iutlittoral.components.*;
import fr.iutlittoral.components.spawntypes.MovingBoxSpawnType;
import javafx.scene.paint.Color;


/**
 * A spawner system that spawn simple boxes.
 * Targeting entities :
 *  - Spawner Component
 *  - SimpleBox Component
 */
public class MovingBoxSpawnerType extends AbstractSpawnerSystem {

    private Color color;
    private Random random;

    public MovingBoxSpawnerType(Color color) {
        super(MovingBoxSpawnType.class);
        this.color = color;
        this.random = new Random();

    }

    @Override
    public void spawn(double x, double y) {
        Entity entity = new Entity();
        entity.add(new Position(x, y));
        entity.add(new BoxShape(40, 40));
        entity.add(new Shade(color));
        entity.add(new LimitedLifespan(15));
        entity.add(new BoxCollider(40, 40));
        entity.add(new Target());
        entity.add(new AlphaDecay());
        double velocityX = this.random.nextDouble() * 200 - 100; 
        double velocityY = this.random.nextDouble() * 200 - 100;
        entity.add(new Velocity(velocityX,velocityY));
        
        getEngine().addEntity(entity);
    }
}