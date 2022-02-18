Polyhedron shape;
int slowdown = 2, step = 0;
float SCALE = 2;
color pointColour, lineColour;

// Initialise frame, and create shape
void setup(){
  size(480, 480);
  colorMode(HSB, 360, 100, 100);

  pointColour = color(0, 0, 80);
  lineColour = color(240, 0, 40);
  // Change to a different function to get a different shape
  shape = createRhombicuboctahedron();
}

void draw(){
  // Rotate shape
  float angle = ((float)step)*PI/180/slowdown;
  shape.rotateHorizontally(cos(angle));
  shape.rotateVertically(sin(angle));
  step++;
  step = step%(slowdown*360);
  
  // Display shape
  clear();
  shape.draw(true, true, true);
}


/** An assortment of functions to make shapes */

/** Tetrahedron */
Polyhedron createTetrahedron(){
  float radius = SCALE;
  Polyhedron tetra = new Polyhedron(new PVector(width/2, height/2, 2), 15, 2.5*SCALE);
  tetra.setPointColour(pointColour);
  tetra.setLineColour(lineColour);
  float[] coords = {-radius, -radius, -radius};
  for (int n = 0; n < pow(2, coords.length); n++){
    if (coords[0]*coords[1]*coords[2]>0){
      tetra.add(new PVector(coords[0], coords[1], coords[2]));
    }
    increment(coords);
  }
  tetra.createLinkingEdges();
  tetra.createFaces(3, false);
  return tetra;
}

/** Cube */
Polyhedron createCube(){
  float radius = SCALE;
  Polyhedron cube = new Polyhedron(new PVector(width/2, height/2, 2), 15*SCALE, 2.5*SCALE);
  cube.setPointColour(pointColour);
  cube.setLineColour(lineColour);
  float[] coords = {-radius, -radius, -radius};
  for (int n = 0; n < pow(2, coords.length); n++){
    cube.add(new PVector(coords[0], coords[1], coords[2]));
    increment(coords);
  }
  cube.createLinkingEdges();
  cube.createLinkingFaces();
  return cube;
}

/** Truncated Cube */
Polyhedron createTruncatedCube(){
  float radius = SCALE;
  Polyhedron cube = new Polyhedron(new PVector(width/2, height/2, 2), 9*SCALE, 2*SCALE);
  cube.setPointColour(pointColour);
  cube.setLineColour(lineColour);
  float[] coords = {-radius, -radius, -radius};
  for (int n = 0; n < pow(2, coords.length); n++){
    for (int j = 0; j < coords.length; j++){
      coords[j] *= 1-sqrt(2);
      cube.add(new PVector(coords[0], coords[1], coords[2]));
      coords[j] /= 1-sqrt(2);
    }
    increment(coords);
  }
  cube.createLinkingEdges();
  cube.createLinkingFaces();
  return cube;
}

/** Cuboctahedron (combination of octahedron and cube),
  * or RectifiedCube (a form of truncated cube) */
Polyhedron createRectifiedCube(){  // Also known as a Cuboctahedron
  float radius = SCALE;
  Polyhedron cube = new Polyhedron(new PVector(width/2, height/2, 2), 12*SCALE, 2*SCALE);
  cube.setPointColour(pointColour);
  cube.setLineColour(lineColour);
  float[] coords = {-radius, -radius, -radius};
  for (int n = 0; n < pow(2, coords.length); n++){
    for (int j = 0; j < coords.length; j++){
      float target = coords[j];
      coords[j] = 0.001*radius;  // Can't be exactly zero, else it will give an unintended result
      if (target >= 0) cube.add(new PVector(coords[0], coords[1], coords[2]));
      coords[j] = target;
    }
    increment(coords);
  }
  cube.createLinkingEdges();
  cube.createFaces(4, true);
  return cube;
}

/** Octahedron */
Polyhedron createOctahedron(){
  float radius = SCALE*1.5;
  Polyhedron octa = new Polyhedron(new PVector(width/2, height/2, 2), 15*SCALE, 2.5*SCALE);
  octa.setPointColour(pointColour);
  octa.setLineColour(lineColour);
  float shift = 1;
  float[] coords = {radius, radius, radius};
  for (int n = 0; n < coords.length; n++){
    for (int s = 0; s <= 2; s+=2){
      coords[n] = s*radius;
      octa.add(new PVector(coords[0]+shift, coords[1]+shift, coords[2]+shift));
    }
    coords[n] = radius;
  }
  octa.createLinkingEdges();
  octa.createFaces(3, false);
  
  PVector translate = new PVector(coords[0]+shift, coords[1]+shift, coords[2]+shift);
  translate.mult(-1);
  octa.translate(translate);
  
  return octa;
}

/** Rhombicuboctahedron (combination of octahedron and cube, also known as an expanded or cantellated cube) */
Polyhedron createRhombicuboctahedron(){
  float radius = 0.6*SCALE;
  Polyhedron rhombi = new Polyhedron(new PVector(width/2, height/2, 2), 9*SCALE, 2*SCALE);
  rhombi.setPointColour(pointColour);
  rhombi.setLineColour(lineColour);
  float[] coords = {-radius, -radius, -radius};
  for (int n = 0; n < pow(2, coords.length); n++){
    for (int j = 0; j < coords.length; j++){
      coords[j] /= 1-sqrt(2);
      rhombi.add(new PVector(coords[0], coords[1], coords[2]));
      coords[j] *= 1-sqrt(2);
    }
    increment(coords);
  }
  rhombi.createLinkingEdges();
  rhombi.createLinkingFaces();
  return rhombi;
}

/** Takes an array of coordiates, and alters it in a way that returns to its original state
  * after (coords.length)^2 iterations */
float[] increment(float[] coords){
  coords[0] *= -1;
  boolean increment = true;
  for (int i = 1; i < coords.length; i++){
    increment = increment&&(coords[i-1] < 0);
    if (increment){
      coords[i] *= -1;
    } else {
      break;
    }
  }
  return coords;
}
