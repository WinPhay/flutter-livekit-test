import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../exts.dart';
import '../pages/room.dart';
import '../utils.dart';
import '../widgets/widgets.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final wsUrl = 'wss://mydemo-kk8lxitw.livekit.cloud';
  final room = Room();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (lkPlatformIs(PlatformType.android)) {
      _checkPremissions();
    }
  }

  Future<void> _checkPremissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Permission disabled');
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Connect Permission disabled');
    }

    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      print('Camera Permission disabled');
    }

    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      print('Microphone Permission disabled');
    }
  }

  Future<void> _connect(BuildContext ctx) async {
    //
    try {
      setState(() {
        _busy = true;
      });

      var roomName = _roomController.text;
      var userName = _nameController.text;

      final input = <String, dynamic>{
        'room': roomName,
        'participant': userName
      };

      final response = await supabase.client.functions.invoke(
        'livekit-token',
        body: jsonEncode(input),
        method: HttpMethod.post,
      );

      print(response.data);

      final token = response.data['token'] as String?;
      if (token == null) {
        throw Exception('Could not generate token');
      } else {
        final listener = room.createListener();
        room.connect(wsUrl, token);
        await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => RoomPage(room, listener)),
      );
      }


      // await Navigator.push<void>(
      //   ctx,
      //   MaterialPageRoute(
      //       builder: (_) => PreJoinPage(
      //             args: JoinArgs(
      //               url: url,
      //               token: token,
      //               e2ee: _e2ee,
      //               e2eeKey: e2eeKey,
      //               simulcast: _simulcast,
      //               adaptiveStream: _adaptiveStream,
      //               dynacast: _dynacast,
      //               preferredCodec: _preferredCodec,
      //               enableBackupVideoCodec:
      //                   ['VP9', 'AV1'].contains(_preferredCodec),
      //             ),
      //           )),
      // );
    } catch (error) {
      print('Could not connect $error');
      await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: SvgPicture.asset(
                      'images/logo-dark.svg',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Room Name',
                      ctrl: _roomController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Participant Name',
                      ctrl: _nameController,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _busy ? null : () => _connect(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        const Text('CONNECT'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
