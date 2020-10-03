import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

import 'package:lama/components/member.dart';
import 'package:lama/pages/preparation/room/wait.dart';

class RoomSearchPage extends StatefulWidget {
  final String title = '部屋を検索';

  @override
  State<StatefulWidget> createState() => _RoomSearchPageState();
}

class _RoomSearchPageState extends State<RoomSearchPage> {
  CollectionReference _roomRef;
  final LocalStorage _storage = new LocalStorage('lama_game');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomIdController = TextEditingController();
  String _myUid = '';
  String _roomId;
  Member _host;
  bool _isNoResult = false;

  bool get _hasRoom {
    return _roomId != null && _host != null && _host.uid != null;
  }

  @override
  void initState() {
    _roomRef = FirebaseFirestore.instance.collection('preparationRooms');
    super.initState();

    Future(() async {
      await _storage.ready;
      _myUid = _storage.getItem('myUid');
      _roomIdController.text = _storage.getItem('searchRoomId');
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
                          child: Text('検索'),
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
            ),
            if (_isNoResult)
              ListView(
                children: [
                  Text(
                    '見つかりませんでした',
                    style: TextStyle(fontSize: 18.0, color: Colors.yellow[300]),
                  ),
                ],
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            if (_hasRoom)
              ListView(
                children: [
                  Text(
                    "部屋ID: $_roomId",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Text(
                    "ホスト名: ${_host.name}",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            if (_hasRoom)
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Text('入る'),
                  onPressed: () async {
                    _participateGame(roomId: _roomId);
                  },
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

  void _searchRoom() async {
    try {
      DocumentSnapshot snapshot =
          await _roomRef.doc(_roomIdController.text).get();
      if (!snapshot.exists) {
        setState(() {
          _roomId = null;
          _host = null;
          _isNoResult = true;
        });
        return;
      }
      Map<String, dynamic> data = snapshot.data();
      setState(() {
        _roomId = snapshot.id;
        _host = Member(
          uid: data['hostUid'],
          name: data['hostName'],
        );
        _isNoResult = false;
      });
    } catch (e) {}
  }

  void _participateGame({roomId: String}) {
    try {
      String myName = _storage.getItem('myName') ?? '';
      // TODO myName 取得できなかったらエラー
      _roomRef.doc(roomId).update({
        'members': FieldValue.arrayUnion([
          {'uid': _myUid, 'name': myName}
        ])
      });
      _storage.setItem('searchRoomId', _roomIdController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RoomWaitPage(roomId: roomId)),
      );
    } catch (e) {}
  }
}
