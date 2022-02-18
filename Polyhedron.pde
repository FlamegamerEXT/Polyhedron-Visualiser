import java.util.*;

final static float RATIO_ERROR = 0.001;  // Error for distances, to account for floating point error;
final static float UNIVERSAL_CONSTANT = 100;
final color NO_COLOUR = color(HSB, 0, 0, 0);

public class Polyhedron {
  int index;
  PVector drawPoint;
  float pointSize, lineWidth;
  Map<Integer, PVector> points;
  Set<Line> lines;
  Set<Face> faces;
  Map<Integer, Set<Integer>> links;
  color[] colours = new color[3];  // 0 -> points, 1 -> lines, 2 -> faces

  /** Initialise the Polyhedron object */
  public Polyhedron(PVector dp, float ps, float lw){
    index = 0;
    drawPoint = dp.copy();
    float scale = dp.z/UNIVERSAL_CONSTANT;
    pointSize = ps*scale;
    lineWidth = lw*scale;
    points = new HashMap<Integer, PVector>();
    lines = new HashSet<Line>();
    faces = new HashSet<Face>();
    links = new HashMap<Integer, Set<Integer>>();

    colorMode(HSB, 360, 100, 100);
    for (int i = 0; i < colours.length; i++){
      colours[i] = NO_COLOUR;
    }
  }


  // METHODS FOR ALTERING THE POLYHEDRON

  /** Adds a vertex to the polyhedron */
  public void add(PVector p){
    if (p.z != 0) {
      points.put(index, p.copy());
    }
    index++;
  }

  /** Returns the set of points that make up the vertices of the polyhedron */
  public ArrayList<PVector> getPoints(){
    ArrayList<PVector> returnPoints = new ArrayList<PVector>();
    for (PVector p : points.values()) {
      returnPoints.add(p.copy());
    }
    return returnPoints;
  }

  /** Returns the set of points in order of furthest to closest to the screen */
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

  /** Compares two pVectors to find which one is closest to the screen */
  public int compare(PVector p1, PVector p2){
    if (p1.z < p2.z) { return 1; }
    if (p1.z > p2.z) { return -1; }
    float dist1 = pow(pow(p1.x, 2) + pow(p1.y, 2), 0.5);
    float dist2 = pow(pow(p2.x, 2) + pow(p2.y, 2), 0.5);
    if (dist1 < dist2) { return 1; }
    if (dist1 > dist2) { return -1; }
    return 0;
  }

  /** Rotates the polyhedron in the XZ-axis */
  public void rotateHorizontally(float degrees){
    rotate(degrees, 0);
  }

  /** Rotates the polyhedron in the YZ-axis */
  public void rotateVertically(float degrees){
    rotate(degrees, 1);
  }

  /** Rotates the polyhedron in the XY-axis */
  public void rotateClockwise(float degrees){
    rotate(degrees, 2);
  }

  /** Rotates the polyhedron in the given direction */
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

  /** Returns the point at which the polyhedron will be drawn */
  public PVector getDrawPoint(){
    return drawPoint;
  }

  /** Gives a new point at which the polyhedron will be drawn */
  public void newDrawPoint(PVector dp){
    drawPoint = dp;
  }

  /** Translates the point at which the polyhedron will be drawn */
  public void shiftDrawPoint(PVector dpShift){
    drawPoint.add(dpShift);
  }

  /** Translates/shifts the positions of the vertices */
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

  /** Scales the positions of the vertices */
  public void scale(float scale){
    for (int i : points.keySet()){
      PVector p = points.get(i);
      p.mult(scale);
      points.put(i, p);
    }
  }

  /** Method to calculate the distance between two PVectors */
  public float distance(PVector p1, PVector p2){
    return pow(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2) + pow(p1.z-p2.z, 2), 0.5);
  }

  /** Returns the fill colour of the vertices */
  public void setPointColour(color c){
    colours[0] = c;
  }
  public void setPointColor(color c){
    colours[0] = c;
  }
  /** Gives a new fill colour for the vertices */
  public color getPointColour(){
    return colours[0];
  }
  public color getPointColor(){
    return colours[0];
  }

  /** Returns the stroke colour of the edges */
  public void setLineColour(color c){
    colours[1] = c;
  }
  public void setLineColor(color c){
    colours[1] = c;
  }
  /** Gives a new stroke colour of the edges */
  public color getLineColour(){
    return colours[1];
  }
  public color getLineColor(){
    return colours[1];
  }

  /** Returns the fill colour of the new faces */
  public void setFaceColour(color c){
    colours[2] = c;
  }
  public void setFaceColor(color c){
    colours[2] = c;
  }
  /** Gives a new fill colour for the new faces */
  public color getFaceColour(){
    return colours[2];
  }
  public color getFaceColor(){
    return colours[2];
  }

  /** Returns a set of indices that represents the lines between vertices
    * if calculate is given to be true, then the links will be recalculated */
  public Map<Integer, Set<Integer>> getLinks(boolean calculate){
    if (calculate) {
      for (int i : points.keySet()){
        links.put(i, new HashSet<Integer>());
      }
      for (Line l : lines){
        int[] indices = l.getIndices();
        for (int n = 0; n < indices.length; n++){
          Set<Integer> pointLinks = links.get(indices[n]);
          pointLinks.add(indices[indices.length-1-n]);
          links.put(indices[n], pointLinks);
        }
      }
    }
    return links;
  }

  /** Clears the links between vertices */
  public void clearLinks(){
    links.clear();
  }


  // METHODS FOR EDGES

  /** Creates lines between edges so that all of the vertices are linked by edges */
  public void createLinkingEdges(){
    ArrayList<Float> distances = new ArrayList<Float>();
    for (int i : points.keySet()){
      PVector p = points.get(i);
      for (int n : points.keySet()){
        if (i != n) {
          PVector pn = points.get(n);
          float distance = distance(p, pn);
          boolean notAddedYet = true;
          for (float d : distances){
            if ((distance > d * (1 - RATIO_ERROR))&&(distance < d * (1 + RATIO_ERROR))){
              notAddedYet = false;
              break;
            }
          }
          if (notAddedYet){
            distances.add(distance);
          }
        }
      }
    }
    Collections.sort(distances);
    for (int nd = 0; nd < distances.size(); nd++){
      // Link all pairs that are 'd' units apart
      float d = distances.get(nd);
      for (int i : points.keySet()){
        createEdges(d, i);
      }

      // Update the set of links
      getLinks(true);

      // Get one random index to start of the check for connectivity
      int randomIndex = 0;
      for (int i : points.keySet()){
        randomIndex = i;
        break;
      }

      // Check connectivity, and break loop if it is all connected
      ArrayList<Integer> linkedIndices = new ArrayList<Integer>();
      boolean connected = false;
      linkedIndices.add(randomIndex);
      for (int n = 0; n < linkedIndices.size(); n++){
        for (int i : links.get(linkedIndices.get(n))){
          if (!linkedIndices.contains(i)){
            linkedIndices.add(i);
          }
        }
        if (linkedIndices.size() == points.keySet().size()){
          connected = true;
          break;
        }
      }
      if (connected){
        break;
      }
    }
  }

  /** Links each vertex with the vertices closest to it */
  public void createNearestEdges(){
    for (int i : points.keySet()){
      float minDistance = Float.MAX_VALUE;
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

  /** Creates edges between all vertices that are a given distance apart */
  public void createEdges(float distance){
    for (int i : points.keySet()){
      createEdges(distance, i);
    }
    getLinks(true);
  }

  /** Creates edges between this vertex and other vertices that are the given distance apart */
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

  /** Clears the set of lines */
  public void clearEdges(){
    lines.clear();
  }

  /** Returns a list of edges, sorted so that the furthest from the screen are first, and closest are last */
  public ArrayList<Line> getEdgesSorted(){
    ArrayList<Line> returnList = new ArrayList<Line>(lines);

    // Sorting algorithm
    boolean swapped = (returnList.size() > 1);
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


  // METHODS FOR FACES

  /** Creates a set of faces to close the polyhedron */
  public void createLinkingFaces(){
    // Recommended that createLinkingEdges() is used beforehand to ensure that the necessary edges exist
    Set<Line> usedLines = new HashSet<Line>();
    for (int n = 3; n < ceil(points.size()*0.5); n++){
      createFaces(n, false);

      for (Face f : faces){
        if (f.getIndices().size() == n){
          for (Line l : f.getLines()){
            usedLines.add(l);
          }
        }
      }
      if (usedLines.size() >= lines.size()){
        break;
      }
    }
  }

  /** Creates faces with a given number of edges 
    * if (range), checks for faces with a number of sides between 3 and maxEdges
    * else, just check for faces with maxEdges sides */
  public void createFaces(int maxEdges, boolean range){
    // Initialise bounds
    maxEdges = abs(maxEdges);
    if (maxEdges < 3){
      return;
    }
    int minEdges = maxEdges;
    if (range){
      minEdges = 3;
    }

    // Initialise map that links the points via lines
    getLinks(true);
    Stack<ArrayList<Integer>> stack = new Stack<ArrayList<Integer>>();
    for (int i : points.keySet()){
      ArrayList<Integer> start = new ArrayList<Integer>();
      start.add(i);
      stack.push(start);
    }

    // Iterate through all possible paths, only adding complete faces to the set of faces
    while (!stack.isEmpty()){
      ArrayList<Integer> path = stack.pop();
      int firstIndex = path.get(0);
      int lastIndex = path.get(path.size()-1);
      for (int newIndex : links.get(lastIndex)){
        if (newIndex == firstIndex) {
          if ((path.size() >= minEdges)&&(path.size() <= maxEdges)){
            Face newFace = new Face(path);
            colorMode(HSB, 360, 100, 100);
            boolean notAdded = true;
            for (Face f : faces) {
              if (f.equals(newFace)){
                notAdded = false;
                break;
              }
            }
            if (notAdded){
              faces.add(newFace);
            }
          }
        } else if (path.size() < maxEdges){
          boolean viablePath = true;
          for (int i : path){
            if (i == newIndex){
              viablePath = false;
              break;
            }
          }
          if (viablePath){
            ArrayList<Integer> newPath = new ArrayList<Integer>(path);
            newPath.add(newIndex);
            stack.push(newPath);
          }
        }
      }
    }

    // Colour the faces
    int n = 0;
    for (Face f : faces){
      if (colours[2] == NO_COLOUR){
        f.setColor(color(random(360), 90, 90));
      } else {
        f.setColor(colours[2]);
      }
      n++;
    }
  }

  /** Clears the set of faces */
  public void clearFaces(){
    faces.clear();
  }

  /** Returns a list of faces, sorted so that the furthest from the screen are first, and closest are last */
  public ArrayList<Face> getFacesSorted(){
    ArrayList<Face> returnList = new ArrayList<Face>(faces);

    // Sorting algorithm
    boolean swapped = (returnList.size() > 1);
    while (swapped){
      swapped = false;
      for (int i = 1; i < returnList.size(); i++){
        Face f1 = returnList.get(i-1), f2 = returnList.get(i);
        if (f1.compareTo(f2, points) > 0){
          Collections.swap(returnList, i-1, i);
          swapped = true;
        }
      }
    }

    return returnList;
  }


  // DRAW METHODS

  /** Calls the necessary draw functions, based on the given boolean values */
  public void draw(boolean drawCorners, boolean drawEdges, boolean drawFaces){
    if (drawFaces) {
      drawFaces(getFacesSorted(), drawCorners, drawEdges);
    } else {
      if (colours[1] == NO_COLOUR){
        noStroke();
      }  // No black strokes
      else {
        stroke(colours[1]);
      }
      if (drawCorners){
        drawCorners(getPointsSorted());
      }

      if (drawEdges){
        for (Line l : getEdgesSorted()) {
          drawEdge(l);
        }
      }
    }
  }

  /** Draws all of the corners in the given ArrayList */
  public void drawCorners(ArrayList<PVector> pVectors){
    fill(colours[0]);
    for (PVector p : pVectors){
      PVector pt = transform(p);
      strokeWeight(max(0, lineWidth/pt.z));
      circle(pt.x, pt.y, pointSize/pt.z);
    }
  }

  /** Draws the given edge */
  public void drawEdge(Line l){
    if (colours[1] == NO_COLOUR){
      stroke(0, 0, 80);  // No black strokes
    } else {
      stroke(colours[1]);
    }
    int[] indices = l.getIndices();
    PVector[] ends = new PVector[indices.length];
    boolean exists = true;
    for (int i = 0; i < indices.length; i++){
      PVector point = points.get(indices[i]);
      exists = exists&&(point != null);
      if (exists){
        ends[i] = transform(points.get(indices[i]));
      }
    }
    if (exists){
      drawLine(ends[0], ends[1], 9);
    }
  }

  /** Draws a line between two given points */
  private void drawLine(PVector p1, PVector p2, int depth){
    float zAverage = (p1.z+p2.z)/2;
    float strokeWeight = max(0, lineWidth/zAverage);
    float distance = pow(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2), 0.5);
    // Split the line to better represent the depth of the line in the 3-dimensional space 
    if ((strokeWeight < distance)||(depth <= 0)){
      strokeWeight(strokeWeight);
      line(p1.x, p1.y, p2.x, p2.y);
    } else {
      PVector pMid = midpoint(p1, p2);
      drawLine(p1, pMid, depth-1);
      drawLine(pMid, p2, depth-1);
    }
  }

  /** Returns the midpoint of two PVectors */
  public PVector midpoint(PVector p1, PVector p2){
    PVector returnPoint = p1.copy();
    returnPoint.add(p2);
    returnPoint.div(2);
    return returnPoint;
  }

  /** Returns the average position of an ArrayList of PVectors */
  public PVector midpoint(ArrayList<PVector> ps){
    if (ps.size() == 0) {
      return null;
    }
    PVector returnPoint = ps.get(0).copy();
    for (int i = 1; i < ps.size(); i++){
      returnPoint.add(ps.get(i));
    }
    returnPoint.div(ps.size());
    return returnPoint;
  }

  /** Draws the given list of faces, with lines and corners drawn if needed */
  public void drawFaces(ArrayList<Face> faces, boolean drawCorners, boolean drawEdges){
    for (Face f : faces){
      ArrayList<Integer> indices = f.getIndices();
      boolean exists = true;
      for (int i : indices){
        exists = exists&&(points.get(i) != null);
      }  // Only draw face if all the squares exist
      if (exists) {
        ArrayList<PVector> corners = new ArrayList<PVector>();
        for (int i : indices){
          corners.add(points.get(i));
        }

        // Draw the polygon that makes up the face
        noStroke();
        fill(f.getColour());
        beginShape();
        for (int i : indices){
          PVector point = transform(points.get(i));
          vertex(point.x, point.y);
        }
        endShape(CLOSE);

        // Draws the corner circles
        if (drawCorners){
          if ((colours[1] != NO_COLOUR)&&drawEdges){
            stroke(colours[1]);  // No black strokes
          } else {
            noStroke();
          }
          drawCorners(corners);
        }

        // Draws short lines over the corners to make sure the edges are still visible
        if (drawEdges&&drawCorners){
          for (int i : indices){
            Set<Integer> adjacents = links.get(i);
            PVector point = transform(points.get(i));
            for (int j : adjacents){
              PVector pAdj = transform(points.get(j));
              float displacement = pointSize/point.z/2;
              pAdj.sub(point);
              pAdj.normalize();
              pAdj.mult(displacement);
              pAdj.add(point);
              drawLine(point, pAdj, 6);
            }
          }
        }

        // Draws the lines are over the edges of the faces
        if (drawEdges) {
          for (Line l : f.getLines()) {
            drawEdge(l);
          }
        }
      }
    }
  }

  /** Transforms a PVector position to where it'll be drawn in the window */
  public PVector transform(PVector p){
    float x = p.x, y = p.y, z = p.z;
    z /= 5;  // Prevents a fish-eye lens effect
    z += drawPoint.z;
    z /= UNIVERSAL_CONSTANT;
    x /= z;
    y /= z;
    x += drawPoint.x;
    y += drawPoint.y;
    return new PVector(x, y, z);
  }
}
