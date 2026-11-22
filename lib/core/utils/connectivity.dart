import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// only knows if wifi or mobile data is on, not if the internet really works
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _offline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_offline);
});

bool _offline(List<ConnectivityResult> results) =>
    results.every((r) => r == ConnectivityResult.none);
