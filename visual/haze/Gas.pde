void drawPoint(float x, float y, float noiseFactor, float... controls) {

  pushMatrix();
  translate(x,y);
  rotate(noiseFactor*radians(540));
  noStroke();
  float edgeSize = noiseFactor*30;
  float grey = 80 + (noiseFactor*170);
  float alpha = 80 + (noiseFactor*170);
  float depth = map(noiseFactor, 0.0, 1.0, -0.5, 1);

  float shape_control = map(controls[0], 0.0, 1.0, 1.5, 2.5);
  int line_control = int(map(controls[1], 0.0, 1.0, 0, 30));
  int line_alpha = int(map(controls[2], 0.0, 1.0, 0, 150)); 
  
  fill(grey, alpha);   
  translate(0, 0, depth);
  ellipse(0, 0, edgeSize, edgeSize/shape_control);

  if(line_control != 0 ) {
    rotate(noiseFactor*radians(360));
    stroke(0, line_alpha);
    line(0,0,20,0);
  }
   
  popMatrix();
}


float smooth_val(float src, float dest) {
  if(abs(src-dest) <= 1) {
    return dest;
  } else if(dest > src) {
    return src + 1;
  } else if(dest < src) {
    return src - 1;
  } else {
    return dest;
  }
}

float smooth_val_small(float src, float dest) {
  if(abs(src-dest) <= 0.005) {
    return dest;
  } else if(dest > src) {
    return src + 0.005;
  } else if(dest < src) {
    return src - 0.005;
  } else {
    return dest;
  }
}

class Gas {
  //--------------------------------------
  int pm25 = 0;
  int pm10 = 0;
  int so2 = 0;
  int no2 = 0;
  int co = 0;
  int rate = 0;
  int distance = 0;
  int sum_so2 = 0;
  
  int delay = 10;

  float left_bound=0.0, right_bound=0.0;
  float left_bound_next=0, right_bound_next=0;  

  float step1 = 0.01; // the step value calculate the noise
  float step2 = 0.1; // the step value calculate the noise
  int detail = 5; // pixal detail of the noise
  float xstart, ystart;
  float xNoise, yNoise, xsNoise,ysNoise;
  
  float offset_x=0, offset_x_next=0;
  float offset_y=0, offset_y_next=0;
  float gas_width = 0;
  float gas_height = height;  

  float line_control = 0;
  
  float gas_scale = 1;
  float gas_scale_next = 1;
  //--------------------------------------
  public Gas(int _distance) {
    distance = _distance;
    gas_width = 0;
    xstart = random(20);
    ystart = random(20);
    xsNoise = float(20);
    ysNoise = float(20);
  }

  public void setData(Map<String, Integer> num_data) {
    if (num_data == null) {
    } else {
      pm25 = num_data.get("pm25");
      pm10 = num_data.get("pm10");
      so2 = num_data.get("so2");
      no2 = num_data.get("no2");
      co = num_data.get("co");
      rate = num_data.get("rate");
      
      step1 = map(so2, 0, 200, -0.005, 0.2);
      step2 = map(no2, 0, 100, 0.05, 0.2);

      detail = int(map(rate, 0.0, 5.0, 6.0, 3.0));
      line_control = map(pm25, 0, 500, 0, 1);

    }
    
//    offset_x_next = map(distance, 0, 9, 100, width-100) + map(so2, 0, 100, -25, 25);

  }

  public void setBound(float _left, float _right) {
    left_bound_next = _left;
    right_bound_next = _right;
  }
  
 public void setTrigData(float vx, float vy, float locx, float locy){
     line_control = locy;    
     gas_scale_next = map(abs(vy), 0, 10, 1, 1.5);
     this.setBound(locx, locx + map(vx, 0, 15, 0.1, 0.3));
  }

  public void update() {
     left_bound += (left_bound_next- left_bound)/delay;
     right_bound += (right_bound_next- right_bound)/delay;
     gas_scale += (gas_scale_next - gas_scale)/(delay * 3);
//    offset_y = smooth_val(offset_y, offset_y_next);
//    offset_x = smooth_val(offset_x, offset_x_next);
//    gas_width = smooth_val(gas_width, gas_width_next);
//    gas_height = smooth_val(gas_height, gas_height_next);
  }

  //--------------------------------------
  public void render() {
    println(left_bound, right_bound);
    pushMatrix();

    translate(offset_x, height/2);

    xsNoise += step1;    
    ysNoise += step2;
    xstart += (noise(xsNoise)*0.5)-0.25;
    ystart += (noise(ysNoise)*0.5)-0.25;
    xNoise = xstart;
    yNoise = ystart;
    
    float shape_control = map(no2, 0, 100, 0, 1);
    float line_control = map(pm25, 0, 500, 0, 1);
    float line_alpha = map(pm10, 0, 350, 0, 1);    
    float[] extras = {shape_control, line_control, line_alpha};
    
    
    for (int y=-int(gas_height)/2; y <= int(gas_height)/2; y+=detail) {
      yNoise += step2;
      xNoise = xstart;
      for (int x=int(left_bound*width) ; x<=int(right_bound*width); x+=detail) {
        xNoise += step2;
        drawPoint(x, y, noise(xNoise,yNoise), extras);
      }
    }
    popMatrix();
  }
  
}


