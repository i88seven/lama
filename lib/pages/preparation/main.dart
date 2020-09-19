import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstorage/localstorage.dart';

import 'package:lama/pages/preparation/room/create.dart';
import 'package:lama/pages/preparation/room/search.dart';

class PreparationMainPage extends StatefulWidget {
  final String title = 'Lama';
  final User user;

  PreparationMainPage({this.user});

  @override
  State<StatefulWidget> createState() => _PreparationMainPageState();
}

class _PreparationMainPageState extends State<PreparationMainPage> {
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
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                widget.user == null ? '' : widget.user.uid,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
            ),
            _PreparationMainForm(user: widget.user),
          ],
        );
      }),
    );
  }
}

class _PreparationMainForm extends StatefulWidget {
  final User user;

  _PreparationMainForm({this.user});

  @override
  State<StatefulWidget> createState() => _PreparationMainFormState();
}

class _PreparationMainFormState extends State<_PreparationMainForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalStorage _storage = new LocalStorage('lama_game');
  final TextEditingController _myNameController = TextEditingController();

  @override
  void initState() {
    // TODO セットされない
    _myNameController.text = _storage.getItem('myName');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
                        _createRoom(widget.user);
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
                        _searchRoom(widget.user);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  void _createRoom(User user) async {
    try {
      _storage.setItem('myName', _myNameController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RoomCreatePage(user: user)),
      );
    } catch (e) {}
  }

  void _searchRoom(User user) async {
    try {
      _storage.setItem('myName', _myNameController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RoomSearchPage(user: user)),
      );
    } catch (e) {}
  }
}
