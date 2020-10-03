import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:lama/pages/preparation/room/wait.dart';

class RoomCreatePage extends StatefulWidget {
  final String title = '部屋の作成';

  @override
  State<StatefulWidget> createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends State<RoomCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomIdController = TextEditingController();
  LocalStorage _storage = LocalStorage('lama_game');
  String _myUid = '';

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _storage.ready;
      _myUid = _storage.getItem('myUid');
      _roomIdController.text = _storage.getItem('myRoomId');
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
                        controller: _roomIdController,
                        decoration: const InputDecoration(labelText: '部屋ID'),
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
                          child: Text('作成'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _createRoom();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _createRoom() async {
    try {
      String myName = _storage.getItem('myName') ?? '';
      // TODO myName 取得できなかったらエラー
      // TODO すでに存在していて、自分以外が作っていたらエラー
      DocumentReference roomRef = FirebaseFirestore.instance
          .collection('preparationRooms')
          .doc(_roomIdController.text);
      await roomRef.set({
        'hostUid': _myUid,
        'hostName': myName,
        'members': FieldValue.arrayUnion([
          {'uid': _myUid, 'name': myName}
        ])
      });
      _storage.setItem('myRoomId', _roomIdController.text);

      bool shouldDelete = await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (context) => RoomWaitPage(
            roomId: _roomIdController.text,
          ),
        ),
      );
      if (shouldDelete) {
        roomRef.delete();
      }
    } catch (e) {}
  }
}
