import java.util.*;
  
public class Polyhedron {
  int index;
  float pointSize;
  PVector drawPoint;
  Map<Integer, PVector> points;
  Map<Integer, Set<Integer>> edges;
  
  public Polyhedron(float ps, PVector dp){
    index = 0;
    pointSize = ps;
    drawPoint = dp.copy();
    points = new HashMap<Integer, PVector>();
  }
  
  public void add(PVector p){
    if (p.z != 0){ points.put(index, p.copy()); }
    index++;
  }
  
  public ArrayList<PVector> getPoints(){
    ArrayList<PVector> returnPoints = new ArrayList<PVector>();
    for (PVector p : points.values()){
      returnPoints.add(p.copy());
    }
    return returnPoints;
  }
  
  public ArrayList<PVector> getPointsSorted(){
    ArrayList<PVector> returnPoints = new ArrayList<PVector>();
    for (PVector p : points.values()){
      returnPoints.add(p);
    }
    
    // Sorting algorithm
    boolean swapped = true;
    while (swapped){
      swapped = false;
      for (int i = 1; i < returnPoints.size(); i++){
        PVector p1 = returnPoints.get(i-1), p2 = returnPoints.get(i);
        if (compare(p1, p2) > 0){
          Collections.swap(returnPoints, i-1, i);
          swapped = true;
        }
      }
    }
    
    return returnPoints;
  }
  
  public int compare(PVector p1, PVector p2){
    //float distance1 = (float)Math.hypot(Math.hypot(p1.x, p1.y), p1.z+drawPoint.z);
    //float distance2 = (float)Math.hypot(Math.hypot(p2.x, p2.y), p2.z+drawPoint.z);
    float distance1 = p1.z+drawPoint.z, distance2 = p2.z+drawPoint.z;
    if (distance1 < distance2){ return 1; }
    if (distance1 > distance2){ return -1; }
    return 0;
  }
  
  public void rotateHorizontally(float degrees){
    rotate(degrees, 0);
  }
  
  public void rotateVertically(float degrees){
    rotate(degrees, 1);
  }
  
  public void rotateClockwise(float degrees){
    rotate(degrees, 2);
  }
  
  private void rotate(float degrees, int direction){
    float angle = degrees*PI/180;
    Map<Integer, PVector> newPoints = new HashMap<Integer, PVector>();
    for (int i : points.keySet()){
      PVector p = points.get(i);
      switch (direction){
        case 0:
          newPoints.put(i, new PVector(p.x*cos(angle)-p.z*sin(angle), p.y, p.z*cos(angle)+p.x*sin(angle)));
          break;
        case 1:
          newPoints.put(i, new PVector(p.x, p.y*cos(angle)+p.z*sin(angle), p.z*cos(angle)-p.y*sin(angle)));
          break;
        case 2:
          newPoints.put(i, new PVector(p.x*cos(angle)-p.y*sin(angle), p.y*cos(angle)+p.x*sin(angle), p.z));
          break;
        default:
          break;
      }
    }
    points = newPoints;
  }
  
  public void draw(){
    for (PVector p : getPointsSorted()){
      float x = p.x, y = p.y, z = p.z;
      z += drawPoint.z;
      z /= 100;
      x /= z; y /= z;
      x += drawPoint.x;
      y += drawPoint.y;
      circle(x, y, 10*pointSize/z);
    }
  }
}
