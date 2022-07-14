//Tree Object. It's basically a circle.
//CSCI 5611 Project 1.2B
// Jasper Rutherford <ruthe124@umn.edu>

public class Tree
{
    public Vec2 center;
    public float radius;
    public float colRad;    //the radius of the tree combined with the radius of a woid
    
    //woidRad is the radius of the woid collision circle
    public Tree(Vec2 center, float radius)
    {
        this.center = center;
        this.radius = radius;
        colRad = radius + woidRad;
    }
    
    public void drawImage()
    {
        beginShape();
        float hX = (float)(radius * Math.sin(Math.PI / 4));  //helper values for drawing the image
        float hY = (float)(radius * Math.cos(Math.PI / 4));
        pushMatrix();
        translate(center.x, center.y);
        beginShape();
        texture(imgTree);
        vertex( - hX, -hY, 0, 0,   0);
        vertex(hX, -hY, 0, imgTree.width, 0);
        vertex(hX,  hY, 0, imgTree.width, imgTree.height);
        vertex( -hX,  hY, 0, 0, imgTree.height);
        endShape();
        popMatrix();
    }
}
