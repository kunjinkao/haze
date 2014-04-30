class Gas {
  //--------------------------------------
  
  int pm25 = 0;
  int pm10 = 0;
  int so2 = 0;
  int no2 = 0;
  int co = 0;
  int rate = 0;
  int distance = 0;

  float x,y;
  float w,h;
  float c;
  float alpha;
  //--------------------------------------
  public Gas(int _distance) {
    distance = _distance;
  }

  public void setData(Map<String, Integer> num_data) {
    if (num_data == null) {
    } else {
      pm25 = num_data.get("pm25");
      pm10 = num_data.get("pm25");
      so2 = num_data.get("so2");
      no2 = num_data.get("no2");
      co = num_data.get("co");
      rate = num_data.get("rate");
    }
  }

  public void calc() {
    y = map(distance, 0, 10, 100, height-100) + random(-20, 20);
    x = map(no2, 0, 80, 100, width - 100) + random(-10, 10);    
    w = map(so2, 0, 100, 10, width/3);
    h = map(rate, 0, 5, 40, 30);
    c = map(pm25, 0, 200, 20, 255);
    alpha = map(pm10, 0, 200, 20, 255);
  }

  //--------------------------------------
  public void render() {
    rectMode(CENTER);
    pushMatrix(); 
    rect(x, y, w, h);
    popMatrix();
  }
  
}

