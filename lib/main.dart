import 'dart:math';
import 'dart:ui' as UI;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark().copyWith(
    ),
    debugShowCheckedModeBanner: false,
    home: Material(child: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late UI.Image _data;
  bool _loading = true;
  bool _error = false;

  List<Point> _tappedPoints = [];


  void getImage() async {
    try {
      print('loading');
      var assetBundle = DefaultAssetBundle.of(context);
      var bytesData = await assetBundle.load('assets/images/trophy.png');
      var unit8List = bytesData.buffer.asUint8List();
      _data = await decodeImageFromList(unit8List);
      this.setState(() {
        _loading = !_loading;
      });
      print('done loading');
    }catch(e) {
      this.setState(() {
        _error = !_error;
      });
    }
  }

  @override
  void initState() {
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey.shade200, child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
          Text('Scratch To see your Prize', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 20),
              buildWidgetToShow(),
        ])));
  }
  
  Widget buildWidgetToShow() {
    if(_loading)
      return CircularProgressIndicator();
    if(_error)
      return Text('An error has occurred');
    return getCanvas();
  }
  
  Widget getCanvas() {
    return GestureDetector(
      onTapUp: _onTapUp,
      child: CustomPaint(
          child: Container(
              width: 200, height: 200, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
          )),
          foregroundPainter: MyPainter(_data, _tappedPoints)
      ),
    );
  }

  void _onTapUp(TapUpDetails details) {
    var dx = details.localPosition.dx;
    var dy = details.localPosition.dy;

    _tappedPoints.add(Point<double>(dx, dy));
    this.setState(() {});

    print('dx: $dx and dy: $dy');
  }
}

class MyPainter extends CustomPainter {
  final UI.Image image;
  final List<Point> tappedPoints;

  MyPainter(this.image, this.tappedPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final blendMode = BlendMode.clear;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.blue.shade200);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, Paint()..color = Colors.white);
    canvas.drawImage(image, Offset(size.width / 2 - 50, size.height / 2 - 50), Paint()..color = Colors.blue);


    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), Paint()..color = Colors.black);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), Paint()..color = Colors.black);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), Paint()..color = Colors.black);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), Paint()..color = Colors.black);

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black);

    tappedPoints.forEach((point) {
      canvas.drawCircle(Offset(point.x as double, point.y as double), 20, Paint()..color=Colors.white..blendMode = blendMode);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
