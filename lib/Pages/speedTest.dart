import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:krestelvpn/Pages/consentpage.dart';
import 'package:speed_test_dart/classes/coordinate.dart';
import 'package:speed_test_dart/classes/server.dart';
import 'package:speed_test_dart/speed_test_dart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final speedTest = FlutterInternetSpeedTest();
  double speed = 0;
  double download = 0;
  int indexD = 0;
  int indexU = 0;
  double upoad = 0;
  String ip = '';
  String location = '';
  String isp = '';
  bool isLoading = false;
  bool start = false;
  bool upload = false;

  // Create a tester instance
  SpeedTestDart tester = SpeedTestDart();

  // And a variable to store the best servers
  List<Server> bestServersList = [];

  // Example function to set the best servers, could be called
  // in an initState()
  @override
  void initState() {
    super.initState();
    setBestServers();
  }

  Future<void> setBestServers() async {
    try {
      final settings = await tester.getSettings();
      final servers = settings.servers;

      log(servers.toString());

      final _bestServersList = await tester.getBestServers(
        servers: servers,
      );

      log(_bestServersList.toString());

      setState(() {
        bestServersList = _bestServersList;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  getSpeed() async {
    try {
      //Test download speed in MB/s
      log(servers.toString());
      final downloadRate = await tester
          .testDownloadSpeed(servers: servers)
          .onError((error, stackTrace) {
        log(error.toString());
        return 0;
      });

      //Test upload speed in MB/s
      final uploadRate = await tester.testUploadSpeed(servers: servers);
      setState(() {
        download = downloadRate;
        upoad = uploadRate;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  startTest() async {
    setState(() {
      isLoading = true;
    });
    speedTest.startTesting(
      useFastApi: true, //true(default)
      onStarted: () {
        // TODO
        setState(() {
          start = true;
          upload = false;
          download = 0;
          upoad = 0;
          indexD = 0;
          indexU = 0;
        });
      },
      onCompleted: (TestResult downloads, TestResult uploads) {
        speed = 0;
        start = false;
        setState(() {});
      },
      onProgress: (double percent, TestResult data) {
        if (start) {
          HapticFeedback.lightImpact();
          if (data.type == TestType.download) {
            setState(() {
              speed = data.transferRate;
              download = data.transferRate;
            });
          } else {
            setState(() {
              upload = true;
              speed = data.transferRate;
              upoad = data.transferRate;
            });
          }
        }
      },
      onError: (String errorMessage, String speedTestError) {
        // TODO
        log(errorMessage);
        setState(() {
          isLoading = false;
          speed = 0;
          start = false;
        });
      },
      onDefaultServerSelectionInProgress: () {
        // TODO
        //Only when you use useFastApi parameter as true(default)
      },
      onDefaultServerSelectionDone: (Client? client) {
        // TODO
        log(client.toString());
        if (client != null) {
          setState(() {
            ip = client.ip!;
            isp = client.isp ?? "Unknown";

            location = client.location!.city! + " " + client.location!.country!;
          });
        }

        ///Only when you use useFastApi parameter as true(default)
      },
      onDownloadComplete: (TestResult data) {
        // TODO
        setState(() {
          download = data.transferRate;
        });
      },
      onUploadComplete: (TestResult data) {
        // TODO
        setState(() {
          upoad = data.transferRate;
        });
      },
      onCancel: () {
        speed = 0;
        start = false;
        setState(() {});
      },
    );
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  cancelTest() async {
    speed = 0;
    start = false;
    setState(() {});
  }

  @override
  void dispose() {
    speedTest.cancelTest();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("Speed Test",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Download and Upload speed
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: GradientBoxBorder(
                      gradient: LinearGradient(colors: [
                        Color(0xFFFF477E),
                        Color(0xFF477EFF),
                      ]),
                      width: 2,
                    )),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Location",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(location,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          color: Color(0xFFDFDFDF),
                          width: 1,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Text("IP Address",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                    ip.length > 20
                                        ? ip.replaceRange(18, ip.length, '..')
                                        : ip,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 20,
              ),
              // Speed Gauge

              isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 260,
                              width: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                                height: 260,
                                width: 260,
                                child: Center(
                                    child: Text(
                                  'Connecting',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      width: MediaQuery.sizeOf(context).width - 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SfRadialGauge(
                          enableLoadingAnimation: true,
                          axes: <RadialAxis>[
                            RadialAxis(
                              radiusFactor: 1,
                              minimum: 0,
                              showLastLabel: true,
                              useRangeColorForAxis: true,
                              showTicks: false,
                              labelOffset: 25,
                              // axisLineStyle: AxisLineStyle(
                              //     cornerStyle: CornerStyle.bothCurve,
                              //     thickness: 5),
                              maximum:
                                  100, // Adjusted to match GaugeRange max value
                              showLabels: true, // Ensures labels are displayed
                              axisLabelStyle:
                                  GaugeTextStyle(color: Colors.grey),
                              axisLineStyle: AxisLineStyle(
                                  color: Color.fromARGB(255, 58, 58, 58),
                                  thickness: 10,
                                  cornerStyle: CornerStyle.bothCurve),
                              pointers: [
                                RangePointer(
                                    value: speed,
                                    gradient: SweepGradient(colors: <Color>[
                                      Color(0xFFFF335E),
                                      Color(0xFF0070FF)
                                    ], stops: <double>[
                                      0.25,
                                      0.75
                                    ]),
                                    enableAnimation: true,
                                    width: 10,
                                    cornerStyle: CornerStyle.bothCurve),
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  widget: Column(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                      ),
                                      Text(upload ? 'Upload' : 'Download',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey)),
                                      SizedBox(height: 10),
                                      Text(
                                          '${speed.toString().length < 4 ? speed.toString() : speed.toString().replaceRange(4, speed.toString().length, '')}',
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold)),
                                      Text("Mb/s",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  angle: 90,
                                  positionFactor: 0.6,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

              // Location and IP Address
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green),
                            child: Icon(
                              Icons.arrow_upward_outlined,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Download",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text("${download.toStringAsFixed(1)}Mbps",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red),
                            child: Icon(
                              Icons.arrow_downward_outlined,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Upload",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text("${upoad.toStringAsFixed(1)}Mbps",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              GradientButton(
                  onPressed: () {
                    start ? cancelTest() : startTest();
                  },
                  text: start ? 'Stop Test' : 'Start Test')
              // Speed Test Button
            ],
          ),
        ),
      ),
    );
  }
}

List<Server> servers = [
  Server(
    52535,
    "Ashburn, VA",
    "United States",
    "Virtual Technologies and Solutions",
    "speedtest-ash.vts.bf:8080",
    "http://speedtest-ash.vts.bf:8080/speedtest/upload.php",
    39.0438,
    -77.4874,
    38.0,
    1,
    Coordinate(39.04, -77.48),
  ),
  Server(
    41287,
    "Ashburn, VA",
    "United States",
    "All Points Broadband",
    "aftermath.allpointsbroadband.net:8080",
    "http://aftermath.allpointsbroadband.net:8080/speedtest/upload.php",
    39.0438,
    -77.4874,
    38.0,
    1,
    Coordinate(39.04, -77.48),
  ),
  Server(
    14229,
    "Ashburn, VA",
    "United States",
    "Frontier",
    "ashburn.va.speedtest.frontier.com:8080",
    "https://ashburn.va.speedtest.frontier.com:8080/speedtest/upload.php",
    39.0516,
    -77.4832,
    38.0,
    1,
    Coordinate(39.05, -77.48),
  ),
  Server(
    28920,
    "Ashburn, VA",
    "United States",
    "PhoenixNAP Global IT Services",
    "speedash.phoenixnap.com:8080",
    "http://speedash.phoenixnap.com:8080/speedtest/upload.php",
    39.0516,
    -77.4832,
    38.0,
    1,
    Coordinate(39.05, -77.48),
  ),
  Server(
    48604,
    "Ashburn, VA",
    "United States",
    "GSL Networks",
    "iad10.speedtest.gslnetworks.com:8080",
    "http://iad10.speedtest.gslnetworks.com:8080/speedtest/upload.php",
    39.0516,
    -77.4832,
    38.0,
    1,
    Coordinate(39.05, -77.48),
  ),
  Server(
    32493,
    "Ashburn, VA",
    "United States",
    "Rackdog",
    "vaspeedtest.rackdog.com:8080",
    "http://vaspeedtest.rackdog.com:8080/speedtest/upload.php",
    39.0516,
    -77.4832,
    38.0,
    1,
    Coordinate(39.05, -77.48),
  ),
  Server(
    53965,
    "Ashburn, VA",
    "United States",
    "Boost Mobile",
    "speedtest-iad.dish-wireless.com:8080",
    "http://speedtest-iad.dish-wireless.com:8080/speedtest/upload.php",
    39.0516,
    -77.4832,
    38.0,
    1,
    Coordinate(39.05, -77.48),
  ),
  Server(
    5906,
    "Ashburn, VA",
    "United States",
    "GigeNET",
    "speedtest.iad.gigenet.com:8080",
    "http://speedtest.iad.gigenet.com:8080/speedtest/upload.php",
    39.0516,
    -77.4832,
    38.0,
    1,
    Coordinate(39.05, -77.48),
  ),
  Server(
    1775,
    "Baltimore, MD",
    "United States",
    "Comcast",
    "stosat-balt-01.sys.comcast.net:8080",
    "http://stosat-balt-01.sys.comcast.net:8080/speedtest/upload.php",
    39.2833,
    -76.6167,
    38.0,
    1,
    Coordinate(39.28, -76.61),
  ),
  Server(
    17355,
    "Fort Littleton, PA",
    "United States",
    "Upward Broadband",
    "speedtesthuntingdon.upwardbroadband.com:8080",
    "http://speedtesthuntingdon.upwardbroadband.com:8080/speedtest/upload.php",
    40.0627,
    -77.9637,
    38.0,
    1,
    Coordinate(40.06, -77.96),
  ),
];
