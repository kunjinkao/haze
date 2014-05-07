//import mpe.client.*;
import java.util.HashMap; 
import java.util.Map;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;
import java.io.File;

//TCPClient client;

PShader bgShader;
import oscP5.*;
import netP5.*;

float angle = 0;
PGraphics bgCanvas;

// for display words
PFont wenquanyi;
String[] title = {
  "PART1 - HAZE",
  "PART2 - BODY DANCE",
  "PART3 - BLIND"
};
int title_index;
String[] performers = {
  "锟斤拷",
  "杨众国 & 郭正",
  "秦岭 & XBH"
};
int performers_index;

String[] interaction_msg = {
  "1. 连接到「kunjinkao」的wifi\n2. 用浏览器打开192.168.1.102",
  "1.杨众国怎么\n2.你怎么了"
};
int interaction_msg_index = 0;

int mode;
OscP5 oscP5;
//SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");
Calendar currentDate = Calendar.getInstance();
Map<String, Integer> loc_map = new HashMap<String, Integer>();
Map<String, Gas> gases = new HashMap<String, Gas>();
Map<String, Map<String, Map<String, Integer>>> loc_data = new HashMap<String, Map<String, Map<String, Integer>>>();


void setup() {
  //load init data  
  loadData();

  frameRate(30);
  
  
  //display mode  
  mode = 1;
  
  //fonts
//  wenquanyi = loadFont("WenQuanYiZenHei-80.vlw");
  title_index = 0;
  performers_index = 0;

  //osc config
  oscP5 = new OscP5(this,12000);
  oscP5.plug(this, "newDate","/date"); 
  oscP5.plug(this, "setMode","/mode");
  oscP5.plug(this, "setText","/text");
  oscP5.plug(this, "setInteractionText","/interaction_text");

  //dates
  currentDate.set(2011, 0, 0);
  currentDate.add(Calendar.DATE, 1);
  println(currentDate);

//  println(loc_data.get("xian").get("2013-1-1"));
  
  // make a new Client using an XML file
//  client = new TCPClient(this, "mpe.xml");

  // the size is determined by the client's local width and height
  // size(client.getLWidth(), client.getLHeight());
  size(1200, 600);

  bgCanvas =  createGraphics(width, height);
  // setup gases
  int num = 0;
  for (String loc_name : loc_map.keySet()) {
    int dis = loc_map.get(loc_name);
    Gas gas = new Gas(dis);
    gases.put(loc_name, gas);  
    num += 1;
  }
  
  // the random seed must be identical for all clients
//  randomSeed(1);


//  bgShader = loadShader("whitenoise.glsl");

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
  background(0);
  
  if(mode==0) { 
    hint( ENABLE_DEPTH_TEST );
    String dateStr = calendaer_to_date(currentDate);
    if(frameCount % 30 == 0) {
      currentDate.add(Calendar.DATE, 1);    
    }
    newDate(dateStr);
    println(dateStr);
    for (String loc_name : loc_map.keySet()) {
      Gas gas = gases.get(loc_name);
      gas.update();
       
      gas.render();
    }
  } else if(mode==1) {
    hint( DISABLE_DEPTH_TEST );
    bgCanvas.beginDraw();
    draw_glich(bgCanvas, 0);
    bgCanvas.endDraw();
    
    image(bgCanvas, 0, 0);

    fill(255);
    
    textFont( wenquanyi, 100 );    
    textAlign( CENTER );
    text(title[title_index], width/2, 200);
    textFont( wenquanyi, 50 );
    text("嘉宾", width/2, 350);
    text(performers[performers_index], width/2, 450);

  } else if(mode==2) {

  hint( DISABLE_DEPTH_TEST );

    bgCanvas.beginDraw();
    draw_glich(bgCanvas, 1);
    bgCanvas.endDraw();
    
    image(bgCanvas, 0, 0);

    
    fill(255);
    textFont( wenquanyi, 100 );        
    textAlign( CENTER );
    text("互动", width/2, 200);

    textFont( wenquanyi, 50);
    text(interaction_msg[interaction_msg_index], width/2, 400);

  }

  

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
  float pm10_total = 0;
  float pm10_add = 0;
  for (String loc_name : loc_map.keySet()) {
    Gas gas = gases.get(loc_name);
    gas.setData(loc_data.get(loc_name).get(dateStr));
    pm10_total += gas.pm10;
  }

  for (String loc_name : loc_map.keySet()) {
    Gas gas = gases.get(loc_name);
    float left, right;
    left = pm10_add/pm10_total;
    pm10_add += gas.pm10;
    right = pm10_add/pm10_total;
    
    gas.setBound(left, right);
  }
  
}

public void setInteractionText(int _index) {
  interaction_msg_index = _index;
}

public void setText(int _title, int _performers) {
  title_index = _title;
  performers_index = _performers;
}

public void setMode(int _mode) {  
  mode = _mode;
}

void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.isPlugged()==false) { // not bind to a responder
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }
}

void loadData() {
  String s = sketchPath("");
  s = s.substring(0, s.lastIndexOf('/'));
  s = s.substring(0, s.lastIndexOf('/'));
  String path = s.substring(0, s.lastIndexOf('/')) + "/data/";


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
