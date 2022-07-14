//Woid Class (Wolf-boid)
//CSCI 5611 Project 1.2B
// Jasper Rutherford <ruthe124@umn.edu>

public class Woid
{
    //vectors to represent motion
    public Vec2 pos;
    public Vec2 vel;
    public Vec2 acc;
    public Node currNode;
    
    //the index of the woid in woids
    public int id;
    
    //creates a woid with given id and position, and generates a random direction to move in at initialSpeed
    public Woid(Vec2 pos)
    {
        this.pos = pos;
        currNode = bestNode();//rrt.nearestNode(pos);// bestStartNode();  //currNode defaults to the closest
        
        //generates a random starting direction
        vel = new Vec2( -1 + random(2), -1 + random(2));  //taken from Boids2D
        vel.normalize();                             //taken from Boids2D
        
        vel.mul(initialWoidSpeed);
    }
    
    public void update()
    {
        //updatecurrNode 
        updateCurrNode();
        
        //reset the acceleration vector
        acc = new Vec2(0, 0);
        Vec2 dir;                               //helper vector dir declared here instead of declaring a million dir's across the rest of the function
        
        //add force pulling woid to currNode 
        dir = currNode.pos.minus(pos).normalized();
        acc.add(dir.times(10));
        
        //add force pushing away from obstacles if the woid is less than minDist units away from touching it
        float minDist = 50;     //minimum distance to collision to apply a force
        float maxForce = 10;    //maximum force to apply to avoid a tree
        for (int lcv = 0; lcv < trees.size(); lcv++)
        {
            //the tree being looked at
            Tree tree = trees.get(lcv);
            
            //check if going to collide with this tree 
            hitInfo hit = rayCircleIntersect(tree.center, tree.radius, pos, vel.normalized(), minDist);
            if (hit.hit)
            {
                //time to collision
                float t = hit.t / vel.length();
                
                //direction to move in at time of collision
                dir = pos.plus(vel.times(t).minus(tree.center));
                
                //force to apply to the woid to avoid the collision with the tree 
                if (t != 0)
                {
                    dir.mul(maxForce / t); 
                }

                //apply the force
                acc.add(dir);                
            }
        }
        
        //adds a force away from the fire
        if (fireActive)
        {
            Vec2 mousePoint = new Vec2(mouseX, mouseY);
            float dist = mousePoint.distanceTo(pos);
            float maxFireDist = 300;
            if (dist < maxFireDist)
            {
                dir = mousePoint.minus(pos).normalized();
                acc.subtract(dir.times(pow(300 * dist / maxFireDist, 2)));
            }
        }
        
        
        //I took all three boid forces from boids2D and edited them a little bit
        
        //Separation force (push away from each woid if too close)
        for (int lcv = 0; lcv < woids.size(); lcv++)
        { 
            //Go through woids
            Woid aWoid = woids.get(lcv);
            float dist = pos.distanceTo(aWoid.pos);
            if (dist <.01 || dist > woidRad * 2.5) continue;
            Vec2 separationForce = pos.minus(aWoid.pos).normalized();
            separationForce.mul(30);
            acc.add(separationForce);
        }
        
        //Attraction force (move towards the average position of the woids)
        Vec2 avgPos = new Vec2(0,0);
        int count = 0;
        for (int lcv = 0; lcv < woids.size(); lcv++)
        { 
            //Go through each woid
            Woid aWoid = woids.get(lcv);
            float dist = pos.distanceTo(aWoid.pos);
            if (dist < woidRad * 5 && dist > 0)
            {
                avgPos.add(aWoid.pos);
                count += 1;
            }
        }
        avgPos.mul(1.0 / count);
        if (count >= 1)
        {
            Vec2 attractionForce = avgPos.minus(pos);
            attractionForce.normalize();
            attractionForce.mul(10);
            // attractionForce.clampToLength(maxForce);
            acc.add(attractionForce);
        }
        
        //I found it worked better without an alignment force.

        // //Alignment force
        // Vec2 avgVel = new Vec2(0,0);
        // count = 0;
        // for (int lcv = 0; lcv < woids.size(); lcv++)
        // {
        //     //Go through each woid
        //     Woid aWoid = woids.get(lcv);
        //     float dist = pos.distanceTo(aWoid.pos);
        //     if (dist < woidRad * 4 && dist > 0) 
        //     {
        //         avgVel.add(aWoid.vel);
        //         count += 1;
        //     }
        // }
        // avgVel.mul(1.0 / count);
        // if (count >= 1) {
        //     Vec2 towards = avgVel.minus(vel);
        //     towards.normalize();
        //     acc.add(towards.times(2));
        // }
        
        //Max speed
        if (vel.length() > maxSpeed) 
        {
            vel = vel.normalized().times(maxSpeed);
        }
        
        //move woid
        pos = pos.plus(vel.times(dt));
        vel = vel.plus(acc.times(dt));
    }
    
    // updates the woid's current node
    public void updateCurrNode()
    {
        //if the woid is in the meadow
        if (pos.distanceTo(meadow.center) < meadow.radius)
        {
            //target the nearest rabbit
            Rabbit nearRabbit = nearestRabbit();
            currNode = new Node(nearRabbit.pos, null);

            //if the woid is close enough to a rabbit to eat it
            if (pointInCircle(nearRabbit.pos, rabbitRad, pos, woidRad))
            {
                //eat the rabbit 
                meadow.removeRabbit(nearRabbit.id);

                //remove the woid from the map
                woids.remove(id);
                
                for (int lcv = 0; lcv < woids.size(); lcv++)
                {
                    woids.get(lcv).id = lcv;
                }
            }
        }

        //if the woid cannot see its current node
        if (rayTreeListIntersect(trees, pos, vel.normalized(), pos.distanceTo(currNode.pos)).hit)
        {
            //sets the current node to be the node (of all the nodes in the rrt) whose (distance to the goal) + (distance to the woid) is minimized
            currNode = bestNode();
        }
        
        
        //get the node along the path that is closest to the goal and can currently be seen by the woid and set that node to be the current node
        //loop checks all the nodes in the current path (and does nothing if currNode == null)
        Node aNode = currNode;
        while(aNode != null)
        {
            //hitInfo for if the woid tried to go to this node
            hitInfo hit = rayTreeListIntersect(trees, pos, vel.normalized(), pos.distanceTo(aNode.pos));
            
            //if there are no trees between the woid and the node
            if (!hit.hit)
            {
                //set it to be the current node to move towards
                currNode = aNode;
            }
            
            //advance the search down the path
            aNode = aNode.prev;
        }
    }
    
    //pick avisible node that minimizes (distance to goal) + (distance to woid)
    public Node bestNode()
    {
        Node bestNode = null;   
        float bestDist = sqrt(pow(displayWidth, 2) + pow(displayHeight, 2));     //default to the maximum possible distance (the diagonal of the screen)
        
        for (int lcv = 0; lcv < rrt.nodes.size(); lcv++)
        {
            Node aNode = rrt.nodes.get(lcv);
            float dist = aNode.dist + pos.distanceTo(aNode.pos);    //calculate the  (distance to goal) + (distance to woid) for this node
            
            //node is best if it has good distance and the woid can see the node
            // (only checks for visibility if the distance is good)
            if (dist < bestDist && !rayTreeListIntersect(trees, pos, aNode.pos.minus(pos).normalized(), aNode.pos.distanceTo(pos)).hit)
            {
                bestNode = aNode;
                bestDist = dist;
            }
        }
        
        //if there are zero visible nodes, just go with the nearest node
        if (bestNode == null)
        {
            bestNode = rrt.nearestNode(pos);
        }
        
        //return the node
        return bestNode;
    }
    
    public void draw()
        {
        //draw the woid
        circle(pos.x, pos.y, woidRad * 2);
    }
    
    public void drawImage()
    {
        //calculate angle
        double theta;
        if (vel.x >=  0 && vel.y >= 0)
            {
            theta = Math.asin(abs(vel.y) / vel.length());
        }
        else if (vel.x < 0 && vel.y >= 0)
            {
            theta = Math.PI - Math.asin(abs(vel.y) / vel.length());
        }
        else if (vel.x < 0 && vel.y < 0)
            {
            theta = Math.PI + Math.asin(abs(vel.y) / vel.length());
        }
        else 
            {
            theta = (Math.PI * 2) - Math.asin(abs(vel.y) / vel.length());
        }
        
        beginShape();
        float hX = (float)(woidRad * Math.sin(Math.PI / 4));  //helper values for drawing the image
        float hY = (float)(woidRad * Math.cos(Math.PI / 4));
        pushMatrix();
        translate(pos.x, pos.y);
        rotateZ((float)theta);
        beginShape();
        texture(imgWoid);
        vertex( -hX, -hY, 0, 0,   0);
        vertex(hX, -hY, 0, imgWoid.width, 0);
        vertex(hX,  hY, 0, imgWoid.width, imgWoid.height);
        vertex( -hX,hY, 0, 0, imgWoid.height);
        endShape();
        popMatrix();
    }

    //the rabbit closest to this woid
    public Rabbit nearestRabbit()
    {
        Rabbit near = meadow.rabbits.get(0);
        float nearDist = near.pos.distanceTo(pos);
        for (int lcv = 0; lcv < meadow.rabbits.size(); lcv++)
        {
            Rabbit aRabbit = meadow.rabbits.get(lcv);
            float dist = aRabbit.pos.distanceTo(pos);
            if (dist < nearDist)
            {
                near = aRabbit;
                nearDist = dist;
            }
        }

        return near;
    }
}
