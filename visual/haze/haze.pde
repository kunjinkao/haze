//import mpe.client.*;
import java.util.HashMap; 
import java.util.Map;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;

//TCPClient client;
//PShader bgShader;
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
//SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");
Calendar currentDate = Calendar.getInstance();
Map<String, Integer> loc_map = new HashMap<String, Integer>();
Map<String, Gas> gases = new HashMap<String, Gas>();
Map<String, Map<String, Map<String, Integer>>> loc_data = new HashMap<String, Map<String, Map<String, Integer>>>();

void setup() {
  loadData();

  frameRate(30);
  
  oscP5 = new OscP5(this,12000);
  oscP5.plug(this, "newDate","/date"); 
  
  currentDate.set(2011, 0, 0);

  currentDate.add(Calendar.DATE, 1);

  println(currentDate);

//  println(loc_data.get("xian").get("2013-1-1"));
  
  // make a new Client using an XML file
//  client = new TCPClient(this, "mpe.xml");

  // the size is determined by the client's local width and height
//  size(client.getLWidth(), client.getLHeight());
  size(1200, 600);

  for (String loc_name : loc_map.keySet()) {
    int dis = loc_map.get(loc_name);
    Gas gas = new Gas(dis);
    gases.put(loc_name, gas);  
  }
  
  // the random seed must be identical for all clients
//  randomSeed(1);


//  bgShader = loadShader("003.glsl");

//  bgShader.set("resolution", float(width), float(height));
  // Starting the client
//  client.start();
  background(0);
}

// Reset it called when the sketch needs to start over
//void resetEvent(TCPClient c) {
  // the random seed must be identical for all clients
//  randomSeed(1);
//  balls = new ArrayList<Ball>();
//  for (int i = 0; i < 5; i++) {
//    Ball ball = new Ball(random(client.getMWidth()), random(client.getMHeight()));
//    balls.add(ball);
//  }
//}

//--------------------------------------
// Keep the motor running... draw() needs to be added in auto mode, even if
// it is empty to keep things rolling.
void draw() {
  
//  String dateStr = calendaer_to_date(currentDate);
//  if(frameCount % 180 == 0) {
//    currentDate.add(Calendar.DATE, 1);    
//  }
//  println(dateStr);

  for (String loc_name : loc_map.keySet()) {
    Gas gas = gases.get(loc_name);
//    gas.setData(loc_data.get(loc_name).get(dateStr));
    gas.update();
    gas.render();
  }

  
//  shader(bgShader); 
//  bgShader.set("mouse", float(mouseX), float(mouseY));  
//  bgShader.set("time", frameCount);
//  shader(bgShader);


//  fill(255);
  
}

//--------------------------------------
// Triggered by the client whenever a new frame should be rendered.
// All synchronized drawing should be done here when in auto mode.
//void frameEvent(TCPClient c) {
//  // clear the screen     
//  background(255);
//  
//  // move and draw all the balls
//  for (Ball b : balls) {
//    b.calc();
//    b.draw();
//  }
//
//  // read any incoming messages
//  if (c.messageAvailable()) {
//    String[] msg = c.getDataMessage();
//    String[] xy = msg[0].split(",");
//    float x = Integer.parseInt(xy[0]);
//    float y = Integer.parseInt(xy[1]);
//    balls.add(new Ball(x, y));
//  }
//}

//--------------------------------------
// Adds a Ball to the stage at the position of the mouse click.
void mousePressed() {
  // never include a ":" when broadcasting your message
//  int x = mouseX + client.getXoffset();
//  int y = mouseY + client.getYoffset();
//  client.broadcast(x + "," + y);

 int x = mouseX;
 int y = mouseY;
// balls.add(new Ball(x, y));
}

String calendaer_to_date(Calendar c){
  int y = c.get(Calendar.YEAR);  
  int m = c.get(Calendar.MONTH) + 1;
  int d = c.get(Calendar.DAY_OF_MONTH) + 1;
  return y + "-" + m + "-" + d;
}

public void newDate(String dateStr) {  
  for (String loc_name : loc_map.keySet()) {
    Gas gas = gases.get(loc_name);
    gas.setData(loc_data.get(loc_name).get(dateStr));
  }
}

void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.isPlugged()==false) { // not bind to a responder
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }
}

void loadData() {
  String path = "/Users/sean/Desktop/haze/data/";

  loc_map.put("xian", 0);
  loc_map.put("caotan", 4);
  loc_map.put("gaoya", 5);
  loc_map.put("qujiang", 4);
  loc_map.put("xingqing", 1);
  loc_map.put("changan", 9);
  loc_map.put("guangyuntan", 4);
  loc_map.put("tiyuchang", 1);
  loc_map.put("yanliang", 4);
  loc_map.put("fangzhicheng", 7);
  loc_map.put("jingkai", 6);
  loc_map.put("gaoxin", 6);
  loc_map.put("lintong", 4);
  
  SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
  
  for (String loc_name : loc_map.keySet()) {
    String filepath = path + loc_name + ".json";
    JSONArray gas_data_list = loadJSONArray(filepath);

    Map<String, Map<String, Integer>> this_loc_data = new HashMap<String, Map<String, Integer>>();

    for(int i = 0; i < gas_data_list.size(); i++) {
      
      JSONObject gas_data = gas_data_list.getJSONObject(i);
      String date_str;
      Date date; 
      Integer pm10, pm25, so2, no2, co;
      date_str = gas_data.getString("时间").trim();
      
      try {
        date = formatter.parse(date_str);
      } catch (Exception e) {
        date = null;
      }


      
      try {
        pm10 = gas_data.getInt("PM10");
      } catch (Exception e) {
        pm10 = 0;
      }
      
      try {
        pm25 = gas_data.getInt("PM2.5");
      } catch (Exception e) {
        pm25 = 0;
      }

      try {
        so2 = gas_data.getInt("SO2");
      } catch (Exception e) {
        so2 = 0;
      }

      try {
        no2 = gas_data.getInt("NO2");
      } catch (Exception e) {
        no2 = 0;
      }


      try {
        co = gas_data.getInt("CO");
      } catch (Exception e) {
        co = 0;
      }

    
      String rate_var = gas_data.getString("首要污染物");
      Integer rate;
      if(rate_var == "优"){
        rate = 1;
      } else if (rate_var.equals( "良")) {
        rate = 2;
      } else if (rate_var.equals("轻度")|| rate_var.equals("轻微污")){
        rate = 3;
      } else if (rate_var.equals( "中度") || rate_var.equals("严重")){
        rate = 4;
      } else if (rate_var.equals("重度") || rate_var.equals("严重")){
        rate = 5;
      } else {
        rate = 0;
      }
       
      Map<String, Integer> num_data = new HashMap<String, Integer>();

      num_data.put("pm25", pm25);
      num_data.put("pm10", pm10);
      num_data.put("so2", so2);
      num_data.put("no2", no2);      
      num_data.put("co", co);
      num_data.put("rate", rate);     
      this_loc_data.put(date_str, num_data);
      
    }

    loc_data.put(loc_name, this_loc_data);
  } 
}
