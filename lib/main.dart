import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

const List<Color> appColors = [
  Color(0xFF4285F4),
  Color(0xFF34A853),
  Color(0xFFEA4335),
  Color(0xFFFBBC05),
];

const List<Color> lightColors = [
  Color(0xFFE5E5E5),
  Color(0xFFDBDBDB)
];

const List<Color> darkColors = [
  Color(0xFF1E1E1E),
  Color(0xFF252526)
];

const List<double> fontSize = [100, 140, 210, 100, 180, 250, 180, 160, 240, 100, 120, 200];

void main() {
  if (!kIsWeb && Platform.isMacOS) debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LenovoClock(),
    );
  }
}

class LenovoClock extends StatefulWidget {
  @override
  _LenovoClockState createState() => _LenovoClockState();
}

class _LenovoClockState extends State<LenovoClock> {
  final _controller = StreamController<DateTime>();
  int _currColor = 0;
  int _hour = -1;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (_) => _controller.sink.add(DateTime.now()));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;
    final List<double> positionTop = [h*0.1, -h*0.06, h*0.2, h*0.62, h*0.4, h/3.2, h*0.42, h*0.54, h*0.16, h*0.1, 0, -h*0.08];
    final List<double> positionLeft = [w*0.74, w*0.86, w*0.8, w*0.9, w*0.68, w*0.47, w*0.32, w*0.04, w*0.15, w*0.02, w*0.18, w*0.4];
    final colors = Theme.of(context).brightness == Brightness.light ? lightColors : darkColors;
    return Material(
      color: colors[0],
      child: SafeArea(
        child: StreamBuilder(
          stream: _controller.stream,
          initialData: DateTime.now(),
          builder: (context, AsyncSnapshot<DateTime> snapshot){
            int hour = snapshot.data.hour;
            if(hour > 12) hour = hour - 12;
            if(hour != _hour) {
              _hour = hour;
              _currColor = Random().nextInt(3);
            }
            return Stack(
              children: List.generate(13, (i){
                if(i == 12) return CustomPaint(
                  size: Size.infinite,
                  painter: MinuteLine(snapshot.data.minute, colors[1]),
                );
                return Positioned(
                  top: positionTop[i],
                  left: positionLeft[i],
                  child: Text(
                    (i+1).toString(),
                    style: TextStyle(fontSize: fontSize[i], color: i == hour-1 ? appColors[_currColor] : colors[1], fontFamily: 'bauhaus'),
                  ),
                );
              }),
            );
          },
        )
      ),
    );
  }
}

class MinuteLine extends CustomPainter{
  final int _minute;
  final Color _color;

  MinuteLine(this._minute, this._color);

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;
    final Paint paint = Paint();
    final List<List<double>> delta = [
      [w/2, w/20, 0, 0, 0],
      [w, 0, 0, h/10, 10],
      [w, -w/20, h, 0, 20],
      [0, 0, h, -h/10, 40],
      [0, w/20, 0, 0, 50]
    ];
    int n = 0;
    for(int i=0; i<60; i++) {
      if(i==11 || i==20 || i==41 || i==50) n++;
      canvas.drawCircle(Offset(delta[n][0]+delta[n][1]*(i-delta[n][4]), delta[n][2]+delta[n][3]*(i-delta[n][4])), i%5==0 ? 10 : 4, paint..color = i<=_minute ? appColors[3] : _color);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}