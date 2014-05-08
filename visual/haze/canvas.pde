float d;
float red;
float green;
float blue;
float factor=0.2;
float x, y;

float x_noise=random(20), y_noise=random(20);
float rad_noise=random(20);
float red_offset_noise=random(20);
float green_offset_noise=random(20);
float factor_noise=random(20);

int red_offset=5;
int green_offset=4;
float rad=1;


void draw_glich(PGraphics pg, int mode) {
  x_noise += 0.01;
  y_noise += 0.01;
  rad_noise += 0.01;
  red_offset_noise += 0.01;
  green_offset_noise += 0.01;
  factor_noise += 0.02;

 
  float x_noise_tmp = noise(x_noise);
  
  if(mode==0) {
    x = map(x_noise_tmp, 0, 1, 0, pg.width);
  } else {
    if(x_noise_tmp <=0.5) {
      x = map(x_noise_tmp, 0, 0.5, 0, 0.1*pg.width);
    } else {
      x = map(x_noise_tmp, 0.5, 1, 0.9*pg.width, pg.width);
    }
  }
  println(x);
  y = map(noise(y_noise), 0, 1, 0, pg.height);

  rad = map(noise(rad_noise), 0, 1, 0.1, 2.0);
  red_offset = int(map(noise(red_offset_noise), 0, 1, 3,7));
  green_offset = int(map(noise(red_offset_noise), 0, 1, 1,6));
  factor = map(noise(factor_noise), 0, 1, 0.1, 0.6);
  
  pg.loadPixels();
  //loop to go through every pixel, i=y value, j=x value
  for(int i=0;i<pg.height;i++){
    for(int j=0;j<pg.width;j++){
      
        
        //grabs pixel's current color
        color c = pg.pixels[i*pg.width+j];
        
        //the actual glitch! <<number and & 0xff mess 
        //with the binary code and completely destroy the colors
        //very fun to mess around with. dont be afraid to tweak!        
        red = c << red_offset & 0xff;
        green = c << green_offset & 0xaa;
        blue = c & 0xff;
        
        //gets distance from mouse to pixel
        //the *.4 at the end changes the "saving" area of effect:
        //when the mouse is at rest and the colors dont change.
        //higher value = smaller area
        d =dist(x,y,j,i)*factor;
       
        //make the colors change depending on distance to mouse       
        //rad = radius of the innermost circle
        red += 50/d-rad;
        green += 50/d-rad;
        blue += 50/d-rad;
          
        //changes the pixel to the glitched pixel
        pg.pixels[i*pg.width+j]=color(red,green,blue);
       
    }
  }  
  pg.updatePixels();
}

