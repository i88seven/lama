import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoomWaitPage extends StatefulWidget {
  final String title = '待機中...';
  final User user;
  final String roomId;

  RoomWaitPage({this.user, this.roomId});

  @override
  State<StatefulWidget> createState() => _RoomWaitPageState();
}

class _RoomWaitPageState extends State<RoomWaitPage> {
  DatabaseReference _roomRef;
  List<dynamic> _memberList = [];

  int get memberCount {
    return _memberList.length;
  }

  @override
  Widget build(BuildContext context) {
    _roomRef = FirebaseDatabase.instance
        .reference()
        .child('preparationRooms')
        .child(widget.roomId);
    _roomRef.onChildChanged.listen(_onChangeMember);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, index) {
                return ListTile(
                  title: Text(_memberList[index]['name']),
                );
              },
              itemCount: memberCount,
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                child: Text("$memberCount 人で始める"),
                onPressed: () async {
                  _startGame(widget.user);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _onChangeMember(Event e) {
    print(e.snapshot.value);
    setState(() {
      _memberList = List<dynamic>.from(e.snapshot.value ?? []);
      print(_memberList);
    });
  }
}

void _startGame(User user) async {
  try {
    // TODO 待機部屋を削除

    // TODO 画面遷移
  } catch (e) {}
}
