import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String CHANNEL = 'samples.flutter.dev/native';
  static const platform = MethodChannel(CHANNEL);

  List<String> methdoChannelLogs = [];
  List<String> reverseMethodChannelLogs = [];

  bool isReverseMethodChannleRunning = false;

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      methdoChannelLogs.add("\$ ${DateTime.now()} $batteryLevel");
    });
  }

  Future<void> _startReverseChannel() async {
    final result = await platform.invokeMethod<bool>('startService');
    setState(() {
      isReverseMethodChannleRunning = true;
      reverseMethodChannelLogs.add("\$ ${DateTime.now()} service started");
    });
  }

  Future<void> _stopReverseChannel() async {
    final result = await platform.invokeMethod<bool>('stopService');
    print(result);
    setState(() {
      isReverseMethodChannleRunning = false;
      reverseMethodChannelLogs.add("\$ ${DateTime.now()} service stoped");
    });
  }

  var methodChannelLogScrollcontroller = ScrollController();
  var reverseChannelLogsScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    MethodChannel(CHANNEL).setMethodCallHandler((call) async {
      print("recived");
      if (call.method == "reverseChannelStream") {
        setState(() {
          setState(() {
            reverseMethodChannelLogs.add("\$ ${DateTime.now()} running");
          });
        });

        reverseChannelLogsScrollController.animateTo(
            reverseChannelLogsScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceIn);
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Method Channel"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  const Text("Method Channel"),
                  const Spacer(),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () async {
                        _getBatteryLevel();

                        methodChannelLogScrollcontroller.animateTo(
                            methodChannelLogScrollcontroller
                                .position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      },
                      icon: const Icon(Icons.send),
                      label: const Text("call"))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Logs"),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    margin: const EdgeInsets.only(top: 5.0),
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Scrollbar(
                      controller: methodChannelLogScrollcontroller,
                      thumbVisibility: true,
                      child: ListView.builder(
                          controller: methodChannelLogScrollcontroller,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: methdoChannelLogs.length,
                          itemBuilder: (context, index) {
                            return Text(methdoChannelLogs[index]);
                          }),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: const Text("Reverse Method Channel")),
                    const Spacer(),
                    ElevatedButton.icon(
                        onPressed: () async {
                          if (!isReverseMethodChannleRunning) {
                            _startReverseChannel();
                          } else {
                            _stopReverseChannel();
                          }
                        },
                        icon: !isReverseMethodChannleRunning
                            ? const Icon(Icons.play_arrow)
                            : const Icon(Icons.stop_circle),
                        label: !isReverseMethodChannleRunning
                            ? const Text("Start")
                            : const Text("Stop")),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Logs"),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    margin: const EdgeInsets.only(top: 5.0),
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Scrollbar(
                      controller: reverseChannelLogsScrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                          controller: reverseChannelLogsScrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: reverseMethodChannelLogs.length,
                          itemBuilder: (context, index) {
                            return Text(reverseMethodChannelLogs[index]);
                          }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
