import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MG Musique',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Marc play'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusique = [
    new Musique('theme Swift', 'Marc', 'image/sia.jpeg', "https://open.spotify.com/track/2J2Z1SkXYghSajLibnQHOa?si=3c739d25403d46f8"),
    new Musique('theme', 'Marc', "image/monkey.jpeg", 'https://open.spotify.com/track/2XU0oxnq2qxCpomAAuJY8K?si=0a911e0ee3dc4bd7e')
  ];

  late Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  late StreamSubscription positionSub;
  late StreamSubscription stateSub;
  late AudioPlayer audioPlayer;
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;

  @override
  void initState(){
    super.initState();
    maMusiqueActuelle = maListeDeMusique[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red[400],
        centerTitle: true,
      ),
      backgroundColor: Colors.red[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height /2.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.5),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton(Icons.play_arrow, 45.0, ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle("0:0", .8),
                texteAvecStyle("0:22", .8)
              ],
            ),
            new Slider(value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                  setState(() {
                    Duration nouvelleDuration = new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                  });
                }
            )
          ],
        ),
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action){
    return new IconButton(
        iconSize: taille,
        color: Colors.white,
        onPressed: (){
          switch(action){
            case ActionMusic.play:
              print(('play'));
              break;
            case ActionMusic.pause:
              print(('pause'));
              break;
            case ActionMusic.forward:
              print(('forward'));
              break;
            case ActionMusic.rewind:
              print(('rewind'));
              break;
          }
        },
        icon: new Icon(icone));
  }
  Text texteAvecStyle(String data, double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      style: new TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontStyle: FontStyle.italic
      ),
    );
  }

  void configurationAudioPlayer(){
    audioPlayer = new AudioPlayer();

    positionSub = audioPlayer.onPositionChanged.listen(
            (pos) => setState(() => position = pos)
    );

    stateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == PlayerState.paying){
        setState(() {
          duree = audioPlayer.onDurationChanged as Duration;
        });
      }else if (state == PlayerState.stopped){
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    },  onError:(message){
      print('Erreur: $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    }
    );
  }

}

enum ActionMusic{
  play,
  pause,
  rewind,
  forward
}

enum PlayerState{
  paying,
  stopped,
  paused
}