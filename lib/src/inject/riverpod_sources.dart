import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/data/sources/api_source.dart';
import 'package:jenix_event_manager/src/data/sources/jenix/jenix_api_source_impl.dart';
import 'package:jenix_event_manager/src/data/sources/key_source.dart';
import 'package:jenix_event_manager/src/data/sources/share_preference_key_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_sources.g.dart';

@riverpod
KeySource keySource(Ref ref) {
  ref.keepAlive();
  return SharePreferenceKeySource();
}

@riverpod
APISource jenixSource(Ref ref) {
  ref.keepAlive();
  return JenixAPISourceImpl(
    keySource: ref.watch(keySourceProvider),
  );
}
