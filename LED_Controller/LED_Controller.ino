//DormLED Controller V4.5 by Cole Rabe 

#include <Adafruit_NeoPixel.h>
#include <EasyColor.h>
#include <Adafruit_TinyUSB.h>

//HSV to RGB Setup
EasyColor::HSVRGB HSVConverter;
//End HSV to RGB Setup
#define PIN 5
#define LEDCOUNT 1093
#define SERIAL_SIZE 32

//LED Status + Modes Variables
int ledMode = 1;
int specialMode = 0;
bool cConnected = false;
uint16_t buffStripBright = 255;
uint16_t stripBright = 255;
uint16_t prevStripBright = 255;
bool ledState = true;
bool timeoutlight = false;
bool hasSet = false;
int ddColor1 = 0;
int ddColor2 = 0;
int ch = 69;
int cs = 70;
int cv = 71;
float cr = 255;
float cg = 255;
float cb = 255;
int fh = 0;
float fr = 255;
float fg = 255;
float fb = 255;
String val;
//End LED Status + Modes Variables

//Parsing Serial Data Variables

const byte serialsize = 32;
char input[SERIAL_SIZE];
char tempInput[SERIAL_SIZE];
char intxt_1[SERIAL_SIZE] = {0};
int inNums[5];
bool newData = false;
//End Parsing Serial Data Variables

//Global Animation Variables
const int FORWARD = 1;
const int REVERSE = -1;
int beamSize = LEDCOUNT/20;
bool ledON = false;
int ledNum = 0;
int beamPos[LEDCOUNT];
unsigned long cMillis = 0;
unsigned long pMillis = 0;
unsigned long rMillis = 0;
bool aOn = false;
bool goingUp = true;
uint16_t brightness = 254;
uint16_t prevBrightness = 1;
int aStep = 0;
int bStep = 0;
bool strobeOn = false;
bool altState = false;
int ledDiv = 15;
bool color = false;
int modeSpeed = 60;
float rStates[LEDCOUNT];
float bStates[LEDCOUNT];
float gStates[LEDCOUNT];
float popHang[LEDCOUNT];
float setPopHang[LEDCOUNT];
uint16_t nextrgb[] = {255,0,0};
float color1[] = {255, 255, 255};
float color2[] = {0, 255, 0};
int pixChosen = 0;
int pColorOption = 0;
int ledStatus[LEDCOUNT];
bool barDirectionA = false;
bool barDirectionB = false;
const int barSize = 30;
int barWidth = 10;
int setBarSize = 0;
int phaserNum = 0;
bool inRamp = false;
int rampStep = 0;
int aMBright = 255;



// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//   NEO_RGBW    Pixels are wired for RGBW bitstream (NeoPixel RGBW products)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(LEDCOUNT, PIN, NEO_GRB + NEO_KHZ800);

// IMPORTANT: To reduce NeoPixel burnout risk, add 1000 uF capacitor across
// pixel power leads, add 300 - 500 Ohm resistor on first pixel's data input
// and minimize distance between Arduino and first pixel.  Avoid connecting
// on a live circuit...if you must, connect GND first.

void setup() {
  strip.begin();
  strip.setBrightness(255);
  strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
  strip.show(); // Initialize all pixels to 'off'
  Serial.begin(115200);
  Serial.println("Setup");
  ledState = false;
  ledMode = 0;
    }

void loop() {
 cMillis = millis();
 inpReceiving();  
 if (newData == true){
  strcpy(tempInput, input);
  parseData();
  inputHandling();
  ledModes();
  clearInputs();
  newData = false;
 }
 else{
 ledModes();
 timeout();
 }
 rampBright();
  if (stripBright != buffStripBright && inRamp == false) {
    stripBright = buffStripBright;
    prevStripBright = buffStripBright;
    hasSet = false;
    }
} 


void inpReceiving(){
  static bool recInProgress = false;
  static byte ndx = 0;
  char startMarker = '<';
  char endMarker = '>';
  
  while (Serial.available() > 0 && newData == false){
    char rc = Serial.read();

    if (recInProgress){
      if (rc != endMarker) {
        input[ndx++] = rc;
        if (ndx >= SERIAL_SIZE){
          ndx = SERIAL_SIZE - 1;
          }
        } 
        else {
          input[ndx] = '\0';
          recInProgress = false;
          ndx = 0;
          newData = true;        
          }
      }
      else if (rc == startMarker){
        recInProgress = true;
       }
    }
}

void parseData(){
  char* strtokIndx = strtok(input, ",<>");
  strcpy(intxt_1, strtokIndx);
  
  for (int i = 0; i < 4; i++) {
    strtokIndx = strtok(NULL, ",<>");
    inNums[i] = atof(strtokIndx);
  }
}



void timeout(){
  if (cConnected == false && timeoutlight == false){
  while (millis() - 50 >= 60000){
  ledMode = 11;
  color1[0] = 255;
  color1[1] = 0;
  color1[2] = 0;
  for (uint16_t i=0;i<LEDCOUNT;i++){
       if (ledNum < beamSize){
           if (ledON == false){
              beamPos[i]=0;  
           }
           else {
              beamPos[i]=1;
           }  
           ledNum++;
       } else if (ledNum >= beamSize){
           ledON = !ledON;
           ledNum = 0;
         }
            }
  ledState = true;
  aOn = true;
  timeoutlight = true;
  Serial.println("Timeout");
  Serial.println('\n');  
  break;
    }
  }
  if (cConnected == false && timeoutlight == true){
    timeoutMode(5);
    } 
}

void inputHandling(){
  if (strcmp(intxt_1, "b") == 0){
    buffStripBright = inNums[0];

    }
  if (strcmp(intxt_1, "c") == 0){
    if (inNums[0] == 0||inNums[0] == 1){
      ch = inNums[1];
      cs = inNums[2];
      cv = inNums[3];
      rgb out_rgb;
      out_rgb.r = 0;
      out_rgb.g = 0;
      out_rgb.b = 0;
      hsv in_hsv;
      in_hsv.h = ch;
      in_hsv.s = cs;
      in_hsv.v = cv;
      out_rgb =  HSVConverter.HSVtoRGB(in_hsv,out_rgb);
      cr = out_rgb.r;
      cg = out_rgb.g;
      cb = out_rgb.b;
      if (inNums[0] == 0){
        color1[0] = cr;
        color1[1] = cg;
        color1[2] = cb;
        }
      else if (inNums[0] == 1){
        color2[0] = cr;
        color2[1] = cg;
        color2[2] = cb;
        }                
      }
     if (inNums[0] == 2){
        ddColor1 = inNums[1];
        }
    else if (inNums[0] == 3){
        ddColor2 = inNums[1];
        }  
    hasSet = false;
    }
  if (strcmp(intxt_1,"m") == 0){
       aOn = false;
       ledMode = inNums[0];
       specialMode = inNums[1];
       hasSet = false;
    }
  if (strcmp(intxt_1, "p") == 0){
    if (inNums[0] == 0){
  for (int i=0; i<strip.numPixels(); i++){
    strip.setPixelColor(i,0);
  }
        strip.show();
        ledState = false;
        Serial.println("off");
      } else if (inNums[0] == 1){
        strip.show();
        ledState = true;
        hasSet = false;
        Serial.println("on");
        }
    }
   if (strcmp(intxt_1,"o") == 0){
    if (inNums[0] == 0){ //Speed
      modeSpeed = inNums[1];
      pMillis = cMillis;
      }
    if (inNums[0] == 1){ //Division
      ledDiv = inNums[1];
      }
    if (inNums[0] == 2){ //Ramp Brightness
      if (inRamp == false){
        rampStep = 0;
        inRamp = true;
        }
      if (inRamp == true){
        rampStep = 0;
        }
      }
    if (inNums[0] == 3){ //Stop Ramp Brightness
        rampStep = 0;
        inRamp = false;
      } 
    if (inNums[0] == 4){ //Set Max Brightness
        aMBright = inNums[1];
      }
    
    }
  if (strcmp(intxt_1, "s") == 0){
    if (inNums[0] == 0){
      Serial.print("Connection State: ");
      Serial.println(cConnected);
      Serial.print("Power: ");
      Serial.println(ledState);
      Serial.print("StripBright: ");
      Serial.println(stripBright);
      Serial.print("Brightness: ");
      Serial.println(brightness);
      Serial.print("PrevBrightness: ");
      Serial.println(prevBrightness);
      Serial.print("goingup: ");
      Serial.println(goingUp);
      Serial.print("Current Mode: ");
      Serial.println(ledMode);
      Serial.print("Special Mode: ");
      Serial.println(specialMode);
      Serial.print("altState:");
      Serial.println(modeSpeed);
      Serial.print("aOn: ");
      Serial.println(aOn);
      Serial.print("aStep: ");
      Serial.println(aStep);
      Serial.print("phaserNum: ");
      Serial.println(phaserNum);
      Serial.print("barDirection: ");
      Serial.println(barDirectionA);
      Serial.print("setBarSize: ");
      Serial.println(setBarSize);
      Serial.print("BuffBrightness: ");
      Serial.println(buffStripBright);
      Serial.print("aMBright: ");
      Serial.println(aMBright);
      Serial.print("inRamp: ");
      Serial.println(inRamp);
      Serial.print("RampStep: ");
      Serial.println(rampStep);
      Serial.println('\n');
      }
    if (inNums[0] == 1) {
      Serial.println("Got Message");
      Serial.println('\n');
      if (cConnected == true){
        Serial.println("nomore");
        Serial.println('\n');
        inRamp = false;
        }
      if (cConnected == false){
        Serial.println("yesconnect");
        Serial.println('\n');
        inRamp = false;
        cConnected = true;
        ledState = true;
     //   strip.setBrightness(stripBright);
        if (timeoutlight == true){
          timeoutlight = false; 
          ledMode = 0;
          aOn = false;
          strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
          strip.show();
          }
        }
      }
    if (inNums[0] == 2){
        if (inNums[1] == 0){
      Serial.println(ch);
      Serial.println('\n');
        }
        
        if (inNums[1] == 1){
      Serial.println(cs);
      Serial.println('\n');
        }
        
        if (inNums[1] == 2){
      Serial.println(cv);
      Serial.println('\n');
        }
      }
    if (inNums[0] == 3){
        if (inNums[1] == 0){
      Serial.flush();
      Serial.println(ledState);
      Serial.println('\n');
      Serial.flush();
        }
        
        if (inNums[1] == 1){
      Serial.flush();
      Serial.println(stripBright);
      Serial.println('\n');
      Serial.flush();
        }
        if (inNums[1] == 2){
      Serial.flush();
      Serial.println(ledMode);
      Serial.println('\n');
      Serial.flush();
        }
        if (inNums[1] == 3){
      Serial.flush();
      Serial.println(ledDiv);
      Serial.println('\n');
      Serial.flush();
        }  
        if (inNums[1] == 4){
      Serial.flush();
      Serial.println(specialMode);
      Serial.println('\n');
      Serial.flush();
        }
        if (inNums[1] == 5){
      Serial.flush();
      Serial.println(modeSpeed);
      Serial.println('\n');
      Serial.flush();
        }  
       if (inNums[1] == 6){
      Serial.flush();
      Serial.println(ddColor1);
      Serial.println('\n');
      Serial.flush();
        }
        if (inNums[1] == 7){
      Serial.flush();
      Serial.println(ddColor2);
      Serial.println('\n');
      Serial.flush();
        }          
      }
    }     
  }

void rampBright(){
  if (inRamp == true && rampStep < aMBright){
    if ((cMillis - rMillis) >= 100){
    stripBright = rampStep;
    rampStep++;
    rMillis = cMillis;
    }
  }
  }


//Clear Inputs
void clearInputs(){
//  intxt_1 = '\0';
  }

//~~LED MODE HANDLING~~
void ledModes(){
  if (ledMode == 1){//Rainbow
    if (aOn == false){
      aOn = true;
      pMillis = -1000;
      }
    rainbowCycle(modeSpeed);//Default 20
    }
  if (ledMode == 2 && hasSet == false && ledState == true){//Color
    strip.fill(strip.Color(stripBright*(color1[0]/255),stripBright*(color1[1]/255),stripBright*(color1[2]/255)),0,LEDCOUNT);
    strip.show();
    hasSet = true;
    }
  if (ledMode == 3){//Fade
    if (aOn == false){
      aOn = true;
      pMillis = -1000;
      }
    fade(modeSpeed); //Default 100
    }
      if (ledMode == 4){//Alternating Colors
        if (aOn == false){
          aOn = true;
          altState=false;
          color = false;
          strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
          pMillis = -1000;
      }
    alternatingColors(modeSpeed);//Default 300
    }
      if (ledMode == 5){//Pulse
          if (aOn == false){
           aOn = true;
           pMillis = -1000;
           for (int i=0;i<LEDCOUNT;i++){
            ledStatus[i] = 0;
            beamPos[i] = 0;
            }
      }
    pulse(modeSpeed, 5);//Default 50 pulse(modeSpeed,numPulseBars).
    }
      if (ledMode == 6){//Breathe
         if (aOn == false){
           aOn = true;
           brightness = stripBright;  
           pMillis = -1000;
      }  
    breathe(modeSpeed);//Default 30
    }
      if (ledMode == 7){//Strobe
        if (aOn == false){
          aOn = true;
          pMillis = -1000;
      }
    strobe(modeSpeed);//Default 40
    }
      if (ledMode == 8){//Paint
          if (aOn == false){
           aOn = true;
           pMillis = -1000;
      for(uint16_t i = 0; i < LEDCOUNT; i++) {
        rStates[i] = 0;
        gStates[i] = 0;
        bStates[i] = 0;
      }
      pixChosen = 0;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
      }
    paint(modeSpeed);//Default 120
    }
      if (ledMode == 9){//Weather
        if (aOn == false){
      aOn = true;
      pMillis = -1000;
      }
//Weather
    }
      if (ledMode == 10){//Special
        if (specialMode == 0){
           strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
           strip.show();
          }
        if(specialMode == 2){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(2);
      }
    cylon(modeSpeed);//Default 60
          }
       if(specialMode == 3){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(3);
      }
    phaser(modeSpeed);//Default 60
          }
       if(specialMode == 4){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            phaserNum = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            barDirectionB = false;
            setBarSize = 0;
            Serial.println(4);
      }
    aphaser(modeSpeed);//Default 60
          }
       if(specialMode == 5){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(5);
      }
    //weather(modeSpeed);//Default 60
          }
       if(specialMode == 6){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            altState=false;
            Serial.println(6);
      }
       pLights(modeSpeed);//Default 60
          }
       if(specialMode == 7){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(7);
      }
            fire(modeSpeed);//Default 60
          }
       if(specialMode == 8){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(8);
      }
   // Bouncing Ball(modeSpeed);//Default 60
          }
       if(specialMode == 9){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            /*for (int i=0;i<=LEDCOUNT;i++){
              ledStatus[i] = 50;
              setPopHang[i] = 50;
              popHang[i]=0;
              rStates[i] = 0;
              bStates[i] = 0;
              gStates[i] = 0;
            }*/
            memset(ledStatus,0,sizeof(ledStatus));
            memset(setPopHang,0,sizeof(setPopHang));
            memset(popHang,0,sizeof(popHang));
            memset(rStates,0,sizeof(rStates));
            memset(gStates,0,sizeof(gStates));
            memset(bStates,0,sizeof(bStates));
            Serial.println(9);
      }
            twinkle(modeSpeed);//Default 60
          }
       if(specialMode == 10){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
           strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
//            strip.fill(strip.Color(stripBright*(color1[0]/255),stripBright*(color1[1]/255),stripBright*(color1[2]/255)),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
              ledStatus[i] = 50;
              setPopHang[i] = 50;
              popHang[i]=0;
              rStates[i] = 0;
              bStates[i] = 0;
              gStates[i] = 0;
            }*/
            memset(ledStatus,0,sizeof(ledStatus));
            memset(setPopHang,0,sizeof(setPopHang));
            memset(popHang,0,sizeof(popHang));
            memset(rStates,0,sizeof(rStates));
            memset(gStates,0,sizeof(gStates));
            memset(bStates,0,sizeof(bStates));
            Serial.println(10);
      }
            sparkle(modeSpeed);//Default 60
          }
       if(specialMode == 11){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 0;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            Serial.println(11);
            }
            rLights(modeSpeed);//Default 60
          }
       if(specialMode == 12){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 1;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(12);
            }
            tchase (modeSpeed);//Default 60
       }
       if(specialMode == 13){
           if (aOn == false){
           aOn = true;
           pMillis = -1000;
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
            aStep = 1;
            /*for (int i=0;i<=LEDCOUNT;i++){
            ledStatus[i]=0;
            }*/
            memset(ledStatus, 0, sizeof(ledStatus));
            barDirectionA = false;
            setBarSize = 0;
            Serial.println(13);
      }
   // Meteor(modeSpeed);//Default 60
          }
       if(specialMode == 14){ //Pop
           if (aOn == false){
             aOn = true;
             pMillis = -1000;
             for(uint16_t i = 0; i < LEDCOUNT; i++) {
             rStates[i] = 0;
             gStates[i] = 0;
             bStates[i] = 0;
  }
            strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
            strip.show();
      }
    pop(modeSpeed);//Default 50
          }
  }
  //Timeout
      if (ledMode == 11){
       if (aOn == false){
          // goingUp = false;
            for (int i=0;i<LEDCOUNT;i++){
              beamPos[i]=1;  
       if (ledNum < beamSize){
           if (ledON == false){
              beamPos[i]=1;  
           }
           else {
              beamPos[i]=1;
           }  
           ledNum++;
       } else if (ledNum >= beamSize){
           ledON = !ledON;
           ledNum = 0;
         }
            }
            aOn = true;
           brightness = 255;  
           pMillis = -1000;
      }  
      timeoutMode(20);
      }
}





// Fill the dots one after the other with a color
void colorWipe(uint32_t c, uint8_t freq) {
  uint16_t wait;
  wait = (1000/freq)/2;
  for(uint16_t i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
    strip.show();
    delay(wait);
  }
}

// Slightly different, this makes the rainbow equally distributed throughout
void rainbowCycle(unsigned long freq) {
  uint16_t wait;
  wait = (1000/freq)/2;
  uint16_t i;
  if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
  pMillis = cMillis;
  if(aStep<256){
    for(i=0; i< strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel(((i * 256 / strip.numPixels()) + aStep) & 255));
    }
    strip.show();
    aStep++;
    } 
  }
  if(aStep >= 256) {
      aStep = 0;
      }
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if(WheelPos < 85) {
    return strip.Color(stripBright*(255 - WheelPos * 3)/255, 0, stripBright*(WheelPos * 3)/255);
  }
  if(WheelPos < 170) {
    WheelPos -= 85;
    return strip.Color(0, stripBright*(WheelPos * 3)/255, stripBright*(255 - WheelPos * 3)/255);
  }
  WheelPos -= 170;
  return strip.Color(stripBright*(WheelPos * 3)/255, stripBright*(255 - WheelPos * 3)/255, 0);
}

void fade(unsigned long freq) {
  uint16_t wait;
  wait = (1000/freq)/2;
  if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
  pMillis = cMillis;
  if(aStep<360){

      fh = aStep;
      rgb out_rgb;
      out_rgb.r = 0;
      out_rgb.g = 0;
      out_rgb.b = 0;
      hsv in_hsv;
      in_hsv.h = fh;
      in_hsv.s = 100;
      in_hsv.v = 100;
      out_rgb =  HSVConverter.HSVtoRGB(in_hsv,out_rgb);
      fr = out_rgb.r;
      fg = out_rgb.g;
      fb = out_rgb.b;
      strip.fill(strip.Color(stripBright*(fr/255),stripBright*(fg/255),stripBright*(fb/255)),0,LEDCOUNT);
    }
    strip.show();
    aStep++;
    } 
  if(aStep >= 360) {
      aStep = 0;
      }
}

void breathe(unsigned long freq) {
  long cwait = ((1000 / freq) / 2) * (255 / stripBright);
  
  if ((aOn == true) && (ledState == true) && (brightness < stripBright) && (prevBrightness != brightness) && (cMillis - pMillis >= cwait)) {
    prevBrightness = brightness;
    strip.fill(strip.Color(brightness * (color1[0] / 255), brightness * (color1[1] / 255), brightness * (color1[2] / 255)), 0, LEDCOUNT);
    strip.show();
    if (goingUp == true) {
      brightness++;
    } else {
      brightness--;
    }
    if (brightness >= stripBright) {
      goingUp = false;
    }
    if (brightness <= 0) {
      goingUp = true;
    }
    pMillis = cMillis;
  } else if ((aOn == true) && (ledState == true) && (brightness >= stripBright) && (cMillis - pMillis >= (1000 / (2 * (brightness - stripBright))))) {
    strip.fill(strip.Color(brightness * (color1[0] / 255), brightness * (color1[1] / 255), brightness * (color1[2] / 255)), 0, LEDCOUNT);
    strip.show();
    if (brightness == stripBright) {
      prevBrightness = brightness;
    }
    goingUp = false;
    if (goingUp == false) {
      brightness--;
    }
    pMillis = cMillis;
  }
}


void strobe(unsigned long freq){
  static bool strobeOn = false;
  static unsigned long lastToggleMillis = 0;
  uint16_t wait = (1000/freq)/2;
  
  if ((cMillis - lastToggleMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
    if (strobeOn){
      strip.fill(strip.Color(0, 0, 0), 0, LEDCOUNT);
    } else {
      strip.fill(strip.Color(stripBright*(color1[0]/255), stripBright*(color1[1]/255), stripBright*(color1[2]/255)), 0, LEDCOUNT);
    }
    strobeOn = !strobeOn;
    strip.show();
    lastToggleMillis = cMillis;
  }
}


void alternatingColors(unsigned long freq) {
  uint16_t wait = (500 / freq);
  if (cMillis - pMillis >= wait && aOn && ledState) {
    const int chunkSize = LEDCOUNT / ledDiv;
    const int numChunks = ledDiv;

    for (int i = 0; i < numChunks; i++) {
      int start = i * chunkSize;
      int end = start + chunkSize;

      for (int j = start; j < end; j++) {
        if ((i & 1) == altState) {
          strip.setPixelColor(j, strip.Color(stripBright * color1[0] / 255,
                                              stripBright * color1[1] / 255,
                                              stripBright * color1[2] / 255));
        } else {
          strip.setPixelColor(j, strip.Color(stripBright * color2[0] / 255,
                                              stripBright * color2[1] / 255,
                                              stripBright * color2[2] / 255));
        }
      }
    }
    strip.show();
    altState = !altState;
    pMillis = cMillis;
  }
}


//void pulse(unsigned long freq, int pulseBars[][8], int numPulseBars, int wait){
//  if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
//    for (int i = 0; i < numPulseBars; i++) {
//      if (pixChosen == i) {
//        pulseBars[i][0] = random (0,1);
//        pulseBars[i][1] = random (1,6);
//        pulseBars[i][2] = (stripBright*(color1[0]/255));
//        pulseBars[i][3] = (stripBright*(color1[1]/255));
//        pulseBars[i][4] = (stripBright*(color1[2]/255));
//        pulseBars[i][5] = 72;
//        pulseBars[i][6] = random (0,8);
//        pulseBars[i][7] = 0;
//        pixChosen++;
//      }
//    }
//    if (pixChosen >= numPulseBars){
//      for (int i = 0; i < numPulseBars; i++) {
//        if (pulseBars[i][7] == pulseBars[i][6]){
//          if(pulseBars[i][5] == 0 || pulseBars[i][5] == LEDCOUNT){
//            if (pulseBars[i][0] == 0){
//              pulseBars[i][5] = pulseBars[i][5]+pulseBars[i][1]+1;
//              pulseBars[i][0] = 1;
//            }
//            else{
//              pulseBars[i][5] = pulseBars[i][5]-pulseBars[i][1]-1;
//              pulseBars[i][0] = 0;
//            }
//          }
//          
//          ledStatus[int(pulseBars[i][5])] = 1;
//          if (pulseBars[i][0] == 1){
//            ledStatus[int(pulseBars[i][5])-int(pulseBars[i][1])] = 0;
//            pulseBars[i][5]++;
//          }
//          else{
//            ledStatus[int(pulseBars[i][5])+int(pulseBars[i][1])] = 0;
//            pulseBars[i][5]--;
//          }
//          pulseBars[i][7] = 0;
//        }
//        else{
//          pulseBars[i][7]++;
//        }
//      }
//    }
//  }
//}

void pulse(unsigned long freq, int numPulseBars) {
    long cwait = ((1000/freq)/2);
  if (prevBrightness != brightness && (cMillis - pMillis >= cwait) && (aOn == true) && (ledState == true) && (freq > 0)){
  prevBrightness = brightness;
  for (int i=0;i<LEDCOUNT;i++){
    if (beamPos[i]==1){
          strip.setPixelColor(i,brightness*(color1[0]/255),brightness*(color1[1]/255),brightness*(color1[2]/255));
     //     strip.setPixelColor(i,255,0,0);
    } if (beamPos[i]==0){
      strip.setPixelColor(i,0,0,0);
      }
    }
  strip.show();
  if (goingUp == true){
  brightness++;
    } else if (goingUp == false) {
      brightness--;
    }
      if (brightness >= stripBright){
    goingUp = false;
      }
      if (brightness <= 0){
    goingUp = true;
      }
      if (aStep < beamSize){
        for (int i=1;i<LEDCOUNT;i++){
          if (beamPos[i]==0 && beamPos[i+1]==1){
            beamPos[i]=1;
            }
          if (beamPos[i]==1 && beamPos[i+1]==0){
            beamPos[i]=0;
            }  
          }
        if (beamPos[beamSize]==0 && beamPos[LEDCOUNT-beamSize]==0){
            beamPos[LEDCOUNT]=1;
            }
        if (beamPos[LEDCOUNT-beamSize]==1){
            beamPos[LEDCOUNT]=0;
            }
  
        aStep++;
      if (aStep >= beamSize){
        aStep = 0;
        }
        }
    pMillis = cMillis;
  }
}



void pop(unsigned long speed){
  unsigned long freq = map(speed,1,100,300,1);
  if ((cMillis-pMillis) >= 10 && aOn && ledState){  
    if (random(freq)==1){
      uint16_t pix = random(LEDCOUNT);
      if (rStates[pix] < 1 && gStates[pix] < 1 && bStates[pix] < 1){
        rStates[pix] = (stripBright*(color2[0]/255));
        gStates[pix] = (stripBright*(color2[1]/255));
        bStates[pix] = (stripBright*(color2[2]/255));
      }
    }
    for(uint16_t i = 0; i < LEDCOUNT; i++) {
      if (rStates[i] > 1 || gStates[i] > 1 || bStates[i] > 1) {
        strip.setPixelColor(i, rStates[i], gStates[i], bStates[i]);

        if(popHang[i] >= 200){
          rStates[i] = (rStates[i] * 99) / 100;
          gStates[i] = (gStates[i] * 99) / 100;
          bStates[i] = (bStates[i] * 99) / 100;
        } else {
          popHang[i]++;
        }
      } else {
        strip.setPixelColor(i, (stripBright*(color1[0]/255))/10, (stripBright*(color1[1]/255))/10, (stripBright*(color1[2]/255))/10);
      }
    }
    strip.show();
    pMillis = cMillis;
  }
}


 void paint(unsigned long freq) {
  uint16_t wait = (1000/freq)/100;
  uint16_t pix;
  if (((cMillis-pMillis) >= wait) && (aOn == true) && (ledState == true) && (freq > 0)) {
    if (random(75)<=15) {
      pix = random(LEDCOUNT);
      if ((rStates[pix] != nextrgb[0]) || (gStates[pix] != nextrgb[1]) || (bStates[pix] != nextrgb[2])) {
        rStates[pix] = nextrgb[0];
        gStates[pix] = nextrgb[1];
        bStates[pix] = nextrgb[2];
        strip.setPixelColor(pix, rStates[pix], gStates[pix], bStates[pix]);
        strip.show();
        Serial.println("Chosen");
        pixChosen++;
        Serial.print("Pixels Left: ");
        Serial.println(LEDCOUNT-pixChosen);
      }
    }
    if (pixChosen >= (LEDCOUNT)) {
      Serial.println("Already Set");
      
      uint16_t colorOption = random(0, 7);
      while (colorOption == pColorOption){
        colorOption = random(7);
      }
      pColorOption = colorOption;
      
      for(uint16_t i = 0; i < LEDCOUNT; i++) {
        rStates[i] = 0;
        gStates[i] = 0;
        bStates[i] = 0;
      }
      
      Serial.print("Chosen Option: ");
      Serial.println(colorOption);
      pixChosen = 0;
      
      switch (colorOption) {
        case 0:
          nextrgb[0] = 255;
          nextrgb[1] = 0;
          nextrgb[2] = 0;
          break;
        case 1:
          nextrgb[0] = 255;
          nextrgb[1] = 165;
          nextrgb[2] = 0;
          break;
        case 2:
          nextrgb[0] = 255;
          nextrgb[1] = 255;
          nextrgb[2] = 0;
          break;
        case 3:
          nextrgb[0] = 0;
          nextrgb[1] = 255;
          nextrgb[2] = 0;
          break;
        case 4:
          nextrgb[0] = 0;
          nextrgb[1] = 0;
          nextrgb[2] = 255;
          break;
        case 5:
          nextrgb[0] = 255;
          nextrgb[1] = 0;
          nextrgb[2] = 255;
          break;
        case 6:
          nextrgb[0] = 255;
          nextrgb[1] = 102;
          nextrgb[2] = 178;
        break;
        case 7:
          nextrgb[0] = 102;
          nextrgb[1] = 255;
          nextrgb[2] = 255;
        break;
        default:
        break;
  }
}

pMillis = cMillis;
    }
   }
void cylon(unsigned long freq) {
  static uint32_t lastMillis = 0;
  uint32_t currentMillis = millis();
  uint32_t waitMillis = 1000 / freq;

  if ((currentMillis - lastMillis) < waitMillis) {
    return;
  }

  lastMillis = currentMillis;

  if (aOn && ledState && freq > 0) {
    if (barDirectionA) {
      if (aStep + barSize >= LEDCOUNT) {
        barDirectionA = false;
        aStep = LEDCOUNT - barSize;
      } else {
        aStep++;
      }
    } else {
      if (aStep == 0) {
        barDirectionA = true;
      } else {
        aStep--;
      }
    }

    for (int i = 0; i < LEDCOUNT; i++) {
      if (i >= aStep && i < aStep + barSize) {
        strip.setPixelColor(i, stripBright * strip.Color(
            (barDirectionA ? color1[0] : color2[0]) / 255,
            (barDirectionA ? color1[1] : color2[1]) / 255,
            (barDirectionA ? color1[2] : color2[2]) / 255
          )
        );
        ledStatus[i] = 1;
      } else {
        strip.setPixelColor(i, 0);
        ledStatus[i] = 0;
      }
    }

    strip.show();
  }
}





     void phaser(unsigned long freq){
    uint16_t wait = (1000/freq);
    if ((barDirectionA == false) && (ledStatus[aStep]==0)&&(setBarSize<=barSize)&&((cMillis-pMillis) >= (wait)) && (aOn == true) && (ledState == true) && (freq > 0)){
      strip.setPixelColor(aStep,strip.Color(stripBright*(color1[0]/255),stripBright*(color1[1]/255),stripBright*(color1[2]/255)));
      strip.show();
      ledStatus[aStep]=1;
      setBarSize++;
      aStep++;
      pMillis = cMillis; 
      } 
    if ((barDirectionA == false) && (ledStatus[aStep]==0)&&(setBarSize>=barSize)&&(aStep <= LEDCOUNT)&&((cMillis-pMillis) >= (wait)) && (aOn == true) && (ledState == true) && (freq > 0)){
      strip.setPixelColor(aStep,strip.Color(stripBright*(color1[0]/255),stripBright*(color1[1]/255),stripBright*(color1[2]/255)));
      strip.setPixelColor((aStep-barSize-1),strip.Color(0,0,0));
      ledStatus[aStep-barSize-1]=0;
      strip.show();
      ledStatus[aStep]=1;
      if (aStep == LEDCOUNT){
        barDirectionA = true;
        aStep = (aStep-barSize);
        }
      else {
        aStep++;
        }  
      pMillis = cMillis; 
      }
    if ((barDirectionA == true) && (ledStatus[aStep]==1)&&(aStep <= LEDCOUNT)&&((cMillis-pMillis) >= (wait)) && (aOn == true) && (ledState == true) && (freq > 0)){
      strip.setPixelColor(aStep,strip.Color(0,0,0));
      strip.show();
      setBarSize--;
      ledStatus[aStep]=0;
    if (aStep == LEDCOUNT){
      barDirectionA = false;
      aStep = 0;
       } 
    else {
        aStep++;
        }  
       pMillis = cMillis; 
    }
  }

void aphaser(unsigned long freq) {
  uint16_t wait = (1000 / freq);
  
  // Update bar positions
  if ((cMillis - pMillis) >= wait) {
    // Move bars in opposite directions
    if (barDirectionA == FORWARD) {
      aStep++;
      if (aStep >= LEDCOUNT) {
        barDirectionA = REVERSE;
        aStep = LEDCOUNT - 1;
      }
    } else {
      aStep--;
      if (aStep < 0) {
        barDirectionA = FORWARD;
        aStep = 0;
      }
    }
    
    if (barDirectionB == FORWARD) {
      bStep++;
      if (bStep >= LEDCOUNT) {
        barDirectionB = REVERSE;
        bStep = LEDCOUNT - 1;
      }
    } else {
      bStep--;
      if (bStep < 0) {
        barDirectionB = FORWARD;
        bStep = 0;
      }
    }
    
    // Update colors
    for (int i = 0; i < LEDCOUNT; i++) {
      // Calculate color for bar A
      uint8_t rA = 0, gA = 0, bA = 0;
      if (i >= aStep - barSize && i <= aStep) {
        uint8_t blend = map(i, aStep - barSize, aStep, 0, 255);
        rA = ((stripBright * color1[0] / 255) * blend + (stripBright * color2[0] / 255) * (255 - blend)) / 255;
        gA = ((stripBright * color1[1] / 255) * blend + (stripBright * color2[1] / 255) * (255 - blend)) / 255;
        bA = ((stripBright * color1[2] / 255) * blend + (stripBright * color2[2] / 255) * (255 - blend)) / 255;
      }
      
      // Calculate color for bar B
      uint8_t rB = 0, gB = 0, bB = 0;
      if (i >= bStep && i <= bStep + barSize) {
        uint8_t blend = map(i, bStep, bStep + barSize, 0, 255);
        rB = ((stripBright * color2[0] / 255) * blend + (stripBright * color1[0] / 255) * (255 - blend)) / 255;
        gB = ((stripBright * color2[1] / 255) * blend + (stripBright * color1[1] / 255) * (255 - blend)) / 255;
        bB = ((stripBright * color2[2] / 255) * blend + (stripBright * color1[2] / 255) * (255 - blend)) / 255;
      }
      
      // Combine colors for overlapping pixels
      if (i >= aStep && i <= bStep) {
        uint8_t blend = map(i, aStep, bStep, 0, 255);
        uint8_t r = ((rA * blend) + (rB * (255 - blend))) / 255;
        uint8_t g = ((gA * blend) + (gB * (255 - blend))) / 255;
        uint8_t b = ((bA * blend) + (bB * (255 - blend))) / 255;
strip.setPixelColor(i, r, g, b);
} else if (i <= aStep) {
strip.setPixelColor(i, rA, gA, bA);
} else {
strip.setPixelColor(i, rB, gB, bB);
}
}
// Show updated strip
strip.show();

// Update previous millis
pMillis = cMillis;
}
}


  void pLights(unsigned long freq){
    uint16_t wait;
    wait = (1000/freq)/2;
   if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (altState == false) && (freq <=10)){
        strip.fill(strip.Color(255,0,0),(LEDCOUNT/2),LEDCOUNT);
        strip.fill(strip.Color(0,0,0),0,(LEDCOUNT/2));
        strip.show();
        altState = true;
        pMillis = cMillis;
    }
    if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (altState == true) && (freq <=10)){
        strip.fill(strip.Color(0,0,255),0,(LEDCOUNT/2));
        strip.fill(strip.Color(0,0,0),(LEDCOUNT/2),LEDCOUNT);
        strip.show();
        altState = false;
        pMillis = cMillis;
    }
    if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (altState == false) && (freq >10)){
        if ((aStep == 0)||(aStep == 2)||(aStep == 4)||(aStep == 6)||(aStep == 8)){
        strip.fill(strip.Color(255,0,0),(LEDCOUNT/2),LEDCOUNT);
        strip.show();
        }
        
        if ((aStep == 1)||(aStep == 3)||(aStep == 5)||(aStep == 7)||(aStep == 9)){
        strip.fill(strip.Color(0,0,0),(LEDCOUNT/2),LEDCOUNT);
        strip.show();
        }        
        if (aStep >= 9){
          altState = true;
          }
          else {
          aStep++;    
            }
        pMillis = cMillis;
    }
    if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true)&&(altState == true) && (freq >10)){
        if ((aStep == 0)||(aStep == 2)||(aStep == 4)||(aStep == 6)||(aStep == 8)){
        strip.fill(strip.Color(0,0,255),0,(LEDCOUNT/2));
        strip.show();
        }
        if ((aStep == 1)||(aStep == 3)||(aStep == 5)||(aStep == 7)||(aStep == 9)){
        strip.fill(strip.Color(0,0,0),0,(LEDCOUNT/2));
        strip.show();
        }
        if (aStep <= 0){
          altState = false;
          }
          else {
          aStep--;    
            }
        pMillis = cMillis;
    }
}

  void tchase(unsigned long freq){
    uint16_t wait;
    int dotSpacing = 12;
    wait = (1000/freq);
    if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
        if(aStep < dotSpacing){
          aStep++;
          }
        else if (aStep >= dotSpacing){
          aStep = 1;
          }
       for (int i=0; i<=LEDCOUNT;i++){
        if ((i + aStep) % dotSpacing == 0){
          strip.setPixelColor(i,strip.Color(stripBright*(color2[0]/255),stripBright*(color2[1]/255),stripBright*(color2[2]/255)));
          }
          else{
          strip.setPixelColor(i,strip.Color(0,0,0));
            
            }
        }
        strip.show();
        pMillis = cMillis; 
}
  }

  void rLights(unsigned long freq){
    uint16_t wait;
    int barSize = 3;
    int spacingSize = 12;
    int index = 0;
    wait = (1000/freq);
    int offsetNum = 0;
    if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
       if(aStep < spacingSize){
          aStep++;
          }
        else if (aStep >= spacingSize){
          aStep = 0;
          }
       index = 0;   
       strip.fill(strip.Color(0,0,0),0,LEDCOUNT);
       for (int i=0; i<=LEDCOUNT;i++){
        if ((index <= (barSize-1)) && (index <=spacingSize)){
          strip.setPixelColor(i+aStep,strip.Color(stripBright*(color1[0]/255),stripBright*(color1[1]/255),stripBright*(color1[2]/255)));
          index++;
          }
          else if ((index >= barSize) && (index <=(spacingSize+1))){
          strip.setPixelColor(i+aStep,strip.Color(0,0,0));
          index++;
            }
          if ((index > barSize) && (index > spacingSize)){
            index = 0;
            }  
        }
        strip.show();
        pMillis = cMillis; 
  }
}

  void fire(unsigned long freq){
    uint16_t wait;
    int barSize = 3;
    int spacingSize = 12;
    int index = 0;
    wait = (1000/freq);
    int offsetNum = 0;
    if ((cMillis - pMillis >= random(150,275)) && (aOn == true) && (ledState == true)){
        for (int i=0;i < LEDCOUNT; i++){
               int flicker = random(0, 150);
               int r1 = 255 - flicker;
               int g1 = 150 - flicker;
               int b1 = 40 - flicker;
               if (g1 < 0) g1 = 0;
               if (r1 < 0) r1 = 0;
               if (b1 < 0) b1 = 0;
    strip.setPixelColor(i, r1, g1, b1);
          
          }
        strip.show();
        pMillis = cMillis; 
  }
}
//End LED Mode Handling

void twinkle (unsigned long speed){
  unsigned long freq = map(speed,1,100,300,1);
  if ((cMillis-pMillis) >= 20 && (aOn == true) && (ledState == true)){  
   if (random(freq)==1){
    uint16_t pix = random(LEDCOUNT);
      if ((ledStatus[pix]==0) && (speed > 0)){
        rStates[pix] = color1[0];
        gStates[pix] = color1[1];
        bStates[pix] = color1[2];
        ledStatus[pix] = 1;
        setPopHang[pix] = random(0,20);
        }
      } 
      for (int i=0;i<LEDCOUNT;i++){
        if ((ledStatus[i]>=100) && (popHang[i] <= setPopHang[i])){
          popHang[i]++;
          }
        if ((ledStatus[i]>0) && (ledStatus[i]<=100)){
          int correctedbrightness = map(ledStatus[i],1,100,1,255);
          strip.setPixelColor(i,stripBright*(((rStates[i]/255)*correctedbrightness)/255),stripBright*(((gStates[i]/255)*correctedbrightness)/255),stripBright*(((bStates[i]/255)*correctedbrightness))/255);
          ledStatus[i]++;
          }
        if ((ledStatus[i] > 100) && (ledStatus[i] < 200) && (popHang[i]>=setPopHang[i])){
          int correctedbrightness = map(ledStatus[i],101,200,255,1);
          strip.setPixelColor(i,stripBright*(((rStates[i]/255)*correctedbrightness)/255),stripBright*(((gStates[i]/255)*correctedbrightness)/255),stripBright*(((bStates[i]/255)*correctedbrightness))/255);
          ledStatus[i]++;
          }
        if ((ledStatus[i] >= 200)){
          strip.setPixelColor(i,0,0,0);
          ledStatus[i] = 0;
          popHang[i] = 0;
          setPopHang[i] = 0;
          rStates[i] = 0;
          gStates[i] = 0;
          bStates[i] = 0;
          }  
      }
      strip.show();  
      pMillis = cMillis; 
      }
  }

  void sparkle (unsigned long freq){
    uint16_t wait;
    int dotSpacing = 12;
    wait = (1000/freq);
     if ((cMillis - pMillis >= wait) && (aOn == true) && (ledState == true) && (freq > 0)){
       for (int i=0; i<=LEDCOUNT;i++){
        if (i % dotSpacing == 0){
      if ((ledStatus[i] == setPopHang[i])){
        popHang[i] = setPopHang[i];
        while ((setPopHang[i] >= popHang[i]-40)&&(setPopHang[i] <= popHang[i]+40)){
        setPopHang[i] = random(0,100);
        }
      }
      
      if ((ledStatus[i] > setPopHang[i])){
          ledStatus[i]--;
          int correctedbrightness = map(ledStatus[i],0,100,0,255);
          strip.setPixelColor(i,stripBright*(((color1[0]/255)*correctedbrightness)/255),stripBright*(((color1[1]/255)*correctedbrightness)/255),stripBright*(((color1[2]/255)*correctedbrightness))/255);
          strip.show();
          }  
      if ((ledStatus[i] < setPopHang[i])){
          ledStatus[i]++;
          int correctedbrightness = map(ledStatus[i],0,100,0,255);
          strip.setPixelColor(i,stripBright*(((color1[0]/255)*correctedbrightness)/255),stripBright*(((color1[1]/255)*correctedbrightness)/255),stripBright*(((color1[2]/255)*correctedbrightness))/255);
          strip.show();
          }            
      }
      }
      pMillis = cMillis; 
      }
  }

  void timeoutMode (unsigned long freq){
      long cwait = ((1000/freq)/2);
  if (prevBrightness != brightness && (cMillis - pMillis >= cwait) && (aOn == true) && (ledState == true) && (freq > 0)){
  prevBrightness = brightness;
  for (int i=0;i<LEDCOUNT;i++){
    if (beamPos[i]==1){
          strip.setPixelColor(i,brightness*(color1[0]/255),brightness*(color1[1]/255),brightness*(color1[2]/255));
     //     strip.setPixelColor(i,255,0,0);
    } if (beamPos[i]==0){
      strip.setPixelColor(i,0,0,0);
      }
    }
  strip.show();
  if (goingUp == true){
  brightness++;
    } else if (goingUp == false) {
      brightness--;
    }
      if (brightness >= stripBright){
    goingUp = false;
      }
      if (brightness <= 0){
    goingUp = true;
      }
      if (aStep < beamSize){
        for (int i=1;i<LEDCOUNT;i++){
          if (beamPos[i]==0 && beamPos[i+1]==1){
            beamPos[i]=1;
            }
          if (beamPos[i]==1 && beamPos[i+1]==0){
            beamPos[i]=0;
            }  
          }
        if (beamPos[beamSize]==0 && beamPos[LEDCOUNT-beamSize]==0){
            beamPos[LEDCOUNT]=1;
            }
        if (beamPos[LEDCOUNT-beamSize]==1){
            beamPos[LEDCOUNT]=0;
            }
  
        aStep++;
      if (aStep >= beamSize){
        aStep = 0;
        }
        }
    pMillis = cMillis;
  }
  }
