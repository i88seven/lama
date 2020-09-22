import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lama/lama_game.dart';
import 'package:lama/components/member.dart';

class RoomWaitPage extends StatefulWidget {
  String title = '待機中...';
  final User user;
  final String roomId;

  RoomWaitPage({this.user, this.roomId});

  @override
  State<StatefulWidget> createState() => _RoomWaitPageState();
}

class _RoomWaitPageState extends State<RoomWaitPage> {
  DatabaseReference _roomRef;
  List<Member> _memberList = [];
  Member _hostMember;

  int get memberCount {
    return _memberList.length;
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
              itemCount: memberCount,
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                child: Text("$memberCount 人で始める"),
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
      Size screenSize = MediaQuery.of(context).size;
      final game = LamaGame(
          user: widget.user, roomId: widget.roomId, screenSize: screenSize);
      if (widget.user.uid == _hostMember.uid) {
        await game.initializeHost();
        _roomRef.remove();
      } else {
        await game.initializeSlave(hostUid: _hostMember.uid);
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => game.widget),
      );
    } catch (e) {}
  }
}
