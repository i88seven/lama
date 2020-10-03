import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

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
  static const MIN_PLAYER_COUNT = 2;
  DocumentReference _roomRef;
  StreamSubscription _changeSubscription;
  StreamSubscription _removeSubscription;
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
    _roomRef = FirebaseFirestore.instance
        .collection('preparationRooms')
        .doc(widget.roomId);
    _changeSubscription = _roomRef.snapshots().listen(_onChange);
    _roomRef.get().then((DocumentSnapshot snapshot) {
      Map<String, dynamic> data = snapshot.data();
      _hostMember = Member(
        uid: data['hostUid'],
        name: data['hostName'],
      );
    });
    super.initState();

    Future(() async {
      await _storage.ready;
      _myUid = _storage.getItem('myUid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(true);
        return Future.value(false);
      },
      child: Scaffold(
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
                    onPressed: _memberCount < MIN_PLAYER_COUNT
                        ? null
                        : () async {
                            _startGame();
                          },
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _changeSubscription.cancel();
    _removeSubscription.cancel();
    super.dispose();
  }

  void _onChange(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      _startGame();
    }

    Map<String, dynamic> data = snapshot.data();
    if (data == null || data.isEmpty) {
      return;
    }
    List<Map> snapshotMembers = List<Map>.from(data['members']);
    _memberList = [];
    snapshotMembers.forEach((Map snapshotMember) {
      Member member = Member(
        uid: snapshotMember['uid'],
        name: snapshotMember['name'],
      );
      setState(() {
        _memberList.add(member);
      });
    });
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
        await _roomRef.delete();
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
