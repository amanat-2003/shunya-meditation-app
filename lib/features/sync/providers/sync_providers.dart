import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../meditation/providers/meditation_providers.dart';

/// Connectivity stream provider
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Whether device has internet
final hasInternetProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.whenOrNull(
        data: (results) => results.any((r) => r != ConnectivityResult.none),
      ) ??
      false;
});

/// Sync state
final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  return SyncStateNotifier(ref);
});

class SyncState {
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final String? error;

  const SyncState({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncTime,
    this.error,
  });

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncTime,
    String? error,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error,
    );
  }
}

class SyncStateNotifier extends StateNotifier<SyncState> {
  final Ref _ref;

  SyncStateNotifier(this._ref) : super(const SyncState()) {
    // Listen for connectivity changes and auto-sync
    _ref.listen(hasInternetProvider, (previous, next) {
      if (next && !state.isSyncing) {
        syncAll();
      }
    });
  }

  /// Sync all pending sessions
  Future<void> syncAll() async {
    final repo = _ref.read(meditationRepositoryProvider);
    final pending = repo.getPendingSessions();

    if (pending.isEmpty) {
      state = state.copyWith(pendingCount: 0);
      return;
    }

    state = state.copyWith(isSyncing: true, pendingCount: pending.length, error: null);

    try {
      final synced = await repo.syncAllPending();
      state = state.copyWith(
        isSyncing: false,
        pendingCount: pending.length - synced,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  /// Check for pending sessions on launch
  Future<bool> hasPendingSessions() async {
    final repo = _ref.read(meditationRepositoryProvider);
    final pending = repo.getPendingSessions();
    state = state.copyWith(pendingCount: pending.length);
    return pending.isNotEmpty;
  }
}
