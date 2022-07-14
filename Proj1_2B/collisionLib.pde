//
//          Author:
//      Jasper Rutherford
//        
//          Date:
//        9/22/2021
//        
//         Edited:
//        10/3/2021
//



/////////
// Point Intersection Tests
/////////

//Returns true iff the point, pointPos, is inside the box defined by boxTopLeft, boxW, and boxH
boolean pointInBox(Vec2 boxTopLeft, float boxW, float boxH, Vec2 pointPos) {
    //default the checks to false.
    boolean widthCheck = false;
    boolean heightCheck = false;
    
    //if the point is greater than the box's leftmost coordinate and less than the box's rightmost coordinate, pass the width check. 
    if (pointPos.x > boxTopLeft.x && pointPos.x < boxTopLeft.x + boxW)
    {
        widthCheck = true; 
    }
    
    //ifthe point is greater than the box's topmost coordinate and less than the box's bottommost coordinate, pass the height check. 
    if (pointPos.y > boxTopLeft.y && pointPos.y < boxTopLeft.y + boxH)
    {
        heightCheck = true; 
    }
    
    //returnvalue is true if both checks pass and false otherwise.
    return widthCheck && heightCheck;
}

//checks if a circle with a center at pointPos and a radius of radius is inside the box defined by boxTopLeft, boxW, and boxH
boolean circleInBox(Vec2 boxTopLeft, float boxW, float boxH, Vec2 pointPos, float radius)
{
    return pointInBox(new Vec2(boxTopLeft.x + radius, boxTopLeft.y + radius), boxW - 2 * radius, boxH - 2 * radius, pointPos);
}

//Returns true iff the point, pointPos, is inside a circle defined by center and radius r
// If eps isnon - zero, count the point as "inside" the circle if the point is outside, but within the distance eps of the edge
boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps) {
    //check if the point is less than r distance from the center, or if it is less than r + eps distance from the center if eps is not zero  
    return center.distanceTo(pointPos) < r || (eps != 0 && center.distanceTo(pointPos) < (r + eps));
}

//checks if the given point is within the collision radius of any of the trees, otherwise behaves the same as before
boolean pointInTreeList(ArrayList <Tree> trees, Vec2 pointPos, float eps) {
    
    //generate return variable
    boolean out = false;
    
    //loop through numObstacles centers and check for collisions
    for (int lcv = 0; lcv < trees.size(); lcv++)                    
    {
        //out is true ifit was already true or if it intersects the current circle
        out = out || pointInCircle(trees.get(lcv).center, trees.get(lcv).radius, pointPos, eps);
    }
    
    // return the return value
    return out;
}


/////////
// Ray Intersection Tests
/////////

//This struct is used for ray - obstacle intersection.
//It store both if there is a collision, and how far away it is(int terms of distance allong the ray)
class hitInfo{
    public boolean hit = false;
    public float t = 9999999;
}

hitInfo rayCircleIntersect(Vec2 center, float r, Vec2 l_start, Vec2 l_dir, float max_t) {
    hitInfo hit = new hitInfo();
    
    //Step 2 : Compute W - a displacement vector pointing from the start of the line segment to the center of the circle
    Vec2 toCircle = center.minus(l_start);
    
    //Step 3 : Solve quadratic equation for intersection point(in terms of l_dir and toCircle)
    float a = 1;  //Length of l_dir (we normalized it)
    float b = -2 * dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
    float c = toCircle.lengthSqr() - (r + strokeWidth) * (r + strokeWidth); //different of squared distances
    
    float d = b * b - 4 * a * c;//discriminant 
    
    if (d >=  0) { 
        //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
        //... this means t will be between 0 and the length of the line segment
        float t1 = ( -b - sqrt(d)) / (2 * a); //Optimization: we only need the first collision
        float t2 = ( -b + sqrt(d)) / (2 * a); //Optimization: we only need the first collision
        //println(hit.t,t1,t2);
        if (t1 > 0 && t1 < max_t) {
            hit.hit = true;
            hit.t = t1;
        }
        else if (t1 < 0 && t2 > 0) {
            hit.hit = true;
            hit.t = 0;  //I switched this to zero
        }
        
    }
    
    return hit;
}

//This function does the same stuff as before with circles, but now it returns the hitInfo  
// for the first circle that the ray would intersect
hitInfo rayTreeListIntersect(ArrayList<Tree> trees, Vec2 l_start, Vec2 l_dir, float max_t) 
{    
    //generate the return variable. 
    hitInfo hit = new hitInfo();
    
    //loop through trees to check for ray intersections
    for (int lcv = 0; lcv < trees.size(); lcv++)
    {
        //hit info for the lcvth circle's ray intersection
        hitInfo newHit = rayCircleIntersect(trees.get(lcv).center, trees.get(lcv).colRad, l_start, l_dir, max_t);

        //if it's a hit
        if (newHit.hit)
        {
            //if this is the first succesful hit, just set it
            if (!hit.hit)
            {
                hit = newHit;
            }
            //otherwise if there was a previous hit, compare them and keep the one with the smaller distance
            else
            {
                if (newHit.t < hit.t)
                {
                    hit = newHit;
                }
            }
        }
    }

    //hit will still be the default hit if no circles were hit
    return hit;
}
