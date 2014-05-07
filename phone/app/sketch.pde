float xstart,ystart,xNoise,yNoise,xsNoise,ysNoise;

int w = 200;
int h = 100;
float step1 = 0.01;
float step2 = 0.1;
int userId = 0;

float color_noise;
void setup() {
  size(w,h);
  background(0);
  // smooth();
  frameRate(1);
  xstart = random(20);
  ystart = random(20);
  xsNoise = random(20);
  ysNoise = random(20);
}
       
void draw() {
  background(0);

  xsNoise+=step1;
  ysNoise+=step1;
  xstart+=(noise(xsNoise)*0.5)-0.25;
  ystart+=(noise(ysNoise)*0.5)-0.25;
  xNoise=xstart;
  yNoise=ystart;

  float shape = (userId + 2)/2;

  for (int y=0; y <= height; y+=5) {
    yNoise += step2;
    xNoise = xstart;
    for (int x=0; x <= width; x+=5) {
      xNoise += step2;
      drawPoint(x,y,noise(xNoise,yNoise), shape);
    }
  }

}

void setUserId(int _id){
  userId = _id;
}
 
void setControl(float slider, float alpha, float beta){
  // map(slider, 0 , 100, )
  step1 = map(alpha, 0, 180, 0.01, 0.05);
  step2 = map(beta, -90, 90, 0.02, 0.5);
}

void drawPoint(float x, float y, float noiseFactor, float shape) {
  pushMatrix();

  translate(x,y);
  rotate(noiseFactor*radians(540));
  noStroke();
  float edgeSize = noiseFactor*45;
  float grey = 80 + (noiseFactor*170);
  float alpha = 80 + (noiseFactor*170);
  fill(grey, alpha);

  ellipse(0,0,edgeSize, edgeSize/shape);
 // rotate(noiseFactor*radians(360));
 // stroke(0,150);
 // line(0,0,20,0);
  popMatrix();
}