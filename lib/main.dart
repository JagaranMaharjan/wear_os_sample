import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:is_wear/is_wear.dart';

import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:wear_plus/wear_plus.dart';

import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';

late final bool isWear;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  isWear = (await IsWear().check()) ?? false;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<SensorValue> _sensorValues = [];
  final _watch = WatchConnectivity();

  var _count = 0;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    _context = {};
    _receivedContexts = [];

    _watch.messageStream.listen((e) => setState(() {
          _receivedContexts.add(e);
          _sensorValues.add(SensorValue(
            time: DateTime.now(),
            value: double.tryParse(e['data']) ?? 0,
          ));

          _log.add('Received message: $e');
          setState(() {});
        }));

    _watch.contextStream.listen((e) => setState(() {
          _receivedContexts.add(e);
          _log.add('Received context: $e');
        }));

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    _context = await _watch.applicationContext;
    _receivedContexts = await _watch.receivedApplicationContexts;
    setState(() {});
  }

  Text _buildText(String text) {
    return Text(
      text,
      style: isWear ? TextStyle(fontSize: 6) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildText('Supported: $_supported'),
                  _buildText('Paired: $_paired'),
                  _buildText('Reachable: $_reachable'),
                ],
              ),
              _buildText('Send Context/Msg: $_context'),
              _buildText('Received contexts: $_receivedContexts'),

              // const SizedBox(height: 8),
              // const Text('Send'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 1,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => initPlatformState(),
                      child: _buildText('Refresh'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => sendMessage(),
                      child: _buildText(
                          '${isWear ? 'Send Message To Android' : 'Send Message To Wear Os'}'),
                    ),
                  ),
                ],
              ),
              if (!isWear) ...{
                _buildText('Log'),
                // ..._log.reversed.map(Text.new),
                CheckBMP(
                  onBPM: (v) {
                    //{'data': !isWear ? 'Hello wear os' : 'Hello Android'}
                    _watch.sendMessage({'data': '${v.value}'});

                    setState(() => _log.add('Sent message: ${v.toJSON()}'));
                  },
                  onBPMValues: (v) {
                    _watch.sendMessage({'data': '${v.value}'});
                    setState(() => _log.add('Sent message 01: ${v.toJSON()}'));
                  },
                ),
              } else ...{
                // if (_sensorValues.isNotEmpty)
                //   SizedBox(
                //     height: 250,
                //     width: double.infinity,
                //     child: BPMChart(_sensorValues),
                //   ),
              },
            ],
          ),
        ),
      ),
    );

    return MaterialApp(
      home: isWear
          ? AmbientMode(
              builder: (context, mode, child) => child!,
              child: home,
            )
          : home,
    );
  }

  void sendMessage() {
    final message = {'data': !isWear ? 'Hello wear os' : 'Hello Android'};
    _watch.sendMessage(message);
    setState(() => _log.add('Sent message: $message'));
  }

  void sendContext() {
    _count++;
    final context = {
      'data': '${!isWear ? 'Hello wear os' : 'Hello Android'}$_count'
    };
    _watch.updateApplicationContext(context);
    setState(() => _log.add('Sent context: $context'));
  }

  void toggleBackgroundMessaging() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => sendMessage());
    } else {
      timer?.cancel();
      timer = null;
    }
    setState(() {});
  }
}

class CheckBMP extends StatefulWidget {
  final void Function(SensorValue bmpUpdate) onBPM;
  final void Function(SensorValue bmpUpdate) onBPMValues;

  CheckBMP({required this.onBPM, required this.onBPMValues});

  @override
  _CheckBMPState createState() => _CheckBMPState();
}

class _CheckBMPState extends State<CheckBMP> {
  List<SensorValue> data = [];
  List<SensorValue> bpmValues = [];

  bool isBPMEnabled = false;
  Widget? dialog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          isBPMEnabled
              ? dialog = HeartBPMDialog(
                  context: context,
                  showTextValues: true,
                  borderRadius: 10,
                  onRawData: (value) {
                    setState(() {
                      if (data.length >= 100) data.removeAt(0);
                      data.add(value);
                      widget.onBPM(value);
                    });
                  },
                  onBPM: (value) => setState(() {
                    if (bpmValues.length >= 100) bpmValues.removeAt(0);
                    bpmValues.add(SensorValue(
                        value: value.toDouble(), time: DateTime.now()));
                    widget.onBPMValues(SensorValue(
                        value: value.toDouble(), time: DateTime.now()));
                  }),
                )
              : SizedBox(),
          isBPMEnabled && data.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(border: Border.all()),
                  height: 180,
                  child: BPMChart(data),
                )
              : SizedBox(),
          isBPMEnabled && bpmValues.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(border: Border.all()),
                  constraints: BoxConstraints.expand(height: 180),
                  child: BPMChart(bpmValues),
                )
              : SizedBox(),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.favorite_rounded),
              label: Text(isBPMEnabled ? "Stop measurement" : "Measure BPM"),
              onPressed: () => setState(() {
                if (isBPMEnabled) {
                  isBPMEnabled = false;
                } else
                  isBPMEnabled = true;
              }),
            ),
          ),
        ],
      ),
    );
  }
}
