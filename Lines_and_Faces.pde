public class Face implements Comparable<Face> {
  color colour;
  ArrayList<Integer> indices;

  /** Initialise the Face object */
  public Face(ArrayList<Integer> listOfIndices){
    colorMode(RGB);
    colour = color(200, 200, 200);
    indices = new ArrayList<Integer>();

    // Remove final index if it it equal to the first index
    ArrayList<Integer> inds = new ArrayList<Integer>(listOfIndices);
    if (inds.get(0) == inds.get(inds.size()-1)){
      inds.remove(inds.size()-1);
    }

    // Rotate 'inds' to start with the lowest index
    int iMin = Integer.MAX_VALUE, nMin = 0;
    for (int n = 0; n < inds.size(); n++){
      int i = inds.get(n);
      if (iMin > i) {
        iMin = i;
        nMin = n;
      }
    }
    for (int n0 = 0; n0 < inds.size(); n0++){
      int n = n0+nMin;
      n = n%inds.size();
      indices.add(inds.get(n));
    }

    // Flip 'indices' so that the second index is smaller than the last index
    if ((indices.size() > 2)&&(indices.get(1) > indices.get(indices.size()-1))){
      for (int n = 1; n < indices.size()/2; n++){
        Collections.swap(indices, n, indices.size()-n);
      }
    }
  }
  
  /** Set the colour of this face */
  public void setColor(color c){
    colour = c;
  }
  public void setColour(color c){
    colour = c;
  }

  /** Return the colour of this face */
  public color getColour(){
    return colour;
  }
  public color getColor(){
    return colour;
  }

  /** Returns the ordered list of indices that create the vertices of the face */
  public ArrayList<Integer> getIndices(){
    return new ArrayList<Integer>(indices);
  }

  /** Returns the ordered list of lines that create the edges of the face */
  public ArrayList<Line> getLines(){
    ArrayList<Line> returnList = new ArrayList<Line>();
    for (int i = 0; i < indices.size(); i++){
      int j = (i+1)%indices.size();
      returnList.add(new Line(indices.get(i), indices.get(j)));
    }
    return returnList;
  }

  /** This version of compareTo is used to find which face is further back, so it can be drawn first */
  public int compareTo(Face other, Map<Integer, PVector> points){
    int sum = 0;
    for (int i : getIndices()){
      PVector p1 = points.get(i);
      for (int j : other.getIndices()){
        PVector p2 = points.get(j);
        if (p1.z < p2.z){
          sum++;
        }
        if (p1.z > p2.z){
          sum--;
        }
      }
    }
    return sum;
  }

  /** This version of compareTo is simply used to compare the two faces to differenciate them from each other */
  public int compareTo(Face other){
    int sum = 0;
    for (int i : getIndices()){
      for (int j : other.getIndices()){
        if (i > j){
          sum++;
        }
        if (i < j){
          sum--;
        }
      }
    }
    if (sum != 0){
      sum /= abs(sum);
    }
    return sum;
  }

  /** To see whether the two faces have an identical set of indices */
  public boolean equals(Face other){
    ArrayList<Integer> otherIndices = other.getIndices();
    if (indices.size() != otherIndices.size()){
      return false;
    }
    for (int n = 0; n < indices.size(); n++){
      if (indices.get(n) != otherIndices.get(n)){
        return false;
      }
    }
    return true;
  }
}


public class Line implements Comparable<Line>{
  int[] indices;

  /** Initialise the Line object */
  public Line(int iA, int iB) {
    int[] ii = {min(iA, iB), max(iA, iB)};
    indices = ii;
  }

  /** Returns the pair of indices */
  public int[] getIndices(){
    return indices;
  }

  /** Returns the an int if the other int is given, otherwise it returns Integer.MIN_VALUE */
  public int getOtherEnd(int i) {
    for (int n = 0; n < indices.length; n++){
      if (i == indices[n]) {
        return indices[indices.length-1-n];
      }
    }
    return Integer.MIN_VALUE;
  }

  /** This version of compareTo is used to find which line is further back, so it can be drawn first */
  public int compareTo(Line other, Map<Integer, PVector> points){
    int sum = 0;
    for (int i : getIndices()){
      PVector p1 = points.get(i);
      for (int j : other.getIndices()){
        PVector p2 = points.get(j);
        if (p1.z < p2.z){
          sum++;
        }
        if (p1.z > p2.z){
          sum--;
        }
      }
    }
    return sum;
  }

  /** This version of compareTo is simply used to compare the two lines to differenciate them from each other */
  public int compareTo(Line other){
    int sum = 0;
    for (int i : getIndices()){
      for (int j : other.getIndices()){
        if (i > j){
          sum++;
        }
        if (i < j){
          sum--;
        }
      }
    }
    return sum;
  }

  /** To see whether the two lines have an identical pair of indices */
  public boolean equals(Line other){
    int[] otherIndices = other.getIndices();
    for (int n = 0; n < indices.length; n++){
      if (otherIndices[n] != indices[n]){
        return false;
      }
    }
    return true;
  }
}
