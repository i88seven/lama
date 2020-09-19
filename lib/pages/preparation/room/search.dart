import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lama/components/member.dart';
import 'package:lama/pages/preparation/room/wait.dart';

class RoomSearchPage extends StatefulWidget {
  final String title = '部屋を検索';
  final User user;

  RoomSearchPage({this.user});

  @override
  State<StatefulWidget> createState() => _RoomSearchPageState();
}

class _RoomSearchPageState extends State<RoomSearchPage> {
  DatabaseReference _roomRef;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomIdController = TextEditingController();
  String _roomId;
  Member _host;

  bool get hasRoom {
    return _roomId != null && _host != null && _host.uid != null;
  }

  @override
  void initState() {
    _roomRef = FirebaseDatabase.instance.reference().child('preparationRooms');
    super.initState();
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
                                setState(() {
                                  _searchRoom();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            if (this.hasRoom)
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
            if (this.hasRoom)
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Text('入る'),
                  onPressed: () async {
                    _participateGame(roomId: _roomId, user: widget.user);
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
      DataSnapshot snapshot =
          await _roomRef.child(_roomIdController.text).once();
      if (snapshot.value['hostUid'] != null) {
        setState(() {
          _roomId = _roomIdController.text;
          _host = Member(
            uid: snapshot.value['hostUid'],
            name: snapshot.value['hostName'],
          );
        });
      }
    } catch (e) {}
  }

  void _participateGame({roomId: String, user: User}) {
    try {
      String myName = 'participant'; // TODO localstorage から取得
      _roomRef.child(roomId).child('members').child(user.uid).set(myName);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => RoomWaitPage(
                  user: user,
                  roomId: roomId,
                )),
      );
    } catch (e) {}
  }
}
