
int w = 300;
int h = 200;
int userId = 0;
Mover mover;

void setup() {
  size(w, h);
  mover = new Mover();
  frameRate(10);
  X = width / 2;
  Y = width / 2;
}
       
void draw() {
   background( 0 ); 

   mover.update();
   mover.checkEdges();
   mover.display(); 
   
}


void addForce(float _x, float _y){
  PVector loc = new PVector(_x, _y);
  loc.sub(mover.location)
  loc.normalize();
  loc.mult(10)
  mover.applyForce(loc);
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
    location = new PVector(2/width, 2/height);
    velocity = new PVector(random(1), random(1));
    acceleration = new PVector(0,0);
    mass = 1;
    topspeed = 15;
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


