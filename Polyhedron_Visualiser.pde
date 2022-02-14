Polyhedron cube;
float radius = 1;  // At this point, radius is an arbitrary constant
int slowdown = 2, step = 0;

void setup(){
  size(600, 600);
  fill(200, 200, 200);
  stroke(55, 55, 200);
  background(0);
  cube = new Polyhedron(new PVector(width/2, height/2, 2*radius), 20, 3);
  
  float[] coords = {-radius, -radius, -radius};
  for (int n = 0; n < 8; n++){
    cube.add(new PVector(coords[0], coords[1], coords[2]));
    coords[0] *= -1;
    boolean increment = true;
    for (int i = 1; i < coords.length; i++){
      increment = increment&&(coords[i-1] < 0);
      if (increment){
        coords[i] *= -1;
      }
    }
  }
  
  cube.createNearestEdges();
  //cube.createEdges(radius*2*sqrt(2));
}

void draw(){
  clear();
  cube.draw(true, true);
  float angle = ((float)step)*PI/180/slowdown;
  cube.rotateVertically(cos(angle));
  cube.rotateClockwise(sin(angle));
  
  step++;
  step = step%(slowdown*360);
}
