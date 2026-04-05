import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../meditation/providers/meditation_providers.dart';

/// Global key for showing sync failure snackbars from anywhere
final syncScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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
    // Listen for connectivity changes and auto-sync silently in the background
    _ref.listen(hasInternetProvider, (previous, next) {
      if (next && !state.isSyncing) {
        syncAll(showNotification: false);
      }
    });
  }

  /// Sync all pending sessions
  Future<void> syncAll({bool showNotification = false}) async {
    final repo = _ref.read(meditationRepositoryProvider);
    final pending = repo.getPendingSessions();

    if (pending.isEmpty) {
      state = state.copyWith(pendingCount: 0);
      return;
    }

    // Check if we have internet *before* trying
    final hasInternet = _ref.read(hasInternetProvider);
    if (!hasInternet) {
      state = state.copyWith(
        pendingCount: pending.length,
        error: 'No internet connection',
      );
      if (showNotification) {
        _showSyncFailureNotification(
          'Sync failed — No internet connection. '
          '${pending.length} session${pending.length > 1 ? 's' : ''} pending.',
        );
      }
      return;
    }

    state = state.copyWith(isSyncing: true, pendingCount: pending.length, error: null);

    try {
      final synced = await repo.syncAllPending();
      final remaining = pending.length - synced;
      state = state.copyWith(
        isSyncing: false,
        pendingCount: remaining,
        lastSyncTime: DateTime.now(),
      );
      if (remaining > 0 && showNotification) {
        _showSyncFailureNotification(
          'Sync incomplete — $remaining session${remaining > 1 ? 's' : ''} '
          'could not be synced. Will retry when online.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
      if (showNotification) {
        _showSyncFailureNotification(
          'Sync failed — ${pending.length} session${pending.length > 1 ? 's' : ''} '
          'pending. Check your connection.',
        );
      }
    }
  }

  /// Show a snackbar notification for sync failures
  void _showSyncFailureNotification(String message) {
    final messenger = syncScaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.clearSnackBars(); // Ensure old snackbars don't pile up and freeze the UI
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          duration: const Duration(seconds: 2),
        ),
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
