package fr.iutlittoral;
 
import fr.iutlittoral.components.Spawner;
import fr.iutlittoral.components.Target;
import fr.iutlittoral.components.spawntypes.SimpleBoxSpawnType;
import fr.iutlittoral.events.Bonus;
import fr.iutlittoral.events.Score;
import fr.iutlittoral.events.TargetDestroyed;
import fr.iutlittoral.components.spawntypes.BonusBoxSpawnType;
import fr.iutlittoral.components.spawntypes.MovingBoxSpawnType;
import fr.iutlittoral.systems.*;
import fr.iutlittoral.systems.spawners.BonusSpawnerSystem;
import fr.iutlittoral.systems.spawners.ExplosionSpawnerSystem;
import fr.iutlittoral.systems.spawners.MovingBoxSpawnerType;
import fr.iutlittoral.systems.spawners.SimpleBoxSpawnerSystem;
import fr.iutlittoral.utils.*;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.input.MouseButton;
import javafx.scene.layout.StackPane;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.stage.Stage;
import com.badlogic.ashley.core.Engine;
import com.badlogic.ashley.core.Family;


public class App extends Application {

    private GameLoopTimer timer ;
    private boolean isBonusActive = false;
    private long bonusEndTime = 0;

    @Override
    public void start(Stage stage) {
        /* Standard JavaFX stage creation */
        var canvas = new Canvas(1600, 900);

        canvas.getGraphicsContext2D().fillRect(0, 0, 1600, 900);

        var scene = new Scene(new StackPane(canvas), 1600, 900);

        stage.setScene(scene);
        stage.setResizable(false);
        stage.setFullScreen(false);
        stage.show();

        /* Ashley engine initialization */
        Engine world = new Engine();

        /* Helper objects initialization */
        Font font = new Font("Vera.ttf", 25);
        // Keyboard keyboard = new Keyboard(scene);
        Mouse mouse = new Mouse(canvas);
        EntityCreator creator = new EntityCreator(world);

        Score score = new Score(0);

        Bonus bonus = new Bonus();

        /* Adds a target spawner */

        creator.create(
            new Spawner(1, 0, 0, 1550, 850),
            new SimpleBoxSpawnType(),
            new MovingBoxSpawnType()
        );

        creator.create(
            new Spawner(10, 0, 0, 1550, 850),
            new BonusBoxSpawnType()
        );

        /* System registration */
        SimpleBoxSpawnerSystem simpleBoxSpawnerSystem = new SimpleBoxSpawnerSystem(Color.GOLDENROD);
        world.addSystem(simpleBoxSpawnerSystem);
        MovingBoxSpawnerType movingBoxSpawnerType = new MovingBoxSpawnerType(Color.RED);
        world.addSystem(movingBoxSpawnerType);
        BonusSpawnerSystem bonusSpawnerSystem = new BonusSpawnerSystem(Color.BLUE);
        world.addSystem(bonusSpawnerSystem);
        ExplosionSpawnerSystem explosionSpawnerSystem = new ExplosionSpawnerSystem(Color.DARKORANGE);
        world.addSystem(explosionSpawnerSystem);
        BulletCollisionSystem bulletCollisionSystem = new BulletCollisionSystem();
        world.addSystem(bulletCollisionSystem);
        world.addSystem(new LimitedLifespanSystem());
        VelocitySystem velocitySystem = new VelocitySystem();
        world.addSystem(velocitySystem);
        AlphaDecaySystem alphaSystem = new AlphaDecaySystem();
        world.addEntityListener(Family.all(Target.class).get(), alphaSystem);
        world.addSystem(alphaSystem);
        world.addSystem(new BoxShapeRenderer(canvas));
        world.addSystem(new CircleShapeRenderer(canvas));

        score.add(bulletCollisionSystem.getTargetDestroyedSignal());
        bonus.add(bulletCollisionSystem.getTargetDestroyedSignal());

        bulletCollisionSystem.getTargetDestroyedSignal().add((signal, event) -> {
            explosionSpawnerSystem.spawn(event.x, event.y);
            if(bonus.getBonus()){
                isBonusActive = true;
                bonusEndTime = System.currentTimeMillis() / 1000 + 10;
                world.removeSystem(movingBoxSpawnerType);
                world.removeSystem(simpleBoxSpawnerSystem);
                world.removeSystem(bonusSpawnerSystem);
                world.removeSystem(velocitySystem);
                bonus.setBonus();
            }
        });
        
        timer = new GameLoopTimer() {
            private long startTime = System.currentTimeMillis()/ 1000 +120;
            @Override
            public void tick(float secondsSinceLastFrame) {
                if (mouse.isJustPressed(MouseButton.PRIMARY)) {
                    creator.createBullet(mouse.getX(), mouse.getY());
                    mouse.resetJustPressed();
                    
                }

                long currentTime = System.currentTimeMillis() / 1000 ;
                long elapsedTime = startTime-currentTime;

                if (isBonusActive) {
                    if (currentTime >= bonusEndTime) {
                        world.addSystem(simpleBoxSpawnerSystem);
                        world.addSystem(movingBoxSpawnerType);
                        world.addSystem(bonusSpawnerSystem);
                        world.addSystem(velocitySystem);
                        isBonusActive = false;
                    }
                }

                GraphicsContext gc = canvas.getGraphicsContext2D();
                gc.save();   
                gc.setFill(Color.BLACK);
                gc.fillRect(0, 0, 1600, 900);
                gc.setFill(Color.WHITE);
                gc.setFont(font);
                gc.fillText("Score "+String.valueOf(score.getScore()), 30, 35);
                gc.fillText("Time : " + elapsedTime +"s",1425,35);
                world.update(secondsSinceLastFrame);
                if(elapsedTime == 0){
                    timer.stop();
                    try{
                        Thread.sleep(1000);
                    } catch(InterruptedException e){
                        e.printStackTrace();
                    }
                    gc.setFill(Color.BLACK);
                    gc.fillRect(0, 0, 1600, 900);
                    gc.setFill(Color.WHITE);
                    gc.fillText("Score "+String.valueOf(score.getScore()), 800, 450);
                }
            }

        };

        timer.start();
    }

    public static void main(String[] args) {
        launch();
    }
}