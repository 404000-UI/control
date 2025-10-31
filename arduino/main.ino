#include <SoftwareSerial.h>

#define BT_RXD 2
#define BT_TXD 3
SoftwareSerial hc06 = SoftwareSerial(BT_RXD, BT_TXD);

void checkMessage() {
  if (hc06.available()) {
    switch (hc06.read()) {
      case 'f':
        Serial.write("forward\n");
        break;
      case 'r':
        Serial.write("rightward\n");
        break;
      case 'l':
        Serial.write("leftward\n");
        break;
      case 'b':
        Serial.write("backward\n");
        break;
      case 'c':
        Serial.write("stop\n");
    }
  }

  if (Serial.available()) {
    hc06.write(Serial.read());
  }
}

void setup() {
  Serial.begin(9600);
  hc06.begin(9600);
}

void loop() {
  checkMessage();
}