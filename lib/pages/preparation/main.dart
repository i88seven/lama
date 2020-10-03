import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'package:lama/pages/preparation/room/create.dart';
import 'package:lama/pages/preparation/room/search.dart';

class PreparationMainPage extends StatefulWidget {
  final String title = 'Lama';

  @override
  State<StatefulWidget> createState() => _PreparationMainPageState();
}

class _PreparationMainPageState extends State<PreparationMainPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myNameController = TextEditingController();
  LocalStorage _storage = LocalStorage('lama_game');

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _storage.ready;
      _myNameController.text = _storage.getItem('myName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _myNameController,
                        decoration: const InputDecoration(labelText: '表示名'),
                        maxLength: 10,
                        validator: (String value) {
                          if (value.isEmpty) return '入力してください';
                          return null;
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: RaisedButton(
                          child: Text('部屋を立てる'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _createRoom();
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: RaisedButton(
                          child: Text('部屋を探す'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _searchRoom();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  void _createRoom() async {
    try {
      _storage.setItem('myName', _myNameController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RoomCreatePage()),
      );
    } catch (e) {}
  }

  void _searchRoom() async {
    try {
      _storage.setItem('myName', _myNameController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RoomSearchPage()),
      );
    } catch (e) {}
  }
}
