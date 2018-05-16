import 'dart:collection';
import 'dart:async';
import 'package:flutter/material.dart';

abstract class Character {}

// A Character that represents a Player
class PlayerCharacter implements Character {
  String label;
  String player;
  String role;

  PlayerCharacter([this.label = "Player", this.player = "", this.role = ""]);

  String toString() {
    if (player.length > 0) {
      return '$label ($player)';
    }
    else {
      return '$label';
    }
  }
}

// A Character that represents a Monster
class NonPlayerCharacter implements Character {
  String label;
  String monster;

  NonPlayerCharacter([this.label = "Monster", this.monster = ""]);

  String toString() {
    return '$label';
  }
}

class DualCharacter implements Character {
  String label;
  String player;
  String role;
  String monster;

  DualCharacter([this.label = "Multiple", this.player = "", this.role = "", this.monster = ""]);

  String toString() {
    return '$label';
  }
}

void main() => runApp(new GloomhavenInitiativeTracker());

class GloomhavenInitiativeTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gloomhaven Initiative Tracker',
      theme: new ThemeData(
        primaryColor: Colors.black,
        fontFamily: 'PirataOne',
      ),
      home: new InitiativeTracker(),
    );
  }
}

class InitiativeTracker extends StatefulWidget {
  @override
  createState() => new _InitiativeTrackerState();
}

class _InitiativeTrackerState extends State<InitiativeTracker> {
  final _activeInitiatives = new SplayTreeMap<int, Character>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Gloomhaven Initiative Tracker'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.help),
            onPressed: _showMainHelp,
          )
        ],
      ),
      body: /*new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child:*/ _buildInitiativeGrid(),
      //),
      floatingActionButton: new Tooltip(
        message: 'Show',
        child: new FloatingActionButton(
          child: const Icon(Icons.bookmark),
          onPressed: _pushActive,
          backgroundColor: _activeInitiatives.isNotEmpty ? Theme
              .of(context)
              .primaryColor : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInitiativeGrid() {
    return new OrientationBuilder(
      builder: (context, orientation) {
        return new GridView.builder(
          padding: new EdgeInsets.all(1.0),
          itemCount: 99,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: orientation == Orientation.portrait ? 5 : 10,
          ),
          itemBuilder: (context, i) {
            return _buildInitiativeSelector(i);
          },
        );
      },
    );
  }

  Widget _buildInitiativeSelector(int i) {
    int _display = i + 1;
    final _alreadySaved = _activeInitiatives.containsKey(_display);

    return new ListTile(
      title: new Container(
        child: new Center(
          child: new Text(
              '$_display',
              style: new TextStyle(
                fontSize: 24.0,
                color: _alreadySaved ? Colors.white : null,
                fontWeight: _alreadySaved ? FontWeight.bold : null,
              )
          ),
        ),
        decoration: new BoxDecoration(
          color: _alreadySaved ? _activeInitiatives[_display] is DualCharacter
              ? Colors.amber
              : _activeInitiatives[_display] is PlayerCharacter
              ? Colors.green
              : Colors.red : null,
        ),
      ),
      onTap: () {
        setState(() {
          if (_alreadySaved) {
            Character c = _activeInitiatives[_display];
            _activeInitiatives.remove(_display);
            if (c is PlayerCharacter) {
              _activeInitiatives[_display] = new NonPlayerCharacter();
            } else if (c is NonPlayerCharacter) {
              _activeInitiatives[_display] = new DualCharacter();
            }
          } else {
            _activeInitiatives[_display] = new PlayerCharacter();
          }
        });
      },
    );
  }

  void _pushActive() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = new List<Widget>();
          _activeInitiatives.forEach(
                (i, c) {
              Widget _displayTile = new Dismissible(
                key: new Key(i.toString()),
                onDismissed: (direction) {
                  _activeInitiatives.remove(i);
                  /*if (_activeInitiatives.isEmpty) {
                    _resetInitiative();
                  }*/
                },
                child: new ListTile(
                  leading: new IconButton(
                    icon: c is DualCharacter
                          ? const Icon(Icons.people)
                          : c is PlayerCharacter
                          ? const Icon(Icons.person)
                          : const Icon(Icons.adb),
                    color: c is DualCharacter
                           ? Colors.amber
                           : c is PlayerCharacter ? Colors.green : Colors.red,
                    onPressed: () {
                      setState(() {

                      });
                    },
                  ),
                  title: new Text(
                    '$i',
                    style: new TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: new Text(
                      c.toString(),
                      style: new TextStyle(
                        fontSize: 16.0,
                      )
                  ),
                ),
              );
              tiles.add(_displayTile);
            },
          );

          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Active Initiatives'),
              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.help),
                  onPressed: _showActiveHelp,
                )
              ],
            ),
            body: new Center(
              child: ListView(children: divided),
            ),
            floatingActionButton: new Tooltip(
              message: 'Reset',
              child: new FloatingActionButton(
                child: const Icon(Icons.autorenew),
                onPressed: _resetInitiative,
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  void _strikeInitiative() {
  }

  void _resetInitiative() {
    _activeInitiatives.clear();
    Navigator.of(context).maybePop();
  }

  Future<Null> _showMainHelp() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Welcome!'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('• Tap once to set initiative for a player (green).'),
                new Text('• Tap again to set initiative for a monster (red).'),
                new Text('• Tap a third time to set initiative for mulitple characters (amber).'),
                new Text('• Press the button to see the initiative order.'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> _showActiveHelp() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Active Initiatives'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('• Swipe to clear an initiative.'),
                new Text('• Tap back arrow to add new initiatives.'),
                new Text('• Press the button to reset all initiatives.'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
