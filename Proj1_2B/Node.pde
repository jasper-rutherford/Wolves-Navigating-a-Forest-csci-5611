//Node Object. Used with/in RRT
//CSCI 5611 Project 1.2B
// Jasper Rutherford <ruthe124@umn.edu>

public class Node
{
    public Vec2 pos;                  //the node's position
    public Node prev;                 //the node that leads to this one
    public ArrayList<Node> nexts;     //all the nodes this one leads to
    public float dist;                //the distance from the goal to this node along the rrt
    
    //if prev is null then it is the goal node
    public Node(Vec2 pos, Node prev) 
    {
        this.pos = pos;
        this.prev = prev;
        nexts = new ArrayList<Node>();
        
        if (prev == null)
        {
            this.dist = 0;
        }
        else
        {
            this.prev.nexts.add(this);
            this.dist = pos.distanceTo(prev.pos) + prev.dist;
        }
    }
    
    //used when a node changes its prevNode.
    //updates its own distance, then updates the
    //distance of all the nodes that lead to this one.
    public void updateDist()
    {
        //update this node's distance to the goal
        dist = pos.distanceTo(prev.pos) + prev.dist;
        
        //update the distance of all the nodes that lead to this one
        for (int lcv = 0; lcv < nexts.size(); lcv++)
        {
            nexts.get(lcv).updateDist();            
        }
    }
    
    //draws a line to each of it's next nodes, and then requests that they each do the same.
    public void drawEdges()
    {
        for (int lcv = 0; lcv < nexts.size(); lcv++)
        {
            //get a next Node
            Node aNode = nexts.get(lcv);
            
            //draw a line between this and aNode
            stroke(100, 100, 100);
            strokeWeight(1);    
            line(pos.x, pos.y, aNode.pos.x, aNode.pos.y);
            
            //have aNode draw its edges
            aNode.drawEdges();
        }
    }
}
