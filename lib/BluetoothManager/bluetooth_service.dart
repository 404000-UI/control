import 'dart:async';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

class BluetoothService {
  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();
  final String macAddr = "00:23:09:01:57:CC";

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<BluetoothData>? _dataSubscription;
  StreamSubscription<BluetoothState>? _stateSubscription;

  Future<bool> isBluetoothSupported() async {
    try {
      return await _bluetooth.isBluetoothSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      return await _bluetooth.isBluetoothEnabled();
    } catch (e) {
      return false;
    }
  }

  void setupListeners() {
    _stateSubscription = _bluetooth.onStateChanged.listen((state) {});

    _connectionSubscription = _bluetooth.onConnectionChanged.listen(
      (connectionState) {},
    );

    _dataSubscription = _bluetooth.onDataReceived.listen((data) {});
  }

  Future<bool> connectToDevice() async {
    try {
      return await _bluetooth.connect(macAddr);
    } catch (e) {
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      return await _bluetooth.disconnect();
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendMessageToDevice(String message) async {
    try {
      return await _bluetooth.sendString(message);
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendData(List<int> data) async {
    try {
      return await _bluetooth.sendData(data);
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _stateSubscription?.cancel();
  }
}
