import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/constants/xp_constants.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository();
});

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PlayerNotifier(repo);
});

// ── Player State ──────────────────────────────────────────────────────────────
class PlayerState {
  final PlayerModel? player;
  final bool isLoading;
  final bool justLeveledUp;
  final int newLevel;
  final bool justGainedRank;   // new rank promotion
  final String newRank;
  final bool justTerminated;   // rank termination event

  const PlayerState({
    this.player,
    this.isLoading = false,
    this.justLeveledUp = false,
    this.newLevel = 1,
    this.justGainedRank = false,
    this.newRank = 'F',
    this.justTerminated = false,
  });

  // ── Computed getters ───────────────────────────────────────────

  int get level =>
      player != null ? XpCalculator.levelFromTotalXp(player!.totalXp) : 1;

  /// Current rank is the highestRank field — never drops with XP.
  String get rank => player?.highestRank ?? 'F';

  /// XP progress toward the NEXT rank milestone (using peakXp).
  double get rankProgress =>
      player != null ? XpCalculator.rankProgress(player!.peakXp) : 0.0;

  /// Progress within the current level (for the XP bar fill).
  /// Uses totalXp (current, can drop).
  double get xpProgress =>
      player != null ? XpCalculator.levelProgress(player!.totalXp) : 0.0;

  int get currentLevelXp =>
      player != null ? XpCalculator.currentLevelXp(player!.totalXp) : 0;

  int get xpToNextLevel => XpCalculator.xpNeededForLevel(level);

  /// XP needed to reach the next rank milestone.
  int? get xpToNextRank =>
      player != null ? XpCalculator.xpToNextRank(player!.peakXp) : null;

  PlayerState copyWith({
    PlayerModel? player,
    bool? isLoading,
    bool? justLeveledUp,
    int? newLevel,
    bool? justGainedRank,
    String? newRank,
    bool? justTerminated,
  }) {
    return PlayerState(
      player:         player         ?? this.player,
      isLoading:      isLoading      ?? this.isLoading,
      justLeveledUp:  justLeveledUp  ?? this.justLeveledUp,
      newLevel:       newLevel       ?? this.newLevel,
      justGainedRank: justGainedRank ?? this.justGainedRank,
      newRank:        newRank        ?? this.newRank,
      justTerminated: justTerminated ?? this.justTerminated,
    );
  }
}

// ── Player Notifier ───────────────────────────────────────────────────────────
class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerRepository _repo;

  PlayerNotifier(this._repo) : super(const PlayerState()) {
    _load();
  }

  void _load() {
    final player = _repo.getPlayer();
    state = state.copyWith(player: player);
  }

  Future<void> createPlayer(String name) async {
    state = state.copyWith(isLoading: true);
    final player = await _repo.createPlayer(name);
    await _repo.updateStreak();
    state = state.copyWith(player: player, isLoading: false);
  }

  /// Award XP and check for rank promotion / level up.
  Future<void> gainXp(int amount) async {
    if (amount <= 0) return;
    final oldRank  = state.rank;
    final oldLevel = state.level;

    final player = await _repo.addXp(amount);

    final newLevel = XpCalculator.levelFromTotalXp(player.totalXp);
    final newRank  = player.highestRank;

    // Stat points for level ups
    if (newLevel > oldLevel) {
      player.statPoints +=
          (newLevel - oldLevel) * XpConstants.statPointsPerLevel;
      await _repo.savePlayer(player);
      state = state.copyWith(
        player: player,
        justLeveledUp: true,
        newLevel: newLevel,
      );
    }

    // Rank promotion notification
    if (newRank != oldRank) {
      state = state.copyWith(
        player: player,
        justGainedRank: true,
        newRank: newRank,
      );
    } else {
      state = state.copyWith(player: player);
    }
  }

  /// Deduct XP (habit penalty, important quest failure).
  /// Rank is never affected.
  Future<void> loseXp(int amount) async {
    if (amount <= 0) return;
    final player = await _repo.removeXp(amount);
    state = state.copyWith(player: player);
  }

  /// Trigger rank termination (legendary quest failure only).
  Future<void> triggerRankTermination() async {
    final player = await _repo.applyRankTermination();
    state = state.copyWith(
      player: player,
      justTerminated: true,
    );
  }

  void clearLevelUp()      => state = state.copyWith(justLeveledUp: false);
  void clearRankGain()     => state = state.copyWith(justGainedRank: false);
  void clearTermination()  => state = state.copyWith(justTerminated: false);

  Future<void> allocateStat(String stat) async {
    final success = await _repo.allocateStat(stat);
    if (success) state = state.copyWith(player: _repo.getPlayer());
  }

  void refresh() => _load();
}