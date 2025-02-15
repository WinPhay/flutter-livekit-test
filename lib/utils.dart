import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

FutureOr<void> Function()? onWindowShouldClose;
Supabase supabase = Supabase.instance;