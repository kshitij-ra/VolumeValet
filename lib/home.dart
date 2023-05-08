import 'package:flutter/material.dart';
import 'vol_fns.dart';
import 'media_fns.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String status = '';
  String addr = '';
  String port = '';
  int _vol = 0;
  late bool muted;
  late bool scanned;
  String url = '';
  @override
  void initState() {
    scanned = false;
    muted = true;
    status = 'Disconnected';
    super.initState();
  }

  scanqr() async {
    await Permission.camera.request();
    var cameraScanResult = await scanner.scan();
    if (cameraScanResult != null && cameraScanResult.length >= 25) {
      var c = cameraScanResult.substring(0, 11);
      if (c == "VolumeValet") {
        port = cameraScanResult.substring(
            cameraScanResult.length - 4, cameraScanResult.length);
        addr = cameraScanResult.substring(12, cameraScanResult.length - 5);
        setState(() {
          scanned = true;
          status = 'Press Connect!';
        });
      } else {
        setState(() {
          status = 'Invalid QR!';
          scanned = false;
        });
      }
    } else {
      setState(() {
        status = 'Invalid QR!';
        scanned = false;
      });
    }
  }

  void vplus() async {
    if (_vol < 100) {
      int v = await getVolume(url);
      v++;
      String s1 = await setVolume(url, v);
      if (s1 != 'Success') {
        status = 'Error!';
      }
      setState(() {
        _vol = v;
      });
    }
  }

  void vslider(double val) async {
    if (_vol < 100) {
      _vol = val.round();
      String s1 = await setVolume(url, _vol);
      if (s1 != 'Success') {
        status = 'Error!';
      }
      setState(() {});
    }
  }

  void vminus() async {
    if (_vol > 0) {
      int v = await getVolume(url);
      v--;
      String s1 = await setVolume(url, v);
      if (s1 != 'Success') {
        status = 'Error!';
      }
      setState(() {
        _vol = v;
      });
    }
  }

  void goNext() async {
    await gonext(url);
  }

  void goPrev() async {
    await goprev(url);
  }

  void pP() async {
    await pp(url);
  }

  connectDev() async {
    String u = 'http://$addr:$port';
    url = u;
    int v = -1;
    v = await getVolume(url);
    bool m = await getMute(url);
    String s1 = v.toString();
    if (s1 == '-1') {
      status = 'Error!';
    } else {
      status = 'Connected';
    }
    setState(() {
      if (m == true) {
        muted = true;
      } else {
        muted = false;
      }
      _vol = v;
    });
  }

  vmute() async {
    String s1 = 'a';
    if (muted == true) {
      s1 = await muteVolume(url, 0);
      muted = false;
    } else {
      s1 = await muteVolume(url, 1);
      muted = true;
    }
    if (s1 != 'Success') {
      status = 'Error!';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 4,
          shadowColor: Theme.of(context).shadowColor,
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Status: "),
                        Text(status),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              addr = value.toString();
                            },
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText:
                                    scanned == true ? addr : 'Host Address'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            onChanged: (value) {
                              port = value.toString();
                            },
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: scanned == true ? port : 'Port'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () async {
                              await scanqr();
                            },
                            icon: const Icon(Icons.qr_code_outlined),
                            label: const Text('Scan QR')),
                        FilledButton.icon(
                            onPressed: () async {
                              await connectDev();
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Connect')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                      onPressed: goPrev,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.skip_previous_outlined)),
                  OutlinedButton(
                      onPressed: pP,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.play_arrow_outlined),
                          Text('/'),
                          Icon(Icons.pause_outlined),
                        ],
                      )),
                  OutlinedButton(
                      onPressed: goNext,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.skip_next_outlined)),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  //color: Colors.amber,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 300,
                            //add volume slider here
                            child: SliderTheme(
                              data: SliderThemeData(
                                  trackHeight: 40,
                                  thumbShape: SliderComponentShape.noOverlay,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  valueIndicatorShape:
                                      SliderComponentShape.noOverlay),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                    value: _vol.toDouble(),
                                    min: 0,
                                    max: 100,
                                    label: _vol.toString(),
                                    divisions: 100,
                                    // onChangeEnd: (value) {
                                    //   vslider(value);
                                    // },
                                    onChanged: (value) {
                                      _vol = value.toInt();
                                      vslider(value);
                                    }),
                              ),
                            ),
                          ),
                          //Refresh button
                          const SizedBox(
                            width: 80,
                          ),

                          //volume buttons
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //vol up
                              FilledButton.tonal(
                                  onPressed: vplus,
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(15),
                                  ),
                                  child: const Icon(Icons.volume_up_outlined)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                _vol.toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //vol down
                              FilledButton.tonal(
                                  onPressed: vminus,
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(15),
                                  ),
                                  child:
                                      const Icon(Icons.volume_down_outlined)),
                            ],
                          ), //mute botton
                          FilledButton.tonal(
                              onPressed: vmute,
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    // muted ? Colors.red : Colors.white,
                                    muted ? Colors.red : null,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15),
                              ),
                              child: const Icon(Icons.volume_off_outlined)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
