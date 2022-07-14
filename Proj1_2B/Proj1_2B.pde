//Wolf boids navigate through a forest to get to some rabbits
//Project 1 2B
//Jasper Rutherford <ruthe124@umn.edu>

Meadow meadow;

int displayWidth = 1024;                            //The width of the screen
int displayHeight = 768;                            //the height of the screen

float meadowRad = 75;                               //the radius of the meadow
float rabbitRad = 10;                               //the radius of a rabbit

int numTrees = 100;                                 //the number of trees
float maxTreeRad = 30;                              //the maximum tree radius
float minTreeRad = 10;                              //the minimum tree radius
ArrayList<Tree> trees;                              //the list of trees

int numNodes = 1000;                                //the number of nodes to use for the rrt
RRT rrt;                                            //the rrt
boolean drawGraph = false;                          //whether or not to draw the graph     
boolean drawCircles = false;                        //whether or not to draw the bounding circles       

int numWoids = 25;                                  //the number of woids to spawn initially
float woidRad = 10;                                 //the radius of each woid
ArrayList<Woid> woids;                              //the list of woids
float packSpawnRadius = 100;                        //how far from the center of the pack the woids can spawn
float initialWoidSpeed = 0;
float maxSpeed = 15;
float dt = 0.1;

boolean fireActive = false;                         //whether or not fire is active
float fireRadius = 15;

PImage imgRabbit; 
PImage imgTree; 
PImage imgWoid; 
PImage imgFire; 



int strokeWidth = 2;
void setup() 
{
    //set screen size
    size(displayWidth, displayHeight, P3D);
    
    //set the title
    surface.setTitle("Woids in a forest");
    
    //load the images
    imgRabbit = loadImage("rabbit.jpg");
    imgTree = loadImage("tree.jpg");
    imgWoid = loadImage("woid.jpg");
    imgFire = loadImage("fire.jpg");
    
    //generates a meadow with radius meadowRad at a random spot on the screen where the whole meadow is on the screen
    meadow = new Meadow(new Vec2(random(meadowRad, displayWidth - meadowRad), random(meadowRad, displayHeight - meadowRad)), meadowRad);

    //spawn numTrees trees with random positions (that could make part of the tree go off the screen) 
    //& radii between minTreeRad and maxTreeRad
    trees = new ArrayList<Tree>();
    for (int lcv = 0; lcv < numTrees; lcv++)  
    {   
        //random valid radius, the pow makes it favor larger trees
        float treeRad = (minTreeRad + (maxTreeRad - minTreeRad) * pow(random(1), 3));
        
        //generate a random point that isn't in the meadow and doesnt overlap with the meadow
        Vec2 treePos = new Vec2(random(0, displayWidth), random(0, displayHeight));
        boolean intersects = pointInCircle(meadow.center, meadow.radius, treePos, treeRad); 
        while(intersects)
        {
            treePos = new Vec2(random(0, displayWidth), random(0, displayHeight));
            intersects = pointInCircle(meadow.center, meadow.radius, treePos, treeRad); 
        }
        
        trees.add(new Tree(treePos, treeRad));
    }
    
    //generate the RRT
    rrt = new RRT(meadow, trees, numNodes, displayWidth, displayHeight); //I realized after writing this bit that I don't actually have to pass these in, and that the other classes have access to these variables, but I've decided not to change it because it works.
    
    //initialize the list of woids
    woids = new ArrayList<Woid>();
    
    //choose a random point to spawn woids around
    Vec2 packCenter = new Vec2(random(0, displayWidth), random(0, displayHeight));
    
    //spawn numWoids woids within packSpawnRadius distance from packCenter
    for (int lcv = 0; lcv < numWoids; lcv++)
    {
        //generate a random position in the pack spawn zone that is on the screen and not in a tree
        float r = packSpawnRadius * sqrt(random(1));
        
        Vec2 dir = new Vec2( -1 + random(2), -1 + random(2));  //taken from Boids2D
        dir.normalize();  
        
        Vec2 woidSpawnPoint = packCenter.plus(dir.times(r));
        
        //check if too close to a woid
        boolean tooClose = false;
        for (int lcv2 = 0; lcv2 < woids.size(); lcv2++)
        {
            tooClose = tooClose || pointInCircle(woids.get(lcv2).pos, woidRad, woidSpawnPoint, woidRad);
        }

        //while not on screen or in a tree or too close to a woid
        while(!circleInBox(new Vec2(0, 0), displayWidth, displayHeight, woidSpawnPoint, woidRad) || pointInTreeList(trees, woidSpawnPoint, woidRad) || tooClose)
        {
            r = packSpawnRadius * sqrt(random(1));
            dir = new Vec2( -1 + random(2), -1 + random(2));  //taken from Boids2D
            dir.normalize(); 
            woidSpawnPoint = packCenter.plus(dir.times(r));

            tooClose = false;
            for (int lcv2 = 0; lcv2 < woids.size(); lcv2++)
            {
                tooClose = tooClose || pointInCircle(woids.get(lcv2).pos, woidRad, woidSpawnPoint, woidRad);
            }
        }
        
        //add the new woid to the list
        woids.add(new Woid(woidSpawnPoint));
        woids.get(lcv).id = lcv;
    }
}

void draw()
{ 
    
    //set background color to green (it's grass!)
    background(152,190,100);
    
    // Draw the meadow's bounding circle as requested
    if (drawCircles)
    {
        noFill();
        circle(meadow.center.x, meadow.center.y, meadow.radius * 2);
    }
    
    //Draw the meadow's rabbits 
    meadow.drawRabbits();   
    
    //draw the trees
    fill(60, 143, 74);
    for (int lcv = 0; lcv < trees.size(); lcv++) 
    {      
        Tree tree = trees.get(lcv);
        
        // Draw the tree's bounding circle as requested
        if (drawCircles)
        {
            noFill();
            circle(tree.center.x, tree.center.y, tree.radius * 2);
        }

        //draw the image
        tree.drawImage();
    }
    
    // //draw extra circles around the trees to represent how close a woid's center can come
    // noFill();
    // for (int lcv = 0; lcv < trees.size(); lcv++) 
    // {      
    //     Tree tree = trees.get(lcv);
    //     circle(tree.center.x, tree.center.y,(tree.radius + woidRad) * 2);
// }
    
    //draw nodes/edges of rrt
    if (drawGraph)
        rrt.drawGraph();
    
    //draw the Woids
    fill(133, 146, 148);
    for (int lcv = 0; lcv < woids.size(); lcv++) 
    {
        // Draw the woid's bounding circle as requested
        if (drawCircles)
        {
            noFill();
            woids.get(lcv).draw();
        }

        //draw image
        woids.get(lcv).drawImage();
    }
    
    //draw the fire
    if (fireActive)
    {
        // Draw the fire's bounding circle as requested
        if (drawCircles)
        {
            noFill();
            circle(mouseX, mouseY, fireRadius * 2);
        }

        beginShape();
        float hX = (float)(fireRadius * Math.sin(Math.PI / 4));  //helper values for drawing the image
        float hY = (float)(fireRadius * Math.cos(Math.PI / 4));
        pushMatrix();
        translate(mouseX, mouseY);
        beginShape();
        texture(imgFire);
        vertex( -hX, -hY, 0, 0,   0);
        vertex(hX, -hY, 0, imgFire.width, 0);
        vertex(hX,  hY, 0, imgFire.width, imgFire.height);
        vertex( -hX,  hY, 0, 0, imgFire.height);
        endShape();
        popMatrix();
    }
    
    //update the woids 
    for (int lcv = 0; lcv < woids.size(); lcv++) 
    {
        woids.get(lcv).update();
    }
}


void mousePressed() 
{
    //form fire at the location of the mouse when the left mouse is held
    if (mouseButton == LEFT)
    {
        fireActive = true;    
        maxSpeed *= 2;
    }
    
    //spawn a woid (and a rabbit for the woid) at the mouse when you right click
    if (mouseButton == RIGHT)
    {
        //add the new woid to the list
        woids.add(new Woid(new Vec2(mouseX, mouseY)));
        woids.get(woids.size() - 1).id = woids.size() - 1;

        //add a new rabbit to the meadow 
        meadow.addRabbit();
    }
}

void mouseReleased() 
{
    //form fire at the location of the mouse when the left mouse is held
    if (mouseButton == LEFT)
    {
        fireActive = false;
        maxSpeed /= 2;
    }
}

void keyPressed() 
{
    //toggle graph display
    if (key == 'g') 
    {
        drawGraph = !drawGraph;
    }
    
    //toggle display bounding circles
    if (key == 'b') 
    {
        drawCircles = !drawCircles;
    }

    //load new map
    if (key == 'r')
    {
        setup();
    }
}
