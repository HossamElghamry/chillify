import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_app/src/blocs/global.dart';
import 'package:music_app/src/models/playerstate.dart';
import 'package:music_app/src/ui/device_music/bottom_panel.dart';
import 'package:music_app/src/ui/device_music/song_tile.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DeviceMusicScreen extends StatefulWidget {
  @override
  _DeviceMusicScreenState createState() => _DeviceMusicScreenState();
}

class _DeviceMusicScreenState extends State<DeviceMusicScreen> {
  PanelController _controller;

  @override
  void initState() {
    _controller = PanelController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 1,
              color: Color(0xFFD9EAF1),
            ),
          ),
        ),
        title: Text(
          "Device Music",
          style: TextStyle(
            color: Color(0xFF274D85),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.search,
              size: 32,
              color: Color(0xFF274D85),
            ),
          )
        ],
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: SlidingUpPanel(
        controller: _controller,
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        collapsed: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.8,
              ],
              colors: [
                Color(0xFF4D90CD),
                Color(0xFFDF5F9D),
              ],
            ),
          ),
          child: BottomPanel(controller: _controller),
        ),
        body: StreamBuilder<List<Song>>(
          stream: _globalBloc.musicPlayerBloc.songs$,
          builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final List<Song> _songs = snapshot.data;

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _songs.length + 2,
              itemExtent: 90,
              itemBuilder: (BuildContext context, int index) {
                if (index >= _songs.length) {
                  return Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.transparent,
                  );
                }

                return StreamBuilder<MapEntry<PlayerState, Song>>(
                  stream: _globalBloc.musicPlayerBloc.playerState$,
                  builder: (BuildContext context,
                      AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    final PlayerState _state = snapshot.data.key;
                    final Song _currentSong = snapshot.data.value;
                    final bool _isSelectedSong = _currentSong == _songs[index];
                    return GestureDetector(
                      onTap: () {
                        _globalBloc.musicPlayerBloc.updatePlaylist(_songs);
                        switch (_state) {
                          case PlayerState.playing:
                            if (_isSelectedSong) {
                              _globalBloc.musicPlayerBloc
                                  .pauseMusic(_currentSong);
                            } else {
                              _globalBloc.musicPlayerBloc.stopMusic();
                              _globalBloc.musicPlayerBloc.playMusic(
                                _songs[index],
                              );
                            }
                            break;
                          case PlayerState.paused:
                            if (_isSelectedSong) {
                              _globalBloc.musicPlayerBloc
                                  .playMusic(_songs[index]);
                            } else {
                              _globalBloc.musicPlayerBloc.stopMusic();
                              _globalBloc.musicPlayerBloc.playMusic(
                                _songs[index],
                              );
                            }
                            break;
                          case PlayerState.stopped:
                            _globalBloc.musicPlayerBloc
                                .playMusic(_songs[index]);
                            break;
                          default:
                            break;
                        }
                      },
                      child: SongTile(
                        song: _songs[index],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
