import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:intl/intl.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekitapp/app/app.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'pages/connect.dart';
import 'theme.dart';
import 'utils.dart';

void main() async {
  final format = DateFormat('HH:mm:ss');
  // configure logs for debugging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${format.format(record.time)}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kaheidysrxmaoepfvkeo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImthaGVpZHlzcnhtYW9lcGZ2a2VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM0NDkwMDksImV4cCI6MjAzOTAyNTAwOX0.Z16C4QgY-5vy-MTCYP99onX9NuQqMtYlXeP2DZi7gNY',
  );

  if (lkPlatformIsDesktop()) {
    await FlutterWindowClose.setWindowShouldCloseHandler(() async {
      await onWindowShouldClose?.call();
      return true;
    });
  }

  runApp(const LiveKitExampleApp());
}

class LiveKitExampleApp extends StatelessWidget {
  //
  const LiveKitExampleApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LiveKit Flutter Example',
        theme: LiveKitTheme().buildThemeData(context),
        home: const MyApp(),
      );
}