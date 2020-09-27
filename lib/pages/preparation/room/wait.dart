import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localstorage/localstorage.dart';

import 'package:lama/pages/preparation/main.dart';
import 'package:lama/lama_game.dart';
import 'package:lama/components/member.dart';

class RoomWaitPage extends StatefulWidget {
  String title = '待機中...';
  final String roomId;

  RoomWaitPage({this.roomId});

  @override
  State<StatefulWidget> createState() => _RoomWaitPageState();
}

class _RoomWaitPageState extends State<RoomWaitPage> {
  DatabaseReference _roomRef;
  List<Member> _memberList = [];
  Member _hostMember;
  LocalStorage _storage = LocalStorage('lama_game');
  String _myUid = '';

  int get _memberCount {
    return _memberList.length;
  }

  bool get _isHost {
    return _hostMember != null && _myUid == _hostMember.uid;
  }

  @override
  void initState() {
    widget.title = "${widget.roomId} 待機中...";
    _memberList = [];
    _roomRef = FirebaseDatabase.instance
        .reference()
        .child('preparationRooms')
        .child(widget.roomId);
    _roomRef.onChildChanged.listen(_onChangeMember);
    _roomRef.onChildRemoved.listen(_onRemoveRoom);
    Map snapshotMembers;
    _roomRef.once().then((DataSnapshot snapshot) {
      _hostMember = Member(
        uid: snapshot.value['hostUid'],
        name: snapshot.value['hostName'],
      );
      snapshotMembers = Map.from(snapshot.value['members'] ?? {});
      snapshotMembers.forEach((uid, name) {
        Member member = Member(uid: uid, name: name);
        setState(() {
          _memberList.add(member);
        });
      });
    });
    super.initState();

    Future(() async {
      await _storage.ready;
      _myUid = _storage.getItem('myUid');
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
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, index) {
                return ListTile(
                  title: Text(_memberList[index].name),
                );
              },
              itemCount: _memberCount,
            ),
            if (_isHost)
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Text("$_memberCount 人で始める"),
                  onPressed: () async {
                    _startGame();
                  },
                ),
              ),
          ],
        );
      }),
    );
  }

  void _onChangeMember(Event e) {
    if (e.snapshot.key != 'members') {
      return;
    }

    Map snapshotMembers = Map.from(e.snapshot.value ?? {});
    _memberList = [];
    snapshotMembers.forEach((uid, name) {
      Member member = Member(uid: uid, name: name);
      setState(() {
        _memberList.add(member);
      });
    });
  }

  void _onRemoveRoom(Event e) {
    if (e.snapshot.key == 'members') {
      _startGame();
    }
  }

  void _startGame() async {
    try {
      Flame.images.loadAll(<String>[
        'card-7.png',
      ]);
      Size screenSize = MediaQuery.of(context).size;
      final game = LamaGame(widget.roomId, screenSize, _onGameEnd);
      if (_isHost) {
        await game.initializeHost();
        await _roomRef.remove();
      } else {
        await game.initializeSlave(hostUid: _hostMember.uid);
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => game.widget),
      );
    } catch (e) {}
  }

  void _onGameEnd() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
}
