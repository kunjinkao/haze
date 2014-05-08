import mpe.client.*;
import java.util.HashMap; 
import java.util.Map;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;
import java.io.File;

TCPClient client;

import oscP5.*;
import netP5.*;

int serverOSCPort = 9000;
int appPort = 9001;
String rhizomeIP = "127.0.0.1";
NetAddress rhizomeLocation;


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
OscP5 rhizomeP5;
//SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");
Calendar currentDate = Calendar.getInstance();
Map<String, Integer> loc_map = new HashMap<String, Integer>();
Map<String, Gas> gases = new HashMap<String, Gas>();
Map<String, Map<String, Map<String, Integer>>> loc_data = new HashMap<String, Map<String, Map<String, Integer>>>();
ArrayList<Gas> gas_array;


void setup() {
  //load init data  
  loadData();

  frameRate(30);
  
  
  //display mode  
  mode = 0;
  
  //fonts
  wenquanyi = loadFont("WenQuanYiZenHei-80.vlw");
  title_index = 0;
  performers_index = 0;

  client = new TCPClient(this, "mpe.xml");
 
  if(client.getID() == 0 ){
    println("subed");
    oscP5 = new OscP5(this, 12000);
    oscP5.plug(this, "newDate","/date"); 
    oscP5.plug(this, "setMode","/mode");
    oscP5.plug(this, "setText","/text");
    oscP5.plug(this, "setInteractionText","/interaction_text");
    oscP5.plug(this, "userTrig","/haze/trig");

  // rhizome configs and subscribed
    rhizomeLocation = new NetAddress(rhizomeIP, serverOSCPort);
    OscMessage subscribeMsg = new OscMessage("/sys/subscribe");
    subscribeMsg.add(12000);
    subscribeMsg.add("/haze/trig");
    oscP5.send(subscribeMsg, rhizomeLocation);
  }
  
  int mWidth;
  int mHeight;

  mWidth = client.getLWidth();
  mHeight = client.getLHeight();

  // the size is determined by the client's local width and height
   size(mWidth, mHeight);
//  size(1200, 600);

  bgCanvas =  createGraphics(mWidth, mHeight);
  
  gas_array = new ArrayList<Gas>();  
  // setup gases
  int num = 0;

  for (String loc_name : loc_map.keySet()) {
    int dis = loc_map.get(loc_name);
    Gas gas = new Gas(dis);
    gases.put(loc_name, gas);
    gas_array.add(gas);
    num += 1;
  }
  

  hint( ENABLE_DEPTH_TEST );
  
  // the random seed must be identical for all clients
  randomSeed(1);
  noiseSeed(1);
  // Starting the client
  client.start();
  background(0);
}

// Reset it called when the sketch needs to start over
void resetEvent(TCPClient c) {
    randomSeed(1);
    noiseSeed(1);
}

//--------------------------------------
// Keep the motor running... draw() needs to be added in auto mode, even if
// it is empty to keep things rolling.
void draw() {
//  background(0);
  
//  if(mode==0) { 
//    hint( ENABLE_DEPTH_TEST );
//    String dateStr = calendaer_to_date(currentDate);
//    if(frameCount % 30 == 0) {
//      currentDate.add(Calendar.DATE, 1);    
//    }
//    newDate(dateStr);
//    println(dateStr);
//    for (String loc_name : loc_map.keySet()) {
//      Gas gas = gases.get(loc_name);
//      gas.update();
//      gas.render();
//    }
//  } else if(mode==1) {
//    hint( DISABLE_DEPTH_TEST );
//    bgCanvas.beginDraw();
//    draw_glich(bgCanvas, 0);
//    bgCanvas.endDraw();
    
//    image(bgCanvas, 0, 0);
//
//    fill(255);
//    
//    textFont( wenquanyi, 100 );    
//    textAlign( CENTER );
//    text(title[title_index], width/2, 200);
//    textFont( wenquanyi, 50 );
//    text("嘉宾", width/2, 350);
//    text(performers[performers_index], width/2, 450);
//
//  } else if(mode==2) {
//
//  hint( DISABLE_DEPTH_TEST );
//
//    bgCanvas.beginDraw();
//    draw_glich(bgCanvas, 1);
//    bgCanvas.endDraw();
//    
//    image(bgCanvas, 0, 0);
//
//    
//    fill(255);
//    textFont( wenquanyi, 100 );        
//    textAlign( CENTER );
//    text("互动", width/2, 200);
//
//    textFont( wenquanyi, 50);
//    text(interaction_msg[interaction_msg_index], width/2, 400);
//
//  }
//
//  

//  fill(255);
  
}

//--------------------------------------
// Triggered by the client whenever a new frame should be rendered.
// All synchronized drawing should be done here when in auto mode.
void frameEvent(TCPClient c) {
    background(0);
  
  if(mode==0) { 
    hint( ENABLE_DEPTH_TEST );
//    String dateStr = calendaer_to_date(currentDate);
//    if(frameCount % 30 == 0) {
//      currentDate.add(Calendar.DATE, 1);    
//    }
//    newDate(dateStr);
//    println(dateStr);
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
    text(title[title_index], client.getMWidth()/2, 200);
    textFont( wenquanyi, 50 );
    text("嘉宾",client.getMWidth()/2, 350);
    text(performers[performers_index], client.getMWidth()/2, 450);

  } else if(mode==2) {

  hint( DISABLE_DEPTH_TEST );

    bgCanvas.beginDraw();
    draw_glich(bgCanvas, 1);
    bgCanvas.endDraw();
    
    image(bgCanvas, 0, 0);

    
    fill(255);
    textFont( wenquanyi, 100 );        
    textAlign( CENTER );
    text("互动", client.getMWidth()/2, 200);

    textFont( wenquanyi, 50);
    text(interaction_msg[interaction_msg_index], client.getMWidth()/2, 400);

  }

  
  // read any incoming messages
  if (c.messageAvailable()) {
    String[] msg = c.getDataMessage();
    String[] data = msg[0].split(",");
    String type = data[0];
    println(data);
    if(type.equals("date")) {
      String dateStr = data[1];
      newDateAction(dateStr);
    } else if(type.equals("mode")) {
      int mode = parseInt(data[1]);
      setModeAction(mode);
    } else if(type.equals("text")){
      int title_index = parseInt(data[1]);
      int p_index = parseInt(data[2]);
      setTextAction(title_index, p_index);
    } else if(type.equals("interaction_text")){
      int index = parseInt(data[0]);
      setInteractionTextAction(index);
    } else if(type.equals("user_trig")){
      float userId = parseFloat(data[1]);
      float vx = parseFloat(data[2]);
      float vy = parseFloat(data[3]);
      float locx = parseFloat(data[4]);
      float locy = parseFloat(data[5]);
      userTrigAction(userId, vx, vy, locx, locy);      
    }
  }
}

String calendaer_to_date(Calendar c){
  int y = c.get(Calendar.YEAR);  
  int m = c.get(Calendar.MONTH) + 1;
  int d = c.get(Calendar.DAY_OF_MONTH) + 1;
  return y + "-" + m + "-" + d;
}

public void newDate(String dateStr) {
   client.broadcast("date" + "," + dateStr);
}

public void newDateAction(String dateStr) {
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

public void userTrig(float userId, float vx, float vy, float locx, float locy) {
  client.broadcast("user_trig" + "," + userId + ',' + vx + ',' + vy + ',' + locx + ',' + locy);
}
public void userTrigAction(float userId, float vx, float vy, float locx, float locy) {
  Gas gas;
  int size = gas_array.size();
  if(userId  < size){
    gas = gas_array.get(int(userId));    
  } else {
    gas = gas_array.get(int(random(size)));
  }
  gas.setBound(locx, locy);
  gas.setUserSpeed(vx, vy);
}

public void setInteractionText(int _index) {
  client.broadcast("interaction_text" + "," + _index);
}

public void setInteractionTextAction(int _index) {
  interaction_msg_index = _index;
}

public void setText(int _title, int _performers) {
  client.broadcast("text" + "," + _title + ',' + _performers);
}

public void setTextAction(int _title, int _performers) {
  title_index = _title;
  performers_index = _performers;
}

public void setMode(int _mode) {
  client.broadcast("mode" + "," + _mode);  
}

public void setModeAction(int _mode) {  
  mode = _mode;
}

void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.isPlugged()==false) { // not bind to a responder
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }

  if (theOscMessage.addrPattern().equals("/sys/subscribed")) {
    println("subscribed successfully to address");
  }
}

void loadData() {
  String path = "gas/";

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
