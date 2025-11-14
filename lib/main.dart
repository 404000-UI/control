import 'package:control/BluetoothManager/bluetooth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

BluetoothService bluetoothService = BluetoothService();
bool isConnected = false;

String mode = "";
List<IconData> modeIconList = [Icons.person, Icons.directions_car_rounded];
IconData modeIcon = modeIconList[0];

List<bool> isSelected = [false];

String forward = (mode == "M") ? "f" : "A";
String rightward = (mode == "M") ? "r" : "A";
String leftward = (mode == "M") ? "l" : "A";
String backward = (mode == "M") ? "b" : "A";
String stop = (mode == "M") ? "c" : "A";

IconData upBtnIconData = Icons.arrow_forward_rounded;
IconData downBtnIconData = Icons.arrow_back_rounded;
IconData leftBtnIconData = Icons.arrow_upward_rounded;
IconData rightBtnIconData = Icons.arrow_downward_rounded;

bool startBtn = true;
bool stopBtn = false;

bool upBtn = false;
bool downBtn = false;
bool rightBtn = false;
bool leftBtn = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Flexible(flex: 2, child: UpDownController(width: width)),
            Flexible(flex: 1, child: FnButtons(width: width)),
            Flexible(flex: 3, child: LeftRightController(width: width)),
          ],
        ),
      ),
    );
  }
}

// Main activity Widgets

class UpDownController extends StatefulWidget {
  const UpDownController({super.key, required this.width});

  final double width;

  @override
  State<UpDownController> createState() => _UpDownControllerState();
}

class _UpDownControllerState extends State<UpDownController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.width * 0.8,
        height: widget.width * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DownControllerBtn(size: widget.width * 0.3),
            UpControllerBtn(size: widget.width * 0.3),
          ],
        ),
      ),
    );
  }
}

class FnButtons extends StatefulWidget {
  const FnButtons({super.key, required this.width});

  final double width;

  @override
  State<FnButtons> createState() => _FnButtonsState();
}

class _FnButtonsState extends State<FnButtons> {
  void onStartBtnPressed() async {
    if (await bluetoothService.isBluetoothSupported() &&
        await bluetoothService.isBluetoothEnabled()) {
      isConnected = await bluetoothService.connectToDevice();
      if (isConnected) {
        setState(() {
          startBtn = false;
          stopBtn = true;
        });
        mode = "M";
        HapticFeedback.heavyImpact();
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Connection Error"),
              content: Text("Cannot connect to Device"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Ok"),
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
            title: const Text("Bluetooth Error"),
            content: const Text(
              "This Device don't support Bluetooth or is not enabled Bluetooth.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    }
  }

  void onStopBtnPressed() async {
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
                child: Text("NO"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    startBtn = true;
                    stopBtn = false;
                    modeIcon = modeIconList[0];
                  });
                  bluetoothService.sendMessageToDevice(stop);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: ElevatedButton(
            onPressed: onStopBtnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: stopBtn ? Colors.redAccent : Colors.grey,
              minimumSize: Size(widget.width * 0.5, widget.width * 0.2),
              maximumSize: Size(widget.width * 0.5, widget.width * 0.2),
            ),
            child: Text(
              "stop",
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.width * 0.08,
              ),
            ),
          ),
        ),
        RotatedBox(
          quarterTurns: 1,
          child: ElevatedButton(
            onPressed: onStartBtnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: startBtn ? Colors.lightBlueAccent : Colors.grey,
              minimumSize: Size(widget.width * 0.5, widget.width * 0.2),
              maximumSize: Size(widget.width * 0.5, widget.width * 0.2),
            ),
            child: Text(
              "start",
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.width * 0.08,
              ),
            ),
          ),
        ),
        ToggleBtn(size: widget.width * 0.2),
      ],
    );
  }
}

class LeftRightController extends StatefulWidget {
  const LeftRightController({super.key, required this.width});

  final double width;

  @override
  State<LeftRightController> createState() => _LeftRightControllerState();
}

class _LeftRightControllerState extends State<LeftRightController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.width * 0.3,
        height: widget.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LeftControllerBtn(size: widget.width * 0.3),
            RightControllerBtn(size: widget.width * 0.3),
          ],
        ),
      ),
    );
  }
}

// Controller Buttons - Up, Down, Right, Left

class UpControllerBtn extends StatefulWidget {
  const UpControllerBtn({super.key, required this.size});

  final double size;

  @override
  State<UpControllerBtn> createState() => _UpControllerBtnState();
}

class _UpControllerBtnState extends State<UpControllerBtn> {
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
    if (!startBtn && !downBtn && !rightBtn && !leftBtn && mode == 'M') {
      upBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelListener() {
    if (!startBtn && !downBtn && !rightBtn && !leftBtn && mode == 'M') {
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
      onPanCancel: onPanCancelListener,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          color: containerColor,
        ),
        width: widget.size,
        height: widget.size,
        child: Icon(upBtnIconData, color: arrowIconColor, size: widget.size),
      ),
    );
  }
}

class DownControllerBtn extends StatefulWidget {
  const DownControllerBtn({super.key, required this.size});

  final double size;

  @override
  State<DownControllerBtn> createState() => _DownControllerBtnState();
}

class _DownControllerBtnState extends State<DownControllerBtn> {
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
    if (!startBtn && !upBtn && !rightBtn && !leftBtn && mode == 'M') {
      downBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelListener() {
    if (!startBtn && !upBtn && !rightBtn && !leftBtn && mode == 'M') {
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
      onPanCancel: onPanCancelListener,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          color: containerColor,
        ),
        width: widget.size,
        height: widget.size,
        child: Icon(downBtnIconData, color: arrowIconColor, size: widget.size),
      ),
    );
  }
}

class LeftControllerBtn extends StatefulWidget {
  const LeftControllerBtn({super.key, required this.size});

  final double size;

  @override
  State<LeftControllerBtn> createState() => _LeftControllerBtnState();
}

class _LeftControllerBtnState extends State<LeftControllerBtn> {
  Color containerColor = Colors.white;
  Color arrowIconColor = Colors.black;

  void onPanDownListener(DragDownDetails details) {
    if (!startBtn && !upBtn && !downBtn && !rightBtn && mode == 'M') {
      leftBtn = true;
      bluetoothService.sendMessageToDevice(leftward);
      setState(() {
        containerColor = Colors.blueGrey;
        arrowIconColor = Colors.white70;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void onPanEndListener(DragEndDetails details) {
    if (!startBtn && !upBtn && !downBtn && !rightBtn && mode == 'M') {
      leftBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelListener() {
    if (!startBtn && !upBtn && !downBtn && !rightBtn && mode == 'M') {
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
      onPanCancel: onPanCancelListener,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          color: containerColor,
        ),
        width: widget.size,
        height: widget.size,
        child: Icon(leftBtnIconData, color: arrowIconColor, size: widget.size),
      ),
    );
  }
}

class RightControllerBtn extends StatefulWidget {
  const RightControllerBtn({super.key, required this.size});

  final double size;

  @override
  State<RightControllerBtn> createState() => _RightControllerBtnState();
}

class _RightControllerBtnState extends State<RightControllerBtn> {
  Color containerColor = Colors.white;
  Color arrowIconColor = Colors.black;

  void onPanDownListener(DragDownDetails details) {
    if (!startBtn && !upBtn && !downBtn && !leftBtn && mode == 'M') {
      rightBtn = true;
      bluetoothService.sendMessageToDevice(rightward);
      setState(() {
        containerColor = Colors.blueGrey;
        arrowIconColor = Colors.white70;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void onPanEndListener(DragEndDetails details) {
    if (!startBtn && !upBtn && !downBtn && !leftBtn && mode == 'M') {
      rightBtn = false;
      bluetoothService.sendMessageToDevice(stop);
      setState(() {
        containerColor = Colors.white;
        arrowIconColor = Colors.black;
      });
    }
  }

  void onPanCancelListener() {
    if (!startBtn && !upBtn && !downBtn && !leftBtn && mode == 'M') {
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
      onPanCancel: onPanCancelListener,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          color: containerColor,
        ),
        width: widget.size,
        height: widget.size,
        child: Icon(rightBtnIconData, color: arrowIconColor, size: widget.size),
      ),
    );
  }
}

// Function Buttons - Toggle, InitialSettingBtn

class ToggleBtn extends StatefulWidget {
  const ToggleBtn({super.key, required this.size});

  final double size;

  @override
  State<ToggleBtn> createState() => _ToggleBtnState();
}

class _ToggleBtnState extends State<ToggleBtn> {
  void onTogglePressed(index) {
    if (isConnected && stopBtn) {
      setState(() {
        mode = (mode == "M") ? "A" : "M";
        modeIcon = (modeIcon == modeIconList[0])
            ? modeIconList[1]
            : modeIconList[0];
      });
      if (mode == "A") {
        bluetoothService.sendMessageToDevice(mode);
      } else if (mode == "M") {
        bluetoothService.sendMessageToDevice(stop);
      }
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: ToggleButtons(
        onPressed: onTogglePressed,
        renderBorder: false,
        color: Colors.white,
        isSelected: isSelected,
        children: [Icon(modeIcon, size: widget.size)],
      ),
    );
  }
}
