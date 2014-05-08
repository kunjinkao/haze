
int w = 300;
int h = 200;
int userId = 0;
Mover mover;

void setup() {
  size(w, h);
  mover = new Mover();
  frameRate(10);
  X = width / 2;
  Y = height / 2;
}
       
void draw() {
   background( 0 ); 

   mover.update();
   mover.checkEdges();
   mover.display(); 

}


public void addForce(float _x, float _y){
  PVector loc = new PVector(_x, _y);
  loc.sub(mover.location)
  loc.normalize();
  loc.mult(5);
  mover.applyForce(loc);
  background(255);
}

public void reverse(){
  mover.velocity.x *= -1;
  mover.velocity.y *= -1;
}

public float[] trig(){
  float x = map(mover.location.x, 0, width, 0, 1);
  float y = map(mover.location.y, 0, height, 0, 1);
  return new float[] {mover.velocity.x, mover.velocity.y, x, y };
}

public void rotateV(float angle){
  mover.velocity.rotate(radians(angle));
}


public void swipe(float _x, float _y){
  mover.location.x = constrain(mover.location.x + _x/2, 0, width)
  mover.location.y = constrain(mover.location.y + _y/2, 0, width)  
}

void setV(float _vx, float _vy){
}

void setUserId(int _id){
  userId = _id;
}

void setScale(int _scale){
  radius = constrain(radius * _scale, 5, 100);
}
 
void setControl(float slider, float alpha, float beta){
  // map(slider, 0 , 100, )
  step1 = map(alpha, 0, 180, 0.01, 0.05);
  step2 = map(beta, -90, 90, 0.02, 0.5);
}

class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  float topspeed;

  Mover() {
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    mass = 2;
    topspeed = 20;
  }
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
  }
  
  void update() {
    velocity.limit(topspeed);
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    stroke(0);
    strokeWeight(2);
    fill(255);
    ellipse(location.x, location.y,48,48);
  }

  void checkEdges() {

    if (location.x > width) {
      location.x = width;
      velocity.x *= -1;
    } else if (location.x < 0) {
      velocity.x *= -1;
      location.x = 0;
    }

    if (location.y > height) {
      velocity.y *= -1;
      location.y = height;
    } else if(location.y<0) {
      velocity.y *= -1;
      location.y = 0;      
    }

  }

}


