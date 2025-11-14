#include <SoftwareSerial.h>
#include <AFMotor.h>

#define BT_RXD 2
#define BT_TXD 3
AF_DCMotor motor_L(1);
AF_DCMotor motor_R(4);
SoftwareSerial hc06 = SoftwareSerial(BT_RXD, BT_TXD);
char mode = 0;

void goForward() {
  motor_L.run(FORWARD);
  motor_R.run(BACKWARD);
}

void goRightward() {
  motor_L.run(FORWARD);
  motor_R.run(FORWARD);
}

void goLeftward() {
  motor_L.run(BACKWARD);
  motor_R.run(BACKWARD);
}

void goBackward() {
  motor_L.run(BACKWARD);
  motor_R.run(FORWARD);
}

void stop() {
  motor_L.run(RELEASE);
  motor_R.run(RELEASE);
}

void checkMessage() {
  if (hc06.available()) {
    char cmd = hc06.read();
    switch (cmd) {
      case 'f':
        goForward();
        break;
      case 'r':
        goRightward();
        break;
      case 'l':
        goLeftward();
        break;
      case 'b':
        goBackward();
        break;
      case 'c':
        stop();
        break;
      case 'A':
        while (true) {
          if (hc06.read() == 'c') {
            stop();
            break;
          }
          int varL = digitalRead(A0);
          int varR = digitalRead(A5);
          if (varR == 0 && varL == 0) {
            stop();
          } else if (varR == 0 && varL == 1) {
            goRightward();
          } else if (varR == 1 && varL == 0) {
            goLeftward();
          } else if (varR == 1 && varL == 1) {
            goForward();
          }
        }
        break;
    }
  }
}

void setup() {
  Serial.begin(9600);
  hc06.begin(9600);
  motor_L.setSpeed(250);
  motor_L.run(RELEASE);
  motor_R.setSpeed(250);
  motor_R.run(RELEASE);
}

void loop() {
  checkMessage();
}