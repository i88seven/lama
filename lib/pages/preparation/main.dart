import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                widget.user.uid,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
            ),
            _PreparationMainForm(),
          ],
        );
      }),
    );
  }
}

class _PreparationMainForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PreparationMainFormState();
}

class _PreparationMainFormState extends State<_PreparationMainForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myNameController = TextEditingController();

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
        ));
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  void _createRoom() async {
    try {
      // TODO database に登録

      // TODO 画面遷移
    } catch (e) {}
  }

  void _searchRoom() async {
    try {
      // TODO 画面遷移
    } catch (e) {}
  }
}
