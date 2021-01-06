import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Translator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'AR Translator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[
            Image(
              image: AssetImage('assets/images/logo.png'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LiveTranslate()));
              },
              child: Text("Live translator"),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(250, 35),
                  textStyle: TextStyle(
                    fontSize: 20,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PhotoTranslate()));
              },
              child: Text("Photo translator"),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(250, 35),
                  textStyle: TextStyle(
                    fontSize: 20,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Clipboard()));
              },
              child: Text("Clipboard"),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(250, 35),
                  textStyle: TextStyle(
                    fontSize: 20,
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class LiveTranslate extends StatefulWidget {
  LiveTranslate({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LiveTranslate createState() => _LiveTranslate();
}

class _LiveTranslate extends State<LiveTranslate> {
  ArCoreController arCoreController;

  _onArCoreViewCreated(ArCoreController _arcoreController) {
    arCoreController = _arcoreController;
    _addSphere(arCoreController);
    _addTextPlain(arCoreController);
  }

  _addSphere(ArCoreController _arCoreController) {
    final material = ArCoreMaterial(color: Colors.deepOrange);
    final sphere = ArCoreSphere(materials: [material], radius: 0.2);
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1),
    );

    _arCoreController.addArCoreNode(node);
  }

  _addTextPlain(ArCoreController _arCoreController) {
    final material = ArCoreMaterial(color: Colors.white);
    final textPlain = ArCoreCube(
        materials: [material], size: vector.Vector3(0.1, 0.1, 0.001));
    final node = ArCoreNode(
      shape: textPlain,
      position: vector.Vector3(0, 0, 1),
      name: "dupa",
      // children: Text("dupas"),
    );

    _arCoreController.addArCoreNode(node);
    // ViewRender
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Translate"),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }
}

class PhotoTranslate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo Translate"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("zawracamy"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class Clipboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clipboard"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("zawracamy"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
