//RRT Object. It generates/stores all the points/paths and stuff. 
//CSCI 5611 Project 1.2B
// Jasper Rutherford <ruthe124@umn.edu>

public class RRT
{
    public Meadow meadow;
    public ArrayList<Tree> trees;
    public ArrayList<Node> nodes;
    
    public RRT(Meadow meadow, ArrayList<Tree> trees, int numNodes, int displayWidth, int displayHeight)
    {
        this.meadow = meadow;
        this.trees = trees;
        generateNodes();
    }
    
    public void generateNodes()
    {
        //initialize the list
        nodes = new ArrayList<Node>();
        
        //create goal node at the center of the meadow and add it to the list
        nodes.add(new Node(meadow.center, null));    
        
        //create numNodes nodes
        for (int lcv = 0; lcv < numNodes; lcv++)
        {
            //generate a random point that isn't in a tree and is far enough from the wall for a woid to exist on the node
            Vec2 point = new Vec2(random(0, displayWidth), random(0, displayHeight));
            boolean intersects = pointInTreeList(trees, point, woidRad); 
            while(!circleInBox(new Vec2(0, 0), displayWidth, displayHeight, point, woidRad) || intersects) 
            {
                point = new Vec2(random(0, displayWidth), random(0, displayHeight));
                intersects = pointInTreeList(trees, point, woidRad); 
            }
            
            //find the nearest node
            Node nearest = nearestNode(point);
            
            //check if there are any trees in the path from nearest to point
            float dist = point.distanceTo(nearest.pos);
            Vec2 dir = point.minus(nearest.pos);
            dir.normalize();
            hitInfo hit = rayTreeListIntersect(trees, nearest.pos, dir, dist);
            
            //if there are, move the point to be the point of intersection
            if (hit.hit)
            {
                point = nearest.pos.plus(dir.times(hit.t - 1)); //subtract 1 to keep it slightly out of the circle
            }
            
            //create a node for the point with the nearest node as its previous node
            //the constructor automatically adds this new node to nearest's list of nextNodes
            Node node = new Node(point, nearest);
            
            //adapt the path to keep the rrt optimalish
            for (int lcv2 = 0; lcv2 < nodes.size(); lcv2++)
            {
                //the node being checked for adaptation
                Node aNode = nodes.get(lcv2);
                
                //if the node could get to the goal faster by going to the new node
                //than by going to its previous node
                float a = node.dist + aNode.pos.distanceTo(node.pos);
                float b = aNode.dist;
                // println(a + " < " + b);
                if (a < b)
                {
                    // println("true?");
                    //check if a woid would intersect any trees to get to that node
                    dist = node.pos.distanceTo(aNode.pos);
                    dir = node.pos.minus(aNode.pos);
                    dir.normalize();

                    //if there are no intersections
                    if (!rayTreeListIntersect(trees, aNode.pos, dir, dist).hit)
                    {
                        //remove this node from its previous node's list of nextNodes
                        aNode.prev.nexts.remove(aNode);
                        
                        //set the new node to be this node's new previous node 
                        aNode.prev = node;

                        //add this node to node's nextList
                        aNode.prev.nexts.add(aNode);
                        
                        //update this node's distance 
                        //(this function also updates the dists for all the nodes that lead to this node)
                        aNode.updateDist();
                    }
                }
            }
            
            //add the new node to the list of nodes
            nodes.add(node);
        }
    }
    
    //returns the node in the list of nodes that is closest to the given point
    //assumes that nodes.size() > 0
    public Node nearestNode(Vec2 point)
    {
        //defaults to first node
        Node nearNode = nodes.get(0);
        float minDist = nearNode.pos.distanceTo(point);
        
        //skips the first node because it is the default
        for (int lcv = 1; lcv < nodes.size(); lcv++)
        {
            Node aNode = nodes.get(lcv);
            float aDist = aNode.pos.distanceTo(point);
            
            //if the node in question has a smaller distance than the previously found minDist
            if (aDist < minDist)
            {
                //set the node in question to be the nearNode
                nearNode = aNode;
                minDist = aDist;
            }
        }
        
        return nearNode;
    }
    
    public void drawGraph()
    {
        //Draw Nodes
        fill(0);
        for (int lcv = 0; lcv < nodes.size(); lcv++) 
        {
            Node aNode = nodes.get(lcv);
            circle(aNode.pos.x, aNode.pos.y, 5);
        }
        
        //Draw edges
        //(calling this on the goal node will have it cascade out to all nodes)
        nodes.get(0).drawEdges();
    }
}
