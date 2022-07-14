//Meadow Object. It's where all the rabbits live, and is where all the woids want to go.
//CSCI 5611 Project 1.2B
// Jasper Rutherford <ruthe124@umn.edu>

public class Meadow
{
    public Vec2 center;
    public float radius;
    
    public ArrayList<Rabbit> rabbits;                          //the list of all the rabbits in the meadow
    
    public Meadow(Vec2 center, float radius) 
    {
        this.center = center;
        this.radius = radius;

        //initialize the list
        rabbits = new ArrayList<Rabbit>();

        //spawn a rabbit for every woid and add each rabbit to rabbits
        rabbits = new ArrayList<Rabbit>();
        for (int lcv = 0; lcv < numWoids; lcv++)
        {
            addRabbit();
        }
    }
    
    //no longer used. I added actual rabbits instead of one picture of several rabbits.
    public void drawImage()
    {
        // beginShape();
        // float hX = (float)(radius * Math.sin(Math.PI / 4));  //helper values for drawing the image
        // float hY = (float)(radius * Math.cos(Math.PI / 4));
        // pushMatrix();
        // translate(center.x, center.y);
        // beginShape();
        // texture(imgMeadow);
        // vertex( - hX, -hY, 0, 0,   0);
        // vertex(hX, -hY, 0, imgMeadow.width, 0);
        // vertex(hX,  hY, 0, imgMeadow.width, imgMeadow.height);
        // vertex( -hX,  hY, 0, 0, imgMeadow.height);
        // endShape();
        // popMatrix();
    }

    public void drawRabbits()
    {
        for (int lcv = 0; lcv < rabbits.size(); lcv++)
        {
            beginShape();
            float hX = (float)(rabbitRad * Math.sin(Math.PI / 4));  //helper values for drawing the image
            float hY = (float)(rabbitRad * Math.cos(Math.PI / 4));
            pushMatrix();
            translate(rabbits.get(lcv).pos.x, rabbits.get(lcv).pos.y);
            beginShape();
            texture(imgRabbit);
            vertex( - hX, -hY, 0, 0,   0);
            vertex(hX, -hY, 0, imgRabbit.width, 0);
            vertex(hX,  hY, 0, imgRabbit.width, imgRabbit.height);
            vertex( -hX,  hY, 0, 0, imgRabbit.height);
            endShape();
            popMatrix();
        }
    }

    //add a rabbit to a random position in the meadow
    public void addRabbit()
    {
        float r = radius * sqrt(random(1));
        Vec2 dir = new Vec2( -1 + random(2), -1 + random(2));  //taken from Boids2D
        dir.normalize(); 
        rabbits.add(new Rabbit(center.plus(dir.times(r))));
        rabbits.get(rabbits.size() - 1).id = rabbits.size() - 1;
    }

    //removes the given rabbit from the list and updates all the other rabbits' id's
    public void removeRabbit(int index)
    {
        rabbits.remove(index);
        for (int lcv = 0; lcv < rabbits.size(); lcv++)
        {
            rabbits.get(lcv).id = lcv;
        }
    }
}
