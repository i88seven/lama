import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lama/pages/preparation/room/wait.dart';

class RoomCreatePage extends StatefulWidget {
  final String title = '部屋の作成';
  final User user;

  RoomCreatePage({this.user});

  @override
  State<StatefulWidget> createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends State<RoomCreatePage> {
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
            _RoomCreateForm(user: widget.user),
          ],
        );
      }),
    );
  }
}

class _RoomCreateForm extends StatefulWidget {
  final User user;

  _RoomCreateForm({this.user});

  @override
  State<StatefulWidget> createState() => _RoomCreateFormState();
}

class _RoomCreateFormState extends State<_RoomCreateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomIdController = TextEditingController();
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

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
                  controller: _roomIdController,
                  decoration: const InputDecoration(labelText: '部屋ID'),
                  validator: (String value) {
                    if (value.isEmpty) return '入力してください';
                    return null;
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: RaisedButton(
                    child: Text('作成'),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _createRoom(widget.user);
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
    _roomIdController.dispose();
    super.dispose();
  }

  void _createRoom(User user) async {
    try {
      String myName = 'test'; // TODO localstorage から取得
      // TODO すでに存在していて、自分以外が作っていたらエラー
      _databaseReference.child('preparationRooms').set({
        _roomIdController.text: {
          'hostUid': user.uid,
          'hostName': myName,
          'members': [
            {'uid': user.uid, 'name': myName}
          ]
        }
      });

      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => RoomWaitPage(
                  user: user,
                  roomId: _roomIdController.text,
                )),
      );
    } catch (e) {}
  }
}
