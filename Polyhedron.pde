import java.util.*;

final static float RATIO_ERROR = 0.001;  // Error for distances, to account for floating point error;
final static float UNIVERSAL_CONSTANT = 100;
  
public class Polyhedron {
  int index;
  PVector drawPoint;
  float pointSize, lineWidth;
  Map<Integer, PVector> points;
  Set<Line> lines;
  
  public Polyhedron(PVector dp, float ps, float lw){
    index = 0;
    drawPoint = dp.copy();
    float scale = dp.z/UNIVERSAL_CONSTANT;
    pointSize = ps*scale;
    lineWidth = lw*scale;
    points = new HashMap<Integer, PVector>();
    lines = new HashSet<Line>();
  }
  
  
  // METHODS FOR ALTERING THE POLYHEDRON
  
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
    if (p1.z < p2.z){ return 1; }
    if (p1.z > p2.z){ return -1; }
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
  
  public PVector getDrawPoint(){
    return drawPoint;
  }
  
  public void newDrawPoint(PVector dp){
    drawPoint = dp;
  }
  
  public void shiftDrawPoint(PVector dpShift){
    drawPoint.add(dpShift);
  }
  
  public void shift(PVector shift){
    for (int i : points.keySet()){
      PVector p = points.get(i);
      p.add(shift);
      points.put(i, p);
    }
  }
  public void translate(PVector shift){
    shift(shift);
  }
  
  public void scale(float scale){
    for (int i : points.keySet()){
      PVector p = points.get(i);
      p.mult(scale);
      points.put(i, p);
    }
  }
  
  public float distance(PVector p1, PVector p2){
    return pow(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2) + pow(p1.z-p2.z, 2), 0.5);
  }
  
  
  // METHODS FOR EDGES
  
  public void createNearestEdges(){
    for (int i : points.keySet()){
      float minDistance = (float)(Double.MAX_VALUE/2);
      PVector p = points.get(i);
      for (int n : points.keySet()){
        if (i != n){
          PVector pn = points.get(n);
          float distance = distance(p, pn);
          minDistance = min(minDistance, distance);
        }
      }
      createEdges(minDistance, i);
    }
  }
  
  public void createEdges(float distance){
    for (int i : points.keySet()){
      createEdges(distance, i);
    }
  }
  
  public void createEdges(float distance, int i){
    PVector p = points.get(i);
    for (int n : points.keySet()){
      PVector pn = points.get(n);
      float ratio = distance(p, pn)/distance;
      if ((ratio < (1 + RATIO_ERROR))&&(ratio > (1 - RATIO_ERROR))){
        lines.add(new Line(i, n));
      }
    }
  }
  
  public void clearEdges(){
    lines.clear();
  }
  
  public ArrayList<Line> getEdgesSorted(){
    ArrayList<Line> returnList = new ArrayList<Line>(lines);
    
    // Sorting algorithm
    boolean swapped = true;
    while (swapped){
      swapped = false; 
      for (int i = 1; i < returnList.size(); i++){
        Line l1 = returnList.get(i-1), l2 = returnList.get(i);
        if (l1.compareTo(l2, points) > 0){
          Collections.swap(returnList, i-1, i);
          swapped = true;
        }
      }
    }
    
    return returnList;
  }
  
  
  // DRAW METHODS
  
  public void draw(boolean corner, boolean edge){
    if (corner){ drawCorners(getPointsSorted()); }
    if (edge){ drawEdges(getEdgesSorted()); }
  }
  
  public void drawCorners(ArrayList<PVector> pVectors){
    for (PVector p : pVectors){
      PVector pt = transform(p);
      strokeWeight(max(0, lineWidth/pt.z));
      circle(pt.x, pt.y, pointSize/pt.z);
    }
  }
  
  public void drawEdges(ArrayList<Line> lines){
    for (Line l : lines){
      int[] indices = l.getIndices();
      PVector[] ends = new PVector[indices.length];
      boolean exists = true;
      for (int i = 0; i < indices.length; i++){
        PVector point = points.get(indices[i]);
        exists = exists&&(point != null);
        if (exists){ ends[i] = transform(points.get(indices[i])); }
      }
      if (exists){
        drawLine(ends[0], ends[1], 9);
      }
    }
  }
  
  private void drawLine(PVector p1, PVector p2, int depth){
    float zAverage = (p1.z+p2.z)/2;
    float strokeWeight = max(0, lineWidth/zAverage);
    float distance = pow(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2), 0.5);
    if ((strokeWeight < distance)||(depth <= 0)){
      strokeWeight(strokeWeight);
      line(p1.x, p1.y, p2.x, p2.y);
    } else {
      PVector pMid = PVector.add(p1, p2);
      pMid.div(2);
      drawLine(p1, pMid, depth-1);
      drawLine(pMid, p2, depth-1);
    }
  }
  
  public PVector transform(PVector p){
    float x = p.x, y = p.y, z = p.z;
    z /= 3;  // Prevents a fish-eye lens effect
    z += drawPoint.z;
    z /= UNIVERSAL_CONSTANT;
    x /= z; y /= z;
    x += drawPoint.x;
    y += drawPoint.y;
    return new PVector(x, y, z);
  }
}
