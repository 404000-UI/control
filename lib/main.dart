import 'package:control/BluetoothManager/bluetooth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

BluetoothService bluetoothService = BluetoothService();

String mode = '';

String forward = 'f';
String rightward = 'r';
String leftward = 'l';
String backward = 'b';
String stop = 'c';

bool startBtn = true;
bool stopBtn = false;

bool upBtn = false;
bool downBtn = false;
bool rightBtn = false;
bool leftBtn = false;

int currentSpeed = 0;

void main() async {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(backgroundColor: Colors.black87, title: MainTitle()),
        body: Column(
          children: [
            Flexible(
              flex: 6,
              child: SpeedDometer(width: width, height: height),
            ),
            Flexible(flex: 6, child: Controller(width: width)),
            Flexible(
              flex: 2,
              child: BottomBtn(width: width, height: height),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTitle extends StatelessWidget {
  const MainTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text("Control", style: TextStyle(color: Colors.white))],
    );
  }
}

class SpeedDometer extends StatefulWidget {
  const SpeedDometer({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<SpeedDometer> createState() => _SpeedDometerState();
}

class _SpeedDometerState extends State<SpeedDometer> {
  double leftSpeed = startBtn ? 0 : 0.5;
  double rightSpeed = startBtn ? 0 : 0.3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.width * 0.05),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Center(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.brown.shade400,
                  ),
                  width: widget.width * 0.1,
                  height: widget.height * 0.3,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.greenAccent.shade700,
                    ),
                    width: widget.width * 0.1,
                    height: (widget.height * 0.3) * leftSpeed,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Center(
              child: Container(
                width: widget.width * 0.45,
                height: widget.width * 0.3,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "current speed is",
                      style: TextStyle(
                        fontSize: widget.width * 0.05,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "$currentSpeed km/h",
                      style: TextStyle(
                        fontSize: widget.width * 0.08,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Center(
              child: Center(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.brown.shade400,
                    ),
                    width: widget.width * 0.1,
                    height: widget.height * 0.3,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.cyanAccent.shade700,
                      ),
                      width: widget.width * 0.1,
                      height: (widget.height * 0.3) * rightSpeed,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Controller extends StatefulWidget {
  const Controller({super.key, required this.width});

  final double width;

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  final List<Color> clickedContainer = [Colors.blueGrey, Colors.white70];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.width * 0.07),
      child: Center(
        child: SizedBox(
          width: widget.width * 0.6,
          height: widget.width * 0.6,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ControllerBtnUp(widget: widget)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ControllerBtnLeft(widget: widget),
                  ControllerBtnRight(widget: widget),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ControllerBtnDown(widget: widget)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ControllerBtnDown extends StatefulWidget {
  const ControllerBtnDown({super.key, required this.widget});

  final Controller widget;

  @override
  State<ControllerBtnDown> createState() => _ControllerBtnDownState();
}

class _ControllerBtnDownState extends State<ControllerBtnDown> {
  Color containerColor = Colors.white;
  Color arrowIconColor = Colors.black;

  void onPanDownListener(DragDownDetails details) {
    if (!startBtn && !upBtn && !rightBtn && !leftBtn && mode == 'M') {
      downBtn = true;
      bluetoothService.sendMessageToDevice(backward);
      setState(() {
        containerColor = Colors.blueGrey;
        arrowIconColor = Colors.white70;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void onPanEndListener(DragEndDetails details) {
    if (!startBtn && mode == 'M') {
      downBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelLister() {
    if (!startBtn && mode == 'M') {
      downBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: onPanDownListener,
      onPanEnd: onPanEndListener,
      onPanCancel: onPanCancelLister,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.widget.width * 0.07),
          color: containerColor,
        ),
        width: widget.widget.width * 0.2,
        height: widget.widget.width * 0.2,
        child: Icon(
          Icons.arrow_downward_rounded,
          color: arrowIconColor,
          size: widget.widget.width * 0.1,
        ),
      ),
    );
  }
}

class ControllerBtnRight extends StatefulWidget {
  const ControllerBtnRight({super.key, required this.widget});

  final Controller widget;

  @override
  State<ControllerBtnRight> createState() => _ControllerBtnRightState();
}

class _ControllerBtnRightState extends State<ControllerBtnRight> {
  Color containerColor = Colors.white;
  Color arrowIconColor = Colors.black;

  void onPanDownListener(DragDownDetails details) {
    if (!startBtn && !upBtn && !downBtn && !rightBtn && mode == 'M') {
      leftBtn = true;
      bluetoothService.sendMessageToDevice(rightward);
      setState(() {
        containerColor = Colors.blueGrey;
        arrowIconColor = Colors.white70;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void onPanEndListener(DragEndDetails details) {
    if (!startBtn && mode == 'M') {
      leftBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelLister() {
    if (!startBtn && mode == 'M') {
      leftBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: onPanDownListener,
      onPanEnd: onPanEndListener,
      onPanCancel: onPanCancelLister,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.widget.width * 0.07),
          color: containerColor,
        ),
        width: widget.widget.width * 0.2,
        height: widget.widget.width * 0.2,
        child: Icon(
          Icons.arrow_forward_rounded,
          color: arrowIconColor,
          size: widget.widget.width * 0.1,
        ),
      ),
    );
  }
}

class ControllerBtnLeft extends StatefulWidget {
  const ControllerBtnLeft({super.key, required this.widget});

  final Controller widget;

  @override
  State<ControllerBtnLeft> createState() => _ControllerBtnLeftState();
}

class _ControllerBtnLeftState extends State<ControllerBtnLeft> {
  Color containerColor = Colors.white;
  Color arrowIconColor = Colors.black;

  void onPanDownListener(DragDownDetails details) {
    if (!startBtn && !upBtn && !downBtn && !leftBtn && mode == 'M') {
      rightBtn = true;
      bluetoothService.sendMessageToDevice(leftward);
      setState(() {
        containerColor = Colors.blueGrey;
        arrowIconColor = Colors.white70;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void onPanEndListener(DragEndDetails details) {
    if (!startBtn && mode == 'M') {
      rightBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelLister() {
    if (!startBtn && mode == 'M') {
      rightBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: onPanDownListener,
      onPanEnd: onPanEndListener,
      onPanCancel: onPanCancelLister,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.widget.width * 0.07),
          color: containerColor,
        ),
        width: widget.widget.width * 0.2,
        height: widget.widget.width * 0.2,
        child: Icon(
          Icons.arrow_back_rounded,
          color: arrowIconColor,
          size: widget.widget.width * 0.1,
        ),
      ),
    );
  }
}

class ControllerBtnUp extends StatefulWidget {
  const ControllerBtnUp({super.key, required this.widget});

  final Controller widget;

  @override
  State<ControllerBtnUp> createState() => _ControllerBtnUpState();
}

class _ControllerBtnUpState extends State<ControllerBtnUp> {
  Color containerColor = Colors.white;
  Color arrowIconColor = Colors.black;

  Future<void> onPanDownListener(DragDownDetails details) async {
    if (!startBtn && !downBtn && !rightBtn && !leftBtn && mode == 'M') {
      upBtn = true;
      bluetoothService.sendMessageToDevice(forward);
      setState(() {
        containerColor = Colors.blueGrey;
        arrowIconColor = Colors.white70;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void onPanEndListener(DragEndDetails details) {
    if (!startBtn && mode == 'M') {
      upBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelLister() {
    if (!startBtn && mode == 'M') {
      upBtn = false;
      setState(() {
        bluetoothService.sendMessageToDevice(stop);
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: onPanDownListener,
      onPanEnd: onPanEndListener,
      onPanCancel: onPanCancelLister,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.widget.width * 0.07),
          color: containerColor,
        ),
        width: widget.widget.width * 0.2,
        height: widget.widget.width * 0.2,
        child: Icon(
          Icons.arrow_upward_rounded,
          size: widget.widget.width * 0.1,
          color: arrowIconColor,
        ),
      ),
    );
  }
}

class BottomBtn extends StatefulWidget {
  const BottomBtn({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<BottomBtn> createState() => _BottomBtnState();
}

class _BottomBtnState extends State<BottomBtn> {
  void onStartBtnPressed() async {
    if (await bluetoothService.isBluetoothSupported() &&
        await bluetoothService.isBluetoothEnabled()) {
      if (await bluetoothService.connectToDevice()) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Car Mode"),
              content: Text("Manual or Automatic operation"),
              actions: [
                TextButton(
                  onPressed: () {
                    mode = 'M';
                    bluetoothService.sendMessageToDevice(mode);
                    Navigator.of(context).pop();
                  },
                  child: Text("Manual"),
                ),
                TextButton(
                  onPressed: () {
                    mode = 'A';
                    bluetoothService.sendMessageToDevice('A');
                    Navigator.of(context).pop();
                  },
                  child: Text("Automatic"),
                ),
              ],
            );
          },
        );
        setState(() {
          startBtn = false;
          stopBtn = true;
        });
        HapticFeedback.heavyImpact();
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Connect Error"),
              content: Text("Cannot connect to car"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Setup Error"),
            content: Text(
              "Your Device don't support Bluetooth or Your Device is not enabled Bluetooth",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void onStopBtnPressed() {
    if (stopBtn) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Stop the car"),
            content: const Text("Are you sure?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("NO"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    startBtn = true;
                    stopBtn = false;
                  });
                  bluetoothService.disconnect();
                  bluetoothService.dispose();
                  HapticFeedback.heavyImpact();
                },
                child: const Text("YES"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onStartBtnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: startBtn ? Colors.lightBlueAccent : Colors.grey,
              minimumSize: Size(widget.width * 0.4, widget.height * 0.08),
              maximumSize: Size(widget.width * 0.4, widget.height * 0.08),
            ),
            child: Text(
              "start",
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.width * 0.08,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onStopBtnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: stopBtn ? Colors.redAccent : Colors.grey,
              minimumSize: Size(widget.width * 0.4, widget.height * 0.08),
              maximumSize: Size(widget.width * 0.4, widget.height * 0.08),
            ),
            child: Text(
              "stop",
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.width * 0.08,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
