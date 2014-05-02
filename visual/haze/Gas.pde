void drawPoint(float x, float y, float noiseFactor) {

  pushMatrix();
  translate(x,y);
  rotate(noiseFactor*radians(540));
  noStroke();
  float edgeSize = noiseFactor*30;
  float grey = 80 + (noiseFactor*170);
  float alpha = 80 + (noiseFactor*170);  
  fill(grey, alpha);
  ellipse(0, 0, edgeSize, edgeSize/2);
 
//  rotate(noiseFactor*radians(360));
//  stroke(0,150);
//  line(0,0,20,0);

  popMatrix();
}


float smooth_val(float src, float dest) {
  if(abs(src-dest) <= 0.5) {
    return dest;
  } else if(dest > src) {
    return src + 0.5;
  } else if(dest < src) {
    return src - 0.5;
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

  float step1 = 0.01; // the step value calculate the noise
  float step2 = 0.1; // the step value calculate the noise
  int detail = 5; // pixal detail of the noise
  float xstart, ystart;
  float xNoise, yNoise, xsNoise,ysNoise;
  
  float offset_x=0, offset_x_next=0;
  float offset_y=0, offset_y_next=0;
  float gas_width = 5, gas_width_next=5;
  float gas_height = 10, gas_height_next=10;  

  //--------------------------------------
  public Gas(int _distance) {
    distance = _distance;
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
    }
    
    offset_x_next = map(distance, 0, 9, 50, width-50) + map(so2, 0, 100, -100, 100);

    gas_width_next = map(pm10, 0, 350, 15, width/4);
    gas_height_next = map(no2, 0, 100, 15, height);

    step1 = map(so2, 0, 200, 0.005, 0.02);
    step2 = map(no2, 0, 100, 0.05, 0.2);

    detail = int(map(rate, 0.0, 5.0, 6.0, 3.0));
  }

  public void update() {
//    offset_y = smooth_val(offset_y, offset_y_next);
    offset_x = smooth_val(offset_x, offset_x_next);
    gas_width = smooth_val(gas_width, gas_width_next);
    gas_height = smooth_val(gas_height, gas_height_next);
  }

  //--------------------------------------
  public void render() {
    pushMatrix();

    translate(offset_x, height - 20);

    xsNoise += step1;    
    ysNoise += step1;
    xstart += (noise(xsNoise)*0.5)-0.25;
    ystart += (noise(ysNoise)*0.5)-0.25;
    xNoise = xstart;
    yNoise = ystart;

    for (int y=-int(gas_height); y <= 0; y+=detail) {
      yNoise += step2;
      xNoise = xstart;
      for (int x=-int(gas_width)/2; x<= int(gas_width)/2; x+=detail) {
        xNoise += step2;
        drawPoint(x, y, noise(xNoise,yNoise));
      }
    }
    popMatrix();
  }
  
}


