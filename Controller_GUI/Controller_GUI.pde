//LED Controller Interface V5 by Cole Rabe
import controlP5.*;
import processing.serial.*;

//Setup Variables
ControlP5 cp5;
//Serial port;
//String cPort = Serial.list()[0];

void setup(){
  background(20);
  surface.setResizable(true);
  surface.setLocation(0,0);
  surface.setSize(displayWidth,displayHeight);
  colorMode(HSB);
  cp5 = new ControlP5(this);
  buttons();
}
void draw(){
  background(30);
}
void buttons(){
   cp5.addButton("pOnButton")
    .setPosition(width-100, 100)
    .setImages(loadImage("Power_On_Button.png"),loadImage("Power_Button_H.png"),loadImage("Power_Off_Button.png"))
    .updateSize();
  
  cp5.addButton("pOffButton")
    .setPosition(1620, 10)
    .setImages(loadImage("Power_Off_Button.png"),loadImage("Power_Button_H.png"),loadImage("Power_On_Button.png"))
    .updateSize();
}
