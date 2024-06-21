  //DormLED Controller V4.3 by Cole Rabe 
import controlP5.*;
import processing.serial.*;

//Setup Variables
//Serial port;
//String cPort = "COM16";
boolean yesPort = false;
boolean openPort = false;
ControlP5 cp5;
PShape cHidden,spHidden,altdivHidden,c1color,c2color,c1colorHidden,c2colorHidden;
Button pOfb,pOnb,reb,rbm,acm,wm,pm,tm,cm,fm,seb,bm,sm,spm,spup,spdn,spdefault,altdivup,altdivdn,altdivdefault,aSnooze5Btn,aSnooze10Btn,aDismissBtn,aStTimBtn,aModeGrab;
Numberbox inAHr,inAMin;
Slider speedSlider,altDivider,brightSlider;
CheckBox aRampBrightCB,aEnableCB;
DropdownList c1dd,c2dd,spModes;
boolean newBrightness = false;
boolean pButtonState = false;
boolean cStatus = false;
boolean hasSent = false;
boolean canColorUpdate = false;
long cMillis = 0;
long pMillis = 0;
long aPMillis = 0;

int cStatusInd = 0;
int cSentTime = 0;
boolean canAltDiv = false;

float curBright = 255;
float prevBright = 255;
float barWidth=70.0;    //slider-bar width;
float hueVal=0;  //initial hueValue global value
float visHueVal=0;  //initial vishueValue global value
float prevHueVal=0;  //initial prevhueValue global value
float satVal=0;  //initial satValue global value
float visSatVal=0;  //initial visSatValue global value
float prevSatVal=0;  //initial prevSatValue global value
float valVal=0;  //initial satValue global value

String ledModeText = "";
String specialModeTxt = "";
boolean grabSetup = false;
int setupStep = 0;
boolean settings = false;
boolean canSetupStep = false;
int ledMode = 0;
int pLedMode = 0;
int specialMode = 0;
int colorNum = 0;
int modeSpeed = 60;
int prevSpeed = 60;
boolean canSpeed = false;
float c1colorh = 0;
float c1colors = 0;
float c1colorv = 0;
float c2colorh = 0;
float c2colors = 0;
float c2colorv = 0;
int ledDiv = 17;
int prevAltDiv = 0;
boolean modeSend = false;
boolean newMode = false;
int[] noNeedPicker = {-1,0,1,3};
int[] noNeedSpeed = {-1,0,2};
int[] noNeedAltDivider = {-1,0,1,2,3,5,6,7,8,9,10};
int[] noNeedColor1 = {-1,0,1,3,8};
int[] noNeedColor2 = {-1,0,1,2,3,6,7,8,9};
int[] noNeedSpecial = {-1,0,1,2,3,4,5,6,7,8,9};
int nl = 10; //ASCII code for carage return in serial (How it knows that it is done sending data)
String val = null; //a variable to collect seial data

//Setup Time Variables
int tiM = minute();
String tiMI = "";
int tiH = hour();
int tiAM = 45;
String tiAMI = "";
int tiAH = 7;
int aBright = 255;
boolean aBrightReset = false;
boolean aRampBright = false;
int aMode = 1;
int aSpMode = 1;
int aDay = day();
int pAlaMode = 0;
boolean aSnooze;
boolean aTxtTgl = false;
boolean aCanSnooze = false;
int aMSnoozeTime = 0;
int aHSnoozeTime = 0;
boolean aDismiss;
boolean hasAlarmTime = false;
boolean canAlarmTime = false;

//Mode Setting Storage  {Speed,Color H, Color S, Color V,Color 2 H, Color 2 S, Color V, ledDiv, Other Data}
int[] modeDefaultSpeeds = {0,25,0,5,2,70,17,20,40,0,80};
int[] modeDefaultAltDivider = {0,1,2,3,4,5,6,7,8,9,10};
int tc1t;
int tc2t;
int[] c1t = {0,0,0,0,0,0,0,0,0,0,0};
int[] c2t = {0,0,0,0,0,0,0,0,0,0,0};
boolean cCustom1 = false;
boolean cCustom2 = false;
String[] colorItems = {"","Off","Red","Orange","Yellow","Green","Blue","Purple","White","Custom"};
String[] specialItems = {"","Random","Cylon","Phaser","Alternating Phaser","Weather","Police Lights","Fire","Bouncing Ball","Twinkle","Sparkle","Running Lights","Theatre Chase","Meteor","Pop"};
String[] modeNames = {"","Rainbow","Color","Fade","Alternating Colors","Pulse","Breathe","Strobe","Paint","Time","Special"};
int[] mRainbow = {modeDefaultSpeeds[1],0,0,0,0,0,0,0};
int[] mColor = {modeDefaultSpeeds[2],0,0,0,0,0,0,0};
int[] mFade = {modeDefaultSpeeds[3],0,0,0,0,0,0,0};
int[] mAltColors = {modeDefaultSpeeds[4],0,0,0,0,0,0,15};
int[] mPulse = {modeDefaultSpeeds[5],0,0,0,0,0,0,0};
int[] mBreathe = {modeDefaultSpeeds[6],0,0,0,0,0,0,0};
int[] mStrobe = {modeDefaultSpeeds[7],0,0,0,0,0,0,0};
int[] mPaint = {modeDefaultSpeeds[8],0,0,0,0,0,0,0};
int[] mTime = {modeDefaultSpeeds[9],0,0,0,0,0,0,0};
int[] mSpecial = {modeDefaultSpeeds[10],0,0,0,0,0,0,0};
int[] alarm = {0,0,0,0,0,0,0,0};
int[] modeSpeeds = {mRainbow[0],mColor[0],mFade[0],mAltColors[0],mPulse[0],mBreathe[0],mStrobe[0],mPaint[0],mTime[0],mSpecial[0]};
boolean splitPhaser = false;
boolean compInit = false;



void setup() {  
  fullScreen();
  //surface.setSize(displayWidth, displayHeight); //Size of the Program Window
  surface.setResizable(false);
// surface.setLocation(0,0);
  colorMode(HSB);
  cp5 = new ControlP5(this);
  ControlFont font = new ControlFont(createFont("Impact",25));
  ControlFont mFont = new ControlFont(createFont("Impact",20));
  ControlFont dtFont = new ControlFont(createFont("Impact",30));
  cp5.setFont(font);


   pOnb = cp5.addButton("pOnButton")
    .setPosition(width-300, 10)
    .setImages(loadImage("Power_On_Button.png"),loadImage("Power_Button_H.png"),loadImage("Power_Off_Button.png"))
    .updateSize();
  
  pOfb = cp5.addButton("pOffButton")
    .setPosition(width-300, 10)
    .setImages(loadImage("Power_Off_Button.png"),loadImage("Power_Button_H.png"),loadImage("Power_On_Button.png"))
    .updateSize();
    
  reb = cp5.addButton("rButton")
    .setPosition(width-170, 10)
    .setImages(loadImage("Reset_Button.png"),loadImage("Reset_Button_H.png"),loadImage("Reset_Button_C.png"))
    .updateSize();
    
  seb = cp5.addButton("sButton")
    .setPosition(width-430, 13)
    .setImages(loadImage("Settings_Button.png"),loadImage("Settings_Button_H.png"),loadImage("Settings_Button_C.png"))
    .updateSize();
    
  spdefault = cp5.addButton("speedDefault")
    .setPosition(510, 325)
    .setImages(loadImage("Default_Normal.png"),loadImage("Default_Hovered.png"),loadImage("Default_Pressed.png"))
    .setSize(1,1)
    .updateSize();
    
  spup = cp5.addButton("speedUp")
    .setPosition(630, 325)
    .setImages(loadImage("Up_Normal.png"),loadImage("Up_Hovered.png"),loadImage("Up_Pressed.png"))
    .setSize(1,1)
    .updateSize();
    
  spdn = cp5.addButton("speedDown")
    .setPosition(445, 325)
    .setImages(loadImage("Down_Normal.png"),loadImage("Down_Hovered.png"),loadImage("Down_Pressed.png"))
    .setSize(1,1)
    .updateSize();
    
  altdivdefault = cp5.addButton("altDivDefault")
    .setPosition(810, 325)
    .setImages(loadImage("Default_Normal.png"),loadImage("Default_Hovered.png"),loadImage("Default_Pressed.png"))
    .setSize(1,1)
    .updateSize();
    
  altdivup = cp5.addButton("altDivUp")
    .setPosition(930, 325)
    .setImages(loadImage("Up_Normal.png"),loadImage("Up_Hovered.png"),loadImage("Up_Pressed.png"))
    .setSize(1,1)
    .updateSize();
    
  altdivdn = cp5.addButton("altDivDown")
    .setPosition(745, 325)
    .setImages(loadImage("Down_Normal.png"),loadImage("Down_Hovered.png"),loadImage("Down_Pressed.png"))
    .setSize(1,1)
    .updateSize();
    
  aSnooze5Btn = cp5.addButton("aSnooze5Btn")
    .setPosition(700, 800)
    .setLabel("+5 Min")
    .setSize(100,100)
    .setVisible(false);
    
  aSnooze10Btn = cp5.addButton("aSnooze10Btn")
    .setPosition(820, 800)
    .setSize(100,100)
    .setLabel("+10 Min")
    .setVisible(false);
    
  aDismissBtn = cp5.addButton("aDismissBtn")
    .setPosition(940, 800)
    .setSize(200,100)
    .setLabel("Dismiss")
    .setVisible(false);    
    
  aStTimBtn = cp5.addButton("aStTimBtn")
    .setPosition(1380, 360)
    .setSize(70,40)
    .setLabel("Set")
    .setVisible(false);    
    
  aModeGrab = cp5.addButton("aModeGrab")
    .setPosition(745, 515)
    .setSize(160,30)
    .setLabel("Grab Current")
    .setVisible(false);     
    
    
    brightSlider = cp5.addSlider("brightSlider")
    .setPosition(width-152,150)
    .setSize(70,850)
    .setRange(0,255)
    .setValue(0)
    .setColorValue(color(0,0,0))
    .setColorActive(color(0,0,170))
    .setColorBackground(color(0,0,60))
    .setColorForeground(color(0,0,125))
    .setLabel("");
    
   speedSlider = cp5.addSlider("speedSlider")
    .setPosition(450,250)
    .setSize(230,70)
    .setRange(0,240)
    .setValue(60)
    .setColorValue(color(255,255,0))
    .setColorActive(color(0,0,170))
    .setColorBackground(color(0,0,60))
    .setColorForeground(color(0,0,125))
    .setVisible(false)
    .setLabelVisible(false);
    
   altDivider = cp5.addSlider("altDivider")
    .setPosition(750,250)
    .setSize(230,70)
    .setRange(2,41)
    .setValue(17)
    .setColorValue(color(255,255,0))
    .setColorActive(color(0,0,170))
    .setColorBackground(color(0,0,60))
    .setColorForeground(color(0,0,125))
    .setVisible(true)
    .setLabelVisible(false);
    
    c1dd = cp5.addDropdownList("Color1")
    .setPosition(450,400)
    .setSize(230,140);
    cp5.setFont(dtFont);
    //c1dd.setCaptionLabel.align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    c1dd.setCaptionLabel("Primary Color");
    
    customize(c1dd);
    
    c2dd = cp5.addDropdownList("Color2")
    .setPosition(450,550)
    .setSize(230,140);
    cp5.setFont(dtFont);
    c2dd.setCaptionLabel("Secondary Color");
    
    spModes = cp5.addDropdownList("spModes")
    .setPosition(1050,265)
    .setSize(230,140);
    cp5.setFont(dtFont);
    //c1dd.setCaptionLabel.align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    spModes.setCaptionLabel("Modes");
    
    mcustomize(spModes);
    
    customize(c2dd);
    cp5.setFont(font);
   rbm = cp5.addButton("Rainbow")
    .setPosition(50,150)
    .setSize(125,125);
    
   acm = cp5.addButton("AlternatingColors")
    .setPosition(50,325)
    .setFont(mFont)
    .setLabel(" Alternating \n      Colors")
    .setSize(125,125);
    
   pm = cp5.addButton("Pulse")
    .setPosition(50,500)
    .setSize(125,125);
    
   wm = cp5.addButton("Paint")
    .setPosition(50,675)
    .setSize(125,125);

   tm = cp5.addButton("Time")
    .setPosition(50,850)
    .setSize(125,125);
    
   cm = cp5.addButton("Color")
    .setPosition(225,150)
    .setSize(125,125);
    
   fm = cp5.addButton("Fade")
    .setPosition(225,325)
    .setSize(125,125);
    
   bm = cp5.addButton("Breathe")
    .setPosition(225,500)
    .setSize(125,125);
    
   sm = cp5.addButton("Strobe")
    .setPosition(225,675)
    .setSize(125,125);
    
   spm = cp5.addButton("Special")
    .setPosition(225,850)
    .setSize(125,125);
    
   aRampBrightCB = cp5.addCheckBox("aRampBrightCB")
    .setPosition(884,466)
    .setSize(30,30)
    .setItemsPerRow(1)
    .addItem("",0)
    .setVisible(false);
    
   aEnableCB = cp5.addCheckBox("aEnableCB")
    .setPosition(772,565)
    .setSize(30,30)
    .setItemsPerRow(1)
    .addItem(" ",0)
    .setVisible(false);
    
   inAHr = cp5.addNumberbox("inAHr")
   .setLabel("")
   .setPosition(1245,360)
   .setValue(tiH)
   .setVisible(false)
   .setRange(0,23)
   .setMultiplier(0.1)
   .setDecimalPrecision(0)
   .setScrollSensitivity(1.1)
   .setSize(40,40);
   
   inAMin = cp5.addNumberbox("inAMin")
   .setLabel("")
   .setPosition(1305,360)
   .setValue(tiM)
   .setVisible(false)
   .setRange(0,59)
   .setMultiplier(0.1)
   .setDecimalPrecision(0)
   .setScrollSensitivity(1.1)
   .setSize(40,40);
    
    if (cStatus == true) {
    println("Already Connected");
    }
    
    cHidden = createShape(RECT,40,40,300,1000);
    cHidden.setFill(color(0));
    
    spHidden = createShape(RECT,0,0,250,50);
    spHidden.setFill(color(0));
    
    altdivHidden = createShape(RECT,0,0,250,50);
    altdivHidden.setFill(color(0));
    
    c1colorHidden = createShape(RECT,0,0,50,50);
    c1colorHidden.setFill(color(0));
    
    c2colorHidden = createShape(RECT,0,0,50,50);
    c2colorHidden.setFill(color(0));

    if ((tiAH == tiH && tiAM < tiM)||(tiAH < tiH)){
    aDay = day()+1;
    }
}




void draw() {
background(0); //Background of the Program
  int portListLen = Serial.list().length;
  for (int p=0;p<=portListLen-1;p++){
    if ((yesPort == false) && Serial.list()[p].equals(cPort)){
    yesPort = true;
    }
  }
if (yesPort == true && openPort == false){
  port = new Serial(this, cPort, 115200); //Start Connection to Arduino
  setupStep = 0;
  openPort = true;
  }
tiM = minute();
tiH = hour();
cMillis = millis();
if (openPort == true){
 val = port.readStringUntil('\n'); //STRIP data of serial port
    if (cStatus == false) {
      port.write("<s,1,0,0,0>");
    if (val != null) {
    val = trim(val);
    println(val);
    if(val.equals("yesconnect")) {
      port.clear();
      delay(10);
      cStatus = true;
      println("Full Connected!");
      pButtonState = true;
      canAltDiv = true;
      brightSlider.setValue(255);
      hasSent = false;
      compInit = true;
    }
    if (val.equals("nomore")){
      port.clear();
      delay(10);
      cStatus = true;
      println("Full Connected!");
      hasSent = false;
      grabSetup = true;
      }
    if ((!val.equals("yesconnect") || !val.equals("nomore")) && (hasSent == false) && (cSentTime >= 3000 || cSentTime == 0) && (cStatus == false)){
      delay(1000);
      port.write("<s,1,0,0,0>");
      println("Attempt Connect");
      hasSent = true;
      delay(250);
      } else if (hasSent == false && (!val.equals("yesconnect") || !val.equals("nomore")) && (cSentTime < 3000) && (cStatus == false)){
      cSentTime++;
      println("Time since sent:");
      println(cSentTime);
      }
   } 
 }
     if (cStatus == true && grabSetup == true){
       while(port.available() > 0){
       port.readString();
      }
       if (setupStep < 8){
       port.write("<s,3,"+setupStep+",0,0>");
          if (val != null) {
          val = trim(val);
          println(val);
            if (setupStep == 0){ //Get Power
              if (val.equals("0")){
                pButtonState = false;
                canSetupStep = true;
                port.clear();
                delay(10);
                }
              if (val.equals("1")){
                pButtonState = true;
                canSetupStep = true;
                port.clear();
                delay(10);
                }
              }
            if (setupStep == 1){ //Get Brightness
            curBright = float(val);
            brightSlider.setValue(float(val));
            canSetupStep = true;
            port.clear();
            delay(10);
          }
            if (setupStep == 2){ //Get Mode
            ledMode = int(val);
            if (ledMode > 0){
            ledModeText = "Mode:" + modeNames[ledMode];
            }
            if (ledMode == -1){
            ledMode = 0;
            }
            canSetupStep = true;
            port.clear();
            delay(10);
          }
            if (setupStep == 3){ //Get Divisions
            altDivider.setValue(float(val));
            prevAltDiv = ledDiv;
            canSetupStep = true;
            canAltDiv = true;
            port.clear();
            delay(10);
          }
          if (setupStep == 4){ //Get Special Mode
            specialMode = int(val);
              if (specialMode == 0){
                spModes.setLabel("Modes");
                } else {
                spModes.setLabel(specialItems[specialMode]);  
                }
            specialModeTxt = specialItems[specialMode];
            canSetupStep = true;
            port.clear();
            delay(10);
          }
          if (setupStep == 5){ //Get Speed
            //updateSpeedRange();
            speedSlider.setValue(float(val));
            canSpeed = true;
            speedUpdate();
            canSetupStep = true;
            port.clear();
            delay(10);
          }  
          if (setupStep == 6){ //Get Color1
            c1t[ledMode] = int(val);
            if(c1t[ledMode] == 0){
                c1dd.setLabel("Primary Color");
                } else {
                c1dd.setLabel(colorItems[c1t[ledMode]]);
                }
            c1dd.setValue(c1t[ledMode]);
            canSetupStep = true;
            port.clear();
            delay(10);
          }
          if (setupStep == 7){ //Get Color2
            c2t[ledMode] = int(val);
            if(c2t[ledMode] == 0){
                c2dd.setLabel("Secondary Color");
                } else {
                c2dd.setLabel(colorItems[c2t[ledMode]]);
                }
            c2dd.setValue(c2t[ledMode]);
            canSetupStep = true;
            port.clear();
            delay(10);
          }          
        if (canSetupStep == true){
        setupStep++;
        canSetupStep = false;
        port.clear();
        }  
        if (setupStep == 8){
        grabSetup = false;
        compInit = true;
        }
     }
    }
   }
}
    if (pButtonState == false){
      pOnb.hide();
      pOfb.show();
    } else {
      pOnb.show();
      pOfb.hide();
    }
  if (canColorUpdate == true){
  if (colorNum == 0){
  c1colorh = visHueVal;
  c1colors = visSatVal;
  canColorUpdate = false;
  } else if (colorNum == 1){
  c2colorh = visHueVal;
  c2colors = visSatVal;
  canColorUpdate = false;
  }
  }
  
  fill(c1colorh,c1colors,c1colorv);
  circle(710,417,40);
  fill(c2colorh,c2colors,c2colorv);
  circle(710,567,40);

  if(cStatus == true){
  cStatusInd = 117;
  } else {
  cStatusInd = 0;
  }
  
  fill(cStatusInd,255,255);
  circle(1440,65,60);
  
  hueVal= drawSliderh(width-418,250.0,barWidth,750,hueVal); //xPos yPos Width Height Value
  satVal= drawSliders(width-285,625.0,barWidth,375,satVal); //xPos yPos Width Height Value
  fill(0, 0, 255);
  textSize(100);
  textAlign(CENTER);
  text("Dorm LED Controller", displayWidth/2, 90);
  textSize(80);
  textAlign(LEFT);
  text(ledModeText, (displayWidth/2)-430, 180);
  if (ledMode != 8){
  textSize(30);
  textAlign(CENTER);
  text("Speed:", 495, 235); 
  textSize(30);
  textAlign(LEFT);
  text((modeSpeed+" Hz"), 550, 235);
  }
  else if (ledMode == 8){
  textSize(30);
  textAlign(CENTER);
  text("Frequency:", 520, 235); 
  textSize(30);
  textAlign(LEFT);
  text((modeSpeed), 600, 237);
  }
  text("# of Divisions:", 750, 235); 
  textSize(30);
  textAlign(LEFT);
  text((ledDiv), 925, 235); 
  textSize(40);
  textAlign(CENTER);
  if (colorNum == 0){
  text(("Primary"), displayWidth-320, 1050);
  }
  if (colorNum == 1){
  text(("Secondary"), displayWidth-320, 1050);
  }
  textSize(30);
  textAlign(LEFT);
  if (ledMode == 10){
  text(("Mode: "+specialModeTxt), 1050, 235);
  }
  
  
  if (prevHueVal != hueVal && (cCustom1 == true || cCustom2 == true)) {
  cModeProcessing(int(hueVal),int(prevSatVal),100);
  prevHueVal = hueVal;
  storeColorMode(9);
  }
  
    if (prevSatVal != satVal && (cCustom1 == true || cCustom2 == true)) {
  cModeProcessing(int(hueVal),int(prevSatVal),100);
  prevSatVal = satVal;
  storeColorMode(9);
  }
  
    if ((prevSpeed != modeSpeed) && (ledMode != 8)) {
  prevSpeed = modeSpeed;
  port.write("<o,0," + modeSpeed + ",0,0>");
  }
      if ((prevSpeed != modeSpeed) && (ledMode == 8)) {
  prevSpeed = modeSpeed;
  port.write("<o,0," + (modeSpeed*10) + ",0,0>");
  }
  
   if ((prevAltDiv != ledDiv) && (cStatus == true) && (canAltDiv == true)) {
  prevAltDiv = ledDiv;
  port.write("<o,1," + ledDiv + ",0,0>");
  }
  
  if (spup.isPressed() == true && (cMillis-pMillis) >= 1500){
  speedSlider.setValue(speedSlider.getValue()+1);
  }
  
  if (spdn.isPressed() == true && (cMillis-pMillis) >= 1000){
  speedSlider.setValue(speedSlider.getValue()-1);
  
  }
  if ((spup.isPressed() == false && spdn.isPressed() == false)&&(altdivup.isPressed() == false && altdivdn.isPressed() == false)){
  pMillis = cMillis;
  }
  
  if (altdivup.isPressed() == true && (cMillis-pMillis) >= 1500){
  altDivider.setValue(altDivider.getValue()+1);
  }
  
  if (altdivdn.isPressed() == true && (cMillis-pMillis) >= 1000){
  altDivider.setValue(altDivider.getValue()-1);
  
  }
  
  if ((aDismiss == true) && (hasAlarmTime == true) && (aDay==day())){
  println(aDay);
  aMSnoozeTime = 0;
  aHSnoozeTime = 0;
  if ((aDay < 31)||(day()+1 > aDay)){
  aDay++;
  println(aDay);
  } else {
  aDay = 1;
  }
  hasAlarmTime = false;
  aDismiss = false;
  println("Reset Alarm");
  }
  if (aBrightReset == true){
  port.write("<b,"+curBright+",0,0,0>");
  aBrightReset = false;
  }
  if ((((tiAM+aMSnoozeTime) >= 60 && (tiAM+aMSnoozeTime-60) <= tiM && (tiAH+aHSnoozeTime) < tiH) || ((tiAM+aMSnoozeTime) < 60 && (tiAM+aMSnoozeTime) <= tiM && (tiAH+aHSnoozeTime) == tiH)) && (canAlarmTime == true)&&(hasAlarmTime == false) && (aDay==day())){
  hasAlarmTime = true;
  if (settings == true){
  pAlaMode = pLedMode;
  } else {
  pAlaMode = ledMode;
  }
  println(ledMode);
  println(pLedMode);
  println(pAlaMode);
  if (aRampBright == true){
  port.write("<o,2,0,0,0>");
  } else {
  port.write("<b,"+aBright+",0,0,0>");
  }
  ledMode = aMode;
  specialMode = aSpMode;
  
  //Mode Setting Storage  {Speed,Color H, Color S, Color V,Color 2 H, Color 2 S, Color V, ledDiv, Other Data}
  port.write("<o,0," + alarm[0] + ",0,0>");
  port.write("<c,0," + alarm[1] + "," + alarm[2] + "," + alarm[3] + ">");
  port.write("<c,1," + alarm[4] + "," + alarm[5] + "," + alarm[6] + ">");
updateSpeedRange();
speedSlider.setValue(modeSpeeds[ledMode]);
  if (pButtonState==false){
  port.write("<p,1,0,0,0>");
  }
  if (settings == true){
  settings = false;
  aRampBrightCB.setVisible(false);
  aEnableCB.setVisible(false);
  inAHr.setVisible(false);
  inAMin.setVisible(false);
  aStTimBtn.setVisible(false);
  aModeGrab.setVisible(false);
  }
  println("Alarm!!");
  if (aMSnoozeTime <= 55){
  aSnooze5Btn.show();
  }
  if (aMSnoozeTime <= 50){
  aSnooze10Btn.show();
  aDismissBtn.show();
  }
  if (aHSnoozeTime >= 1){
  aDismissBtn.show();
  }
  aCanSnooze = true;
  }
  if (((tiAM+aMSnoozeTime) <= tiM && (tiAH+aHSnoozeTime) <= tiH)&&(canAlarmTime == false)&&(hasAlarmTime == false) && (aDay==day())){
    if ((aDay < 31)||(day()+1 > aDay)){
    aDay++;
    println("Alarm Time, But Enable Off :(. Added Day");
    } else {
    aDay = 1;
    println("Alarm Time, But Enable Off :(. Reset Day");
  }
  }
     
  if ((aMSnoozeTime > 0 || aHSnoozeTime > 0) && canAlarmTime == false){
    aMSnoozeTime = 0;
    aHSnoozeTime = 0;
    println("Alarm off no Snooze");
    }
  
  if (newBrightness == true && pButtonState == true && settings == false) {
  port.write("<b," + curBright + ",0,0,0>");
  newBrightness = false;
  }
  for (int i=0;i<noNeedPicker.length;i++){
  if (ledMode == noNeedPicker[i] || (cCustom1 == false || cCustom2 == false)){
  cHidden.setVisible(true);
  }
  }
  int pFails = 0;
  for (int i=0;i<noNeedPicker.length;i++){
  if (ledMode != noNeedPicker[i]){
    pFails++;
    if(pFails >= noNeedPicker.length && ((cCustom1 == true && colorNum == 0) || (cCustom2 == true && colorNum == 1))){
  cHidden.setVisible(false);
    }
  }
  }
    for (int i=0;i<noNeedSpeed.length;i++){
  if (ledMode == noNeedSpeed[i]){
  speedSlider.setVisible(false);
  spHidden.setVisible(true);
  spdefault.setVisible(false);
  spup.setVisible(false);
  spdn.setVisible(false);
  }
    }
    int spFails = 0;
    for (int i=0;i<noNeedSpeed.length;i++){
  if (ledMode != noNeedSpeed[i]){
    spFails++;
    if(spFails >= noNeedSpeed.length){
  speedSlider.setVisible(true);
  spHidden.setVisible(false);
  spdefault.setVisible(true);
  spup.setVisible(true);
  spdn.setVisible(true);
    }
  }
  }
  
      for (int i=0;i<noNeedAltDivider.length;i++){
  if (ledMode == noNeedAltDivider[i]){
  altDivider.setVisible(false);
  altdivHidden.setVisible(true);
  altdivdefault.setVisible(false);
  altdivup.setVisible(false);
  altdivdn.setVisible(false);
  }
    }
    int altDivFails = 0;
    for (int i=0;i<noNeedAltDivider.length;i++){
  if (ledMode != noNeedAltDivider[i]){
    altDivFails++;
    if(altDivFails >= noNeedAltDivider.length){
  altDivider.setVisible(true);
  altdivHidden.setVisible(false);
  altdivdefault.setVisible(true);
  altdivup.setVisible(true);
  altdivdn.setVisible(true);
    }
  }
  }
  
  for (int i=0;i<noNeedColor1.length;i++){
  if (ledMode == noNeedColor1[i]){
  c1dd.setVisible(false);
  c1colorHidden.setVisible(true);

  }
    }
    int c1Fails = 0;
    for (int i=0;i<noNeedColor1.length;i++){
  if (ledMode != noNeedColor1[i]){
    c1Fails++;
    if(c1Fails >= noNeedColor1.length){
  c1dd.setVisible(true);
  c1colorHidden.setVisible(false);
    }
  }
  }
  
    for (int i=0;i<noNeedColor2.length;i++){
  if (ledMode == noNeedColor2[i]){
  c2dd.setVisible(false);
  c2colorHidden.setVisible(true);

  }
    }
    int c2Fails = 0;
    for (int i=0;i<noNeedColor2.length;i++){
  if (ledMode != noNeedColor2[i]){
    c2Fails++;
    if(c2Fails >= noNeedColor2.length){
  c2dd.setVisible(true);
  c2colorHidden.setVisible(false);
    }
  }
  }
    for (int i=0;i<noNeedSpecial.length;i++){
  if (ledMode == noNeedSpecial[i]){
  spModes.setVisible(false);

  }
    }
    int spModeFails = 0;
    for (int i=0;i<noNeedSpecial.length;i++){
  if (ledMode != noNeedSpecial[i]){
    spModeFails++;
    if(spModeFails >= noNeedSpecial.length){
  spModes.setVisible(true);
    }
  }
  }
  
  if (cHidden.isVisible()==true){
  shape(cHidden,1380,90);
  }
    if (spHidden.isVisible()==true){
  shape(spHidden,450,200);
  
  }
    if (c1colorHidden.isVisible()==true){
  shape(c1colorHidden,690,397);
  }
    if (c2colorHidden.isVisible()==true){
  shape(c2colorHidden,690,537);
  
  }
    if (altdivHidden.isVisible()==true){
  shape(altdivHidden,750,200);
  
  }
  if ((pButtonState == true || aCanSnooze == true) && modeSend == true && ledMode != 10){
  port.write("<m,"+ ledMode +",0,0,0>");
  modeSend = false;
  }
  if ((pButtonState == true || aCanSnooze == true) && modeSend == true && ledMode == 10){
  port.write("<m,"+ ledMode +","+specialMode+",0,0>");
  modeSend = false;
  }
  
  if(aRampBrightCB.getState(0)==true){
  aRampBright = true;
  } else {
  aRampBright = false;
  }
  
  if(aEnableCB.getState(0)==true){
  canAlarmTime = true;
  } else {
  canAlarmTime = false;
  }
  
  if (settings == true){
  textSize(60);
  textAlign(LEFT);
  text("Settings Menu", (displayWidth/2)-430, 240);
  textSize(40);
  if (tiM < 10){
  tiMI = "0";
  } else {
  tiMI = "";
  }
  if ((tiAM+aMSnoozeTime < 10) || ((tiAM+aMSnoozeTime-60 < 10)&&(tiAM+aMSnoozeTime >= 60))){
  tiAMI = "0";
  } else {
  tiAMI = "";
  }
  text("Current 24 Hr time is {"+tiH+" : "+tiMI+tiM+"}", (displayWidth/2)-430, 340);
  if (tiAM+aMSnoozeTime >= 60){
  text("Set 24 Hr Alarm time is {"+(tiAH+aHSnoozeTime+1)+" : "+tiAMI+(tiAM+aMSnoozeTime-60)+"}", (displayWidth/2)-430, 390);
  } else {
  text("Set 24 Hr Alarm time is {"+(tiAH+aHSnoozeTime)+" : "+tiAMI+(tiAM+aMSnoozeTime)+"}", (displayWidth/2)-430, 390);
  }
  text("Alarm Brightness: "+aBright, (displayWidth/2)-430, 440);
  text("Ramp up Brightness: ", (displayWidth/2)-430, 490);
  if (aMode != 10){
  text("Alarm Mode: ", (displayWidth/2)-430, 540);
  text(modeNames[aMode], (displayWidth/2)-50, 543);
  } else {
  text("Alarm Mode: ", (displayWidth/2)-430, 540);
  text(specialItems[aSpMode], (displayWidth/2)-50, 543);
  }
  text("Alarm Enable:", (displayWidth/2)-430, 590);
  text("Set Time: ", 1075, 390);
  text(":", 1290, 390);
  text("Next Alarm: ",1075,340);
  if (aDay > day()){
  text("Tomorrow",1275,340);
  } else {
  text("Today",1275,340);
  }
  }
  
    if(aTxtTgl == true){
  textSize(40);    
  text("ALARM!!",855,790);
  }
  
  if (aCanSnooze == true && (cMillis-aPMillis) >= 1000){
  aTxtTgl =! aTxtTgl;  
  aPMillis = cMillis;
  }
  
  if (aDismissBtn.isVisible() == true && aCanSnooze == false){
  aSnooze10Btn.hide();
  aSnooze5Btn.hide();
  aDismissBtn.hide();
  }
  
  if(brightSlider.isInside() == false && settings == true && (brightSlider.getValue() != curBright)){
brightSlider.setValue(curBright);
    }
    
    modeHandling();
}

void aStTimBtn(){
  tiAH = int(inAHr.getValue());
  tiAM = int(inAMin.getValue());
  aTxtTgl = false;
  aCanSnooze = false;
  aMSnoozeTime = 0;
  aHSnoozeTime = 0;
  port.write("<o,3,0,0,0>");
  if ((tiAH == tiH && tiAM < tiM)||(tiAH < tiH)){
  aDay = day()+1;
  } else{
  aDay = day();
  }
}

void aSnooze5Btn(){
if(aCanSnooze == true){  
println("+5 Added");
port.write("<o,3,0,0,0>");
if (settings == true){
settings = false;
  aRampBrightCB.setVisible(false);
  aEnableCB.setVisible(false);
  inAHr.setVisible(false);
  inAMin.setVisible(false);
  aStTimBtn.setVisible(false);
  aModeGrab.setVisible(true);
}
aBrightReset = true;
aTxtTgl = false;
if (pButtonState==false){
port.write("<p,0,0,0,0>");
}
ledMode = pAlaMode;
updateSpeedRange();
speedSlider.setValue(modeSpeeds[ledMode]);
if (aMSnoozeTime < 60){
aMSnoozeTime = aMSnoozeTime + 5;
} else {
aMSnoozeTime = 0;
aHSnoozeTime = 1;
}
hasAlarmTime = false;
aCanSnooze = false;
}
}

void aSnooze10Btn(){
if(aCanSnooze == true){
println("+10 Added");
port.write("<o,3,0,0,0>");
if (settings == true){
settings = false;
  aRampBrightCB.setVisible(false);
  aEnableCB.setVisible(false);
  inAHr.setVisible(false);
  inAMin.setVisible(false);
  aStTimBtn.setVisible(false);
  aModeGrab.setVisible(true);
}
aBrightReset = true;
aTxtTgl = false;
if (pButtonState==false){
port.write("<p,0,0,0,0>");
}
ledMode = pAlaMode;
updateSpeedRange();
speedSlider.setValue(modeSpeeds[ledMode]);
if (aMSnoozeTime < 60){
aMSnoozeTime = aMSnoozeTime + 10;
} else {
aMSnoozeTime = 0;
aHSnoozeTime = 1;
}
hasAlarmTime = false;
aCanSnooze = false;
}
}

void aDismissBtn(){
if(aCanSnooze == true){
port.write("<o,3,0,0,0>");
if (settings == true){
settings = false;
  aRampBrightCB.setVisible(false);
  aEnableCB.setVisible(false);
  inAHr.setVisible(false);
  inAMin.setVisible(false);
  aStTimBtn.setVisible(false);
  aModeGrab.setVisible(true);
}
aBrightReset = true;
aTxtTgl = false;
println("Dismissed");
aDismiss = true;
if (pButtonState==false){
port.write("<p,0,0,0,0>");
}
ledMode = pAlaMode;
updateSpeedRange();
speedSlider.setValue(modeSpeeds[ledMode]);
aCanSnooze = false;
}
}

void brightSlider(float theBrightness){
if (curBright != theBrightness && (cStatus == true) && (settings == false)){
curBright = theBrightness;
newBrightness = true;
}
if (curBright != theBrightness && (cStatus == true) && (settings == true)){
aBright = int(theBrightness);
port.write("<o,4,"+aBright+",0,0>");
  }
}
void speedSlider(int speed){
modeSpeed = speed;
newMode = true;
speedUpdate();
}

void speedUpdate(){
if (canSpeed == true){
if(ledMode == 1){
mRainbow[0] = modeSpeed;
newMode = false;

}
else if(ledMode == 2){
mColor[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 3){
mFade[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 4){
mAltColors[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 5){
mPulse[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 6){
mBreathe[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 7){
mStrobe[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 8){
mPaint[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 9){
mTime[0] = modeSpeed;
newMode = false;
}
else if(ledMode == 10){
mSpecial[0] = modeSpeed;
newMode = false;
}
}
}

void updateSpeedRange(){
  if (compInit == true){
if (ledMode == 1){
  speedSlider.setRange(0,1000);
}
else if(ledMode == 2){
speedSlider.setRange(0,0);
}
else if(ledMode == 3){
speedSlider.setRange(0,800);
}
else if(ledMode == 4){
speedSlider.setRange(0,60);
}
else if(ledMode == 5){
speedSlider.setRange(0,100);
}
else if(ledMode == 6){
speedSlider.setRange(0,240);
}
else if(ledMode == 7){
speedSlider.setRange(0,75);
}
else if(ledMode == 8){
speedSlider.setRange(0,1000);
}
else if(ledMode == 9){
speedSlider.setRange(0,240);
}
else if(ledMode == 10){
speedSlider.setRange(0,500);
}
}
}

void altDivider(int altdiv){
ledDiv = altdiv;
if(ledMode == 1){
mRainbow[7] = ledDiv;
}
if(ledMode == 2){
mColor[7] = ledDiv;
}
if(ledMode == 3){
mFade[7] = ledDiv;
}
if(ledMode == 4){
mAltColors[7] = ledDiv;
}
if(ledMode == 5){
mPulse[7] = ledDiv;
}
if(ledMode == 6){
mBreathe[7] = ledDiv;
}
if(ledMode == 7){
mStrobe[7] = ledDiv;
}
if(ledMode == 8){
mPaint[7] = ledDiv;
}
if(ledMode == 9){
mTime[7] = ledDiv;
}
if(ledMode == 10){
mSpecial[7] = ledDiv;
}
}

void speedUp(){
speedSlider.setValue(speedSlider.getValue()+1);
}
void speedDown(){
speedSlider.setValue(speedSlider.getValue()-1);
}
void speedDefault(){
speedSlider.setValue(modeDefaultSpeeds[ledMode]);
}

void altDivUp(){
altDivider.setValue(altDivider.getValue()+1);
}
void altDivDown(){
altDivider.setValue(altDivider.getValue()-1);
}
void altDivDefault(){
altDivider.setValue(modeDefaultAltDivider[ledMode]);
}

void pOnButton(){
  if (pButtonState==true && aCanSnooze == false && compInit == true){
    pOnb.hide();
    pOfb.show();
    pButtonState=false;
    port.write("<p,0,0,0,0>");
  }
  

}

void pOffButton(){
  if (pButtonState==false && aCanSnooze == false &&  compInit == true){
    pOfb.hide();
    pOnb.show();
    pButtonState=true;
    port.write("<p,1,0,0,0>");
  }
}
void sButton(){
if (cStatus == true && compInit == true){
if (settings == false){
  pLedMode = ledMode;
  ledMode = -1;
  aRampBrightCB.setVisible(true);
  aEnableCB.setVisible(true);
  inAHr.setVisible(true);
  inAMin.setVisible(true);
  aStTimBtn.setVisible(true);
  aModeGrab.setVisible(true);
  println("On");
}
else if (settings == true){
  ledMode = pLedMode;
  println("Off");
  aRampBrightCB.setVisible(false);
  aEnableCB.setVisible(false);
  inAHr.setVisible(false);
  inAMin.setVisible(false);
  aStTimBtn.setVisible(false);
  aModeGrab.setVisible(false);
}
settings =! settings;
}
}

void rButton(){
  port.stop();
  cStatusInd = 0;
  cStatus = false;
  openPort = false;
  yesPort = false;
  println("New Port");
}

void aModeGrab(){
  aMode = pLedMode;
  if (aMode == 10){
  aSpMode = specialMode;
  }
  alarmGrabSettings();
}

void Color1(){
 tc1t = int(c1dd.getValue());
if (tc1t >= 1){
 colorNum = 0;
 c1colorv = 255;
}
 if (tc1t == 1){
  cModeProcessing(0,0,0);
  c1colorv = 0;
 }
 if (tc1t == 2){
  cModeProcessing(0,100,100);
  cCustom1 = false;
 }
 if (tc1t == 3){
  cModeProcessing(16,100,100);
  cCustom1 = false;
 }
 if (tc1t == 4){
  cModeProcessing(60,100,100);
  cCustom1 = false;
 }
 if (tc1t == 5){
  cModeProcessing(120,100,100);
  cCustom1 = false;
 }
 if (tc1t == 6){
  cModeProcessing(240,100,100);
  cCustom1 = false;
 }
 if (tc1t == 7){
  cModeProcessing(300,100,100);
  cCustom1 = false;
 }
 if (tc1t == 8){
  cModeProcessing(0,0,100); 
  cCustom1 = false;
 }
 if (tc1t == 9){
  cCustom1 = true;
}
if (tc1t != 9){
storeColorMode(tc1t);
}
}

void Color2(){
 tc2t = int(c2dd.getValue());
if (tc2t >= 1){
 colorNum = 1;
 c2colorv = 255;
}
 if (tc2t == 1){
  cModeProcessing(0,0,0);
  cCustom2 = false;
  c2colorv = 0;
 }
 if (tc2t == 2){
  cModeProcessing(0,100,100);
  cCustom2 = false;
 }
 if (tc2t == 3){
  cModeProcessing(16,100,100);
  cCustom2 = false;
 }
 if (tc2t == 4){
  cModeProcessing(60,100,100);
  cCustom2 = false;
 }
 if (tc2t == 5){
  cModeProcessing(120,100,100);
  cCustom2 = false;
 }
 if (tc2t == 6){
  cModeProcessing(240,100,100);
  cCustom2 = false;
 }
 if (tc2t == 7){
  cModeProcessing(300,100,100);
  cCustom2 = false;
 }
 if (tc2t == 8){
  cModeProcessing(0,0,100);
  cCustom2 = false;
 }
 if (tc2t == 9){
  cCustom2 = true;
}
storeColorMode(tc2t);
}

void spModes(){
 float tmode = spModes.getValue();
 if (tmode == 0){
  specialMode = 0;
  specialModeTxt = "";
  modeSend = true;
 }
 if (tmode == 1){
  specialMode = int(random(2,12));
  specialModeTxt = specialItems[specialMode];
  modeSend = true;
 }
 if (tmode == 2){
   specialMode = 2;
   specialModeTxt = specialItems[2];
  modeSend = true;
 }
 if (tmode == 3){
   specialMode = 3;
   specialModeTxt = specialItems[3];
  modeSend = true;
 }
 if (tmode == 4){
   specialMode = 4;
   specialModeTxt = specialItems[4];
  modeSend = true;
 }
 if (tmode == 5){
   specialMode = 5;
   specialModeTxt = specialItems[5];
  modeSend = true;
 }
 if (tmode == 6){
   specialMode = 6;
   specialModeTxt = specialItems[6];
  modeSend = true;
 }
 if (tmode == 7){
   specialMode = 7;
   specialModeTxt = specialItems[7];
  modeSend = true;
 }
 if (tmode == 8){
   specialMode = 8;
   specialModeTxt = specialItems[8];
  modeSend = true;
 }
 if (tmode == 9){
   specialMode = 9;
   specialModeTxt = specialItems[9];
  modeSend = true;
}
 if (tmode == 10){
   specialMode = 10;
   specialModeTxt = specialItems[10];
  modeSend = true;
}
 if (tmode == 11){
   specialMode = 11;
   specialModeTxt = specialItems[11];
  modeSend = true;
}
 if (tmode == 12){
   specialMode = 12;
   specialModeTxt = specialItems[12];
  modeSend = true;
}
 if (tmode == 13){
   specialMode = 13;
   specialModeTxt = specialItems[13];
  modeSend = true;
}
 if (tmode == 14){
   specialMode = 14;
   specialModeTxt = specialItems[14];
  modeSend = true;
}
}

void Rainbow(){
if(settings == false){
canSpeed = false;
ledMode = 1;
}
}


void Color(){
if(settings == false){
canSpeed = false;
ledMode = 2;

}
}


void Fade(){
if(settings == false){
canSpeed = false;
ledMode = 3;
}
}

void AlternatingColors(){
if(settings == false){
canSpeed = false;
ledMode = 4;
}
}

void Pulse(){
if(settings == false){
canSpeed = false;
ledMode = 5;
}
}

void Breathe(){
if(settings == false){
canSpeed = false;
ledMode = 6;
}
}

void Strobe(){
if(settings == false){
canSpeed = false;
ledMode = 7;
}
}

void Paint(){
if(settings == false){
canSpeed = false;
ledMode = 8;
}
}

void Time(){
if(settings == false){
canSpeed = false;
ledMode = 9;
}
}

void Special(){
if(settings == false){
canSpeed = false;
ledMode = 10;
}
}

float drawSliderh(float xPos, float yPos, float sWidth, float sHeight,float hueVal){
  
  float sliderPos=map(hueVal,0,360,0,sHeight); //find the current sliderPosition from hueVal
  
  for(int i=0;i<sHeight;i++){  //draw 1 line for each hueValue from 0-255
      float hueValue=map(i,0,sHeight,0,255);  //get hueVal for each i position //local variable
      stroke(hueValue,255,255);
      line(xPos,yPos+i,xPos+sWidth,yPos+i);
  }
  if(mousePressed && mouseX>xPos && mouseX<(xPos+sWidth) && mouseY>yPos && mouseY <yPos+sHeight && cHidden.isVisible()==false){
     sliderPos=mouseY-yPos;
     hueVal=map(sliderPos,0,sHeight,0,360);  // get new hueVal based on moved slider
     visHueVal=map(sliderPos,0,sHeight,0,255);  // get new visHueVal based on moved slider
  } 
  stroke(100);
  fill(visHueVal,255,255);  //either new or old hueVal
  rect(xPos-5,yPos-3+sliderPos,sWidth+10,6);  //this is our slider indicator that moves
  fill(visHueVal,visSatVal,255);  //either new or old hueVal
  rect(xPos, yPos-100, sWidth,sWidth,80); // this rectangle displays the changing color above
 // canColorUpdate = true;
  return hueVal;
}

float drawSliders(float xPos, float yPos, float sWidth, float sHeight,float satVal){
  
  float sliderPos=map(satVal,100,0,0,sHeight); //find the current sliderPosition from satVal
  
  for(int i=0;i<sHeight;i++){  //draw 1 line for each satValue from 0-255
      float satValue=map(i,0,sHeight,255,0);  //get satVal for each i position //local variable
      stroke(visHueVal,satValue,255);
      line(xPos,yPos+i,xPos+sWidth,yPos+i);
  }
  if(mousePressed && mouseX>xPos && mouseX<(xPos+sWidth) && mouseY>yPos && mouseY <yPos+sHeight&& cHidden.isVisible()==false){
     sliderPos=mouseY-yPos;
     satVal=map(sliderPos,0,sHeight,100,0);  // get new satVal based on moved slider
     visSatVal=map(sliderPos,0,sHeight,255,0);  // get new visSatVal based on moved slider
  } 
  stroke(100);
  fill(visHueVal,visSatVal,255);  //either new or old satVal
  rect(xPos-5,yPos-3+sliderPos,sWidth+10,6);  //this is our slider indicator that moves
  return satVal;
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ControlFont dFont = new ControlFont(createFont("Impact",25));
  ddl.close();
  ddl.setBackgroundColor(color(190));
  ddl.setBarHeight(35);
  ddl.getCaptionLabel().getStyle().marginTop = 9;
  ddl.setItemHeight(30);
  ddl.getValueLabel().getStyle().marginTop = 8;
  for (int i=0;i<colorItems.length;i++) {
    ddl.setFont(dFont);
    ddl.addItem(colorItems[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void mcustomize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ControlFont dFont = new ControlFont(createFont("Impact",25));
  ddl.close();
  ddl.setBackgroundColor(color(190));
  ddl.setBarHeight(35);
  ddl.getCaptionLabel().getStyle().marginTop = 9;
  ddl.setItemHeight(30);
  ddl.getValueLabel().getStyle().marginTop = 8;
  for (int i=0;i<specialItems.length;i++) {
    ddl.setFont(dFont);
    ddl.addItem(specialItems[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void cModeProcessing(int hue, int sat, int val){
  port.write("<c,"+ colorNum +","+ hue +","+ sat +","+ val +">");
 if(colorNum == 0){
  c1colorh = map(hue,0,360,0,255);
  c1colors = map(sat,0,100,0,255);
  if (ledMode == 1){
   mRainbow[1] = hue;
   mRainbow[2] = sat;
   mRainbow[3] = val;
   }
   if (ledMode == 2){
   mColor[1] = hue;
   mColor[2] = sat;
   mColor[3] = val;

   }
   if (ledMode == 3){
   mFade[1] = hue;
   mFade[2] = sat;
   mFade[3] = val;

   }
   if (ledMode == 4){
   mAltColors[1] = hue;
   mAltColors[2] = sat;
   mAltColors[3] = val;

   }
   if (ledMode == 5){
   mPulse[1] = hue;
   mPulse[2] = sat;
   mPulse[3] = val;

   }
   if (ledMode == 6){
   mBreathe[1] = hue;
   mBreathe[2] = sat;
   mBreathe[3] = val;
   }
   if (ledMode == 7){
   mStrobe[1] = hue;
   mStrobe[2] = sat;
   mStrobe[3] = val;
   }
   if (ledMode == 8){
   mPaint[1] = hue;
   mPaint[2] = sat;
   mPaint[3] = val;
   }
   if (ledMode == 9){
   mTime[1] = hue;
   mTime[2] = sat;
   mTime[3] = val;
   }
   if (ledMode == 10){
   mSpecial[1] = hue;
   mSpecial[2] = sat;
   mSpecial[3] = val;
   if(splitPhaser == false){
   port.write("<c,"+ 1 +","+ hue +","+ sat +","+ val +">");
   mSpecial[4] = hue;
   mSpecial[5] = sat;
   mSpecial[6] = val;
   c2colorh = map(hue,0,360,0,255);
   c2colors = map(sat,0,100,0,255);
   c2colorv = 255;
   }
   }
}

 if(colorNum == 1){
  c2colorh = map(hue,0,360,0,255);
  c2colors = map(sat,0,100,0,255);
  if (ledMode == 1){
   mRainbow[4] = hue;
   mRainbow[5] = sat;
   mRainbow[6] = val;
   }
   if (ledMode == 2){
   mColor[4] = hue;
   mColor[5] = sat;
   mColor[6] = val;

   }
   if (ledMode == 3){
   mFade[4] = hue;
   mFade[5] = sat;
   mFade[6] = val;

   }
   if (ledMode == 4){
   mAltColors[4] = hue;
   mAltColors[5] = sat;
   mAltColors[6] = val;

   }
   if (ledMode == 5){
   mPulse[4] = hue;
   mPulse[5] = sat;
   mPulse[6] = val;

   }
   if (ledMode == 6){
   mBreathe[4] = hue;
   mBreathe[5] = sat;
   mBreathe[6] = val;
   }
   if (ledMode == 7){
   mStrobe[4] = hue;
   mStrobe[5] = sat;
   mStrobe[6] = val;
   }
   if (ledMode == 8){
   mPaint[4] = hue;
   mPaint[5] = sat;
   mPaint[6] = val;
   }
   if (ledMode == 9){
   mTime[4] = hue;
   mTime[5] = sat;
   mTime[6] = val;
   }
   if (ledMode == 10){  
   mSpecial[4] = hue;
   mSpecial[5] = sat;
   mSpecial[6] = val;
   if (splitPhaser == false && compInit == true){
   splitPhaser = true;
       }
    }
  }
}

void storeColorMode(int colorMode){
if (compInit == true){
  if (colorNum == 0) {
  c1t[ledMode] = colorMode;
  if (splitPhaser == false && ledMode == 10&& c1t[ledMode] != 0){
  c2dd.setLabel(colorItems[c1t[ledMode]]);
  port.write("<c,3,"+ c1t[ledMode] +",0,0>");
  }
  port.write("<c,2,"+ c1t[ledMode] +",0,0>");
  }
if (colorNum == 1) {
  c2t[ledMode] = colorMode;
  port.write("<c,3,"+ c2t[ledMode] +",0,0>");
  }
}
}



void modeHandling(){

if (pLedMode != ledMode && compInit == true){
  if (ledMode == 1){
port.write("<o,0," + mRainbow[0] + ",0,0>");
updateSpeedRange();
speedSlider.setValue(mRainbow[0]);
modeSend = true;
ledModeText = "Mode:" + modeNames[1];
}

if (ledMode == 2){
    if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }  
port.write("<c,0," + mColor[1] + "," + mColor[2] + "," + mColor[3] + ">");
port.write("<c,2,"+ c1t[ledMode] +",0,0>");
modeSend = true;
ledModeText = "Mode:" + modeNames[2];
c1colorh = map(mColor[1],0,360,0,255);
c1colors = map(mColor[2],0,100,0,255);
c1colorv = map(mColor[3],0,100,0,255);
}

if (ledMode == 3){
port.write("<o,0," + mFade[0] + ",0,0>");
updateSpeedRange();
speedSlider.setValue(mFade[0]);
modeSend = true;
ledModeText = "Mode:" + modeNames[3];
}

if (ledMode == 4){
    if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }
    if(c2t[ledMode] == 0){
  c2dd.setLabel("Secondary Color");
  } else {
c2dd.setLabel(colorItems[c2t[ledMode]]);
  } 
port.write("<o,0," + mAltColors[0] + ",0,0>");
port.write("<c,0," + mAltColors[1] + "," + mAltColors[2] + "," + mAltColors[3] + ">");
port.write("<c,1," + mAltColors[4] + "," + mAltColors[5] + "," + mAltColors[6] + ">");
port.write("<c,2,"+ c1t[ledMode] +",0,0>");
port.write("<c,3,"+ c2t[ledMode] +",0,0>");
updateSpeedRange();
speedSlider.setValue(mAltColors[0]);
modeSend = true;
ledModeText = "Mode:" + modeNames[4];
c1colorh = map(mAltColors[1],0,360,0,255);
c1colors = map(mAltColors[2],0,100,0,255);
c1colorv = map(mAltColors[3],0,100,0,255);
c2colorh = map(mAltColors[4],0,360,0,255);
c2colors = map(mAltColors[5],0,100,0,255);
c2colorv = map(mAltColors[6],0,100,0,255);
}

if (ledMode == 5){
    if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }
    if(c2t[ledMode] == 0){
  c2dd.setLabel("Secondary Color");
  } else {
c2dd.setLabel(colorItems[c2t[ledMode]]);
  }
port.write("<o,0," + mPulse[0] + ",0,0>");
port.write("<c,0," + mPulse[1] + "," + mPulse[2] + "," + mPulse[3] + ">");
port.write("<c,1," + mPulse[4] + "," + mPulse[5] + "," + mPulse[6] + ">");
port.write("<c,2,"+ c1t[ledMode] +",0,0>");
port.write("<c,3,"+ c2t[ledMode] +",0,0>");
updateSpeedRange();
speedSlider.setValue(mPulse[0]);
modeSend = true;
ledModeText = "Mode:" + modeNames[5];
c1colorh = map(mPulse[1],0,360,0,255);
c1colors = map(mPulse[2],0,100,0,255);
c1colorv = map(mPulse[3],0,100,0,255);
c2colorh = map(mPulse[4],0,360,0,255);
c2colors = map(mPulse[5],0,100,0,255);
c2colorv = map(mPulse[6],0,100,0,255);
}

if (ledMode == 6){
  if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }
port.write("<o,0," + mBreathe[0] + ",0,0>");
port.write("<c,0," + mBreathe[1] + "," + mBreathe[2] + "," + mBreathe[3] + ">");
port.write("<c,2,"+ c1t[ledMode] +",0,0>");
updateSpeedRange();
speedSlider.setValue(mBreathe[0]);
modeSend = true;
ledModeText = "Mode:" + modeNames[6];
c1colorh = map(mBreathe[1],0,360,0,255);
c1colors = map(mBreathe[2],0,100,0,255);
c1colorv = map(mBreathe[3],0,100,0,255);
}

if (ledMode == 7){
    if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }
port.write("<o,0," + mStrobe[0] + ",0,0>");
port.write("<c,0," + mStrobe[1] + "," + mStrobe[2] + "," + mStrobe[3] + ">");
port.write("<c,2,"+ c1t[ledMode] +",0,0>");
updateSpeedRange();
speedSlider.setValue(mStrobe[0]);
modeSend = true;
ledModeText = "Mode:" + modeNames[7];
c1colorh = map(mStrobe[1],0,360,0,255);
c1colors = map(mStrobe[2],0,100,0,255);
c1colorv = map(mStrobe[3],0,100,0,255);
}

if (ledMode == 8){
port.write("<o,0," + (mPaint[0]*10) + ",0,0>");
modeSend = true;
updateSpeedRange();
speedSlider.setValue(mPaint[0]);
ledModeText = "Mode:" + modeNames[8];
}

if (ledMode == 9){
    if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }
    if(c2t[ledMode] == 0){
  c2dd.setLabel("Secondary Color");
  } else {
c2dd.setLabel(colorItems[c2t[ledMode]]);
  }
modeSend = true;
updateSpeedRange();
ledModeText = "Mode:" + modeNames[9];
}

if (ledMode == 10){
    if(c1t[ledMode] == 0){
  c1dd.setLabel("Primary Color");
  } else {
c1dd.setLabel(colorItems[c1t[ledMode]]);
  }
    if(c2t[ledMode] == 0){
  c2dd.setLabel("Secondary Color");
  } else {
c2dd.setLabel(colorItems[c2t[ledMode]]);
  }
  if (specialMode == 0){
  spModes.setLabel("Modes");
  } else {
  spModes.setLabel(specialItems[specialMode]);  
  }
updateSpeedRange();
speedSlider.setValue(mSpecial[0]);
port.write("<o,0," + (mSpecial[0]) + ",0,0>");
port.write("<c,0," + mSpecial[1] + "," + mSpecial[2] + "," + mSpecial[3] + ">");
port.write("<c,1," + mSpecial[4] + "," + mSpecial[5] + "," + mSpecial[6] + ">");
port.write("<c,2,"+ c1t[ledMode] +",0,0>");
port.write("<c,3,"+ c2t[ledMode] +",0,0>");
modeSend = true;
c1colorh = map(mSpecial[1],0,360,0,255);
c1colors = map(mSpecial[2],0,100,0,255);
c1colorv = map(mSpecial[3],0,100,0,255);
c2colorh = map(mSpecial[4],0,360,0,255);
c2colors = map(mSpecial[5],0,100,0,255);
c2colorv = map(mSpecial[6],0,100,0,255);
ledModeText = "Mode:" + modeNames[10];
}
if (ledMode != -1){
pLedMode = ledMode;
}
canSpeed = true;
}
}

void alarmGrabSettings(){
if (ledMode == 1){
alarm[0] = mRainbow[0];
alarm[1] = mRainbow[1];
alarm[2] = mRainbow[2];
alarm[3] = mRainbow[3];
alarm[4] = mRainbow[4];
alarm[5] = mRainbow[5];
alarm[6] = mRainbow[6];
alarm[7] = mRainbow[7];
}

if (ledMode == 2){
alarm[0] = mColor[0];
alarm[1] = mColor[1];
alarm[2] = mColor[2];
alarm[3] = mColor[3];
alarm[4] = mColor[4];
alarm[5] = mColor[5];
alarm[6] = mColor[6];
alarm[7] = mColor[7];
}

if (ledMode == 3){
alarm[0] = mFade[0];
alarm[1] = mFade[1];
alarm[2] = mFade[2];
alarm[3] = mFade[3];
alarm[4] = mFade[4];
alarm[5] = mFade[5];
alarm[6] = mFade[6];
alarm[7] = mFade[7];
}

if (ledMode == 4){
alarm[0] = mAltColors[0];
alarm[1] = mAltColors[1];
alarm[2] = mAltColors[2];
alarm[3] = mAltColors[3];
alarm[4] = mAltColors[4];
alarm[5] = mAltColors[5];
alarm[6] = mAltColors[6];
alarm[7] = mAltColors[7];
}

if (ledMode == 5){
alarm[0] = mPulse[0];
alarm[1] = mPulse[1];
alarm[2] = mPulse[2];
alarm[3] = mPulse[3];
alarm[4] = mPulse[4];
alarm[5] = mPulse[5];
alarm[6] = mPulse[6];
alarm[7] = mPulse[7];
}

if (ledMode == 6){
alarm[0] = mBreathe[0];
alarm[1] = mBreathe[1];
alarm[2] = mBreathe[2];
alarm[3] = mBreathe[3];
alarm[4] = mBreathe[4];
alarm[5] = mBreathe[5];
alarm[6] = mBreathe[6];
alarm[7] = mBreathe[7];
}

if (ledMode == 7){
alarm[0] = mStrobe[0];
alarm[1] = mStrobe[1];
alarm[2] = mStrobe[2];
alarm[3] = mStrobe[3];
alarm[4] = mStrobe[4];
alarm[5] = mStrobe[5];
alarm[6] = mStrobe[6];
alarm[7] = mStrobe[7];
}

if (ledMode == 8){
alarm[0] = mPaint[0];
alarm[1] = mPaint[1];
alarm[2] = mPaint[2];
alarm[3] = mPaint[3];
alarm[4] = mPaint[4];
alarm[5] = mPaint[5];
alarm[6] = mPaint[6];
alarm[7] = mPaint[7];
}

if (ledMode == 9){
alarm[0] = mTime[0];
alarm[1] = mTime[1];
alarm[2] = mTime[2];
alarm[3] = mTime[3];
alarm[4] = mTime[4];
alarm[5] = mTime[5];
alarm[6] = mTime[6];
alarm[7] = mTime[7];
}

if (ledMode == 10){
alarm[0] = mSpecial[0];
alarm[1] = mSpecial[1];
alarm[2] = mSpecial[2];
alarm[3] = mSpecial[3];
alarm[4] = mSpecial[4];
alarm[5] = mSpecial[5];
alarm[6] = mSpecial[6];
alarm[7] = mSpecial[7];
}
  
  
}
