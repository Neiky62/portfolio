package fr.iutlittoral.systems.spawners;

import com.badlogic.ashley.core.Entity;

import fr.iutlittoral.components.*;
import fr.iutlittoral.components.spawntypes.BonusBoxSpawnType;
import javafx.scene.paint.Color;

/**
 * A spawner system that spawns simple boxes.
 * Targeting entities :
 *  - Spawner Component
 *  - SimpleBox Component
 */
public class BonusSpawnerSystem extends AbstractSpawnerSystem {

    private final Color color;

    public BonusSpawnerSystem(Color color) {
        super(BonusBoxSpawnType.class);
        this.color = color;
    }

    @Override
    public void spawn(double x, double y) {
        Entity entity = new Entity();
        entity.add(new Position(x, y));
        entity.add(new CircleShape(30));
        entity.add(new Shade(color));
        entity.add(new LimitedLifespan(5));
        entity.add(new AlphaDecay());
        entity.add(new BoxCollider(30, 30));
        entity.add(new Target());
        entity.add(new BonusBoxSpawnType());

        getEngine().addEntity(entity);
    }
}
