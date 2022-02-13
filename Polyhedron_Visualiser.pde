Polyhedron cube;
float radius = 200;
int step = 0;

void setup(){
  size(960, 600);
  fill(200, 200, 200);
  //noStroke();
  stroke(55, 55, 200);
  strokeWeight(5);
  background(0);
  cube = new Polyhedron(10, new PVector(width/2, height/2, 500));
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
}

void draw(){
  clear();
  cube.draw();
  if (step < 90){
    cube.rotateHorizontally(1);
  } else if (step < 225){
    cube.rotateVertically(1);
  } else {
    cube.rotateClockwise(1);
  }
  step++;
  step = step%360;
}
