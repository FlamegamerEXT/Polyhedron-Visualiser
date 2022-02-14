public class Line {
  int index1, index2;
  
  public Line(int iA, int iB){
    index1 = min(iA, iB);
    index2 = max(iA, iB);
  }
  
  public int[] getIndices(){
    int[] indices = {index1, index2};
    return indices;
  }
  
  public int compareTo(Line other, Map<Integer, PVector> points){
    int sum = 0;
    for (int i : getIndices()){
      PVector p1 = points.get(i);
      for (int j : other.getIndices()){
        PVector p2 = points.get(j);
        if (p1.z < p2.z){ sum++; }
        if (p1.z > p2.z){ sum--; }
      }
    }
    return sum;
  }
}
