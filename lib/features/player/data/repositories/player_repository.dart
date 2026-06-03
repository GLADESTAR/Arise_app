import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/constants/xp_constants.dart';
import '../models/player_model.dart';

class PlayerRepository {
  static const String _boxName   = 'player';
  static const String _playerKey = 'current_player';

  static Future<void> init() async {
    await Hive.openBox<PlayerModel>(_boxName);
  }

  Box<PlayerModel> get _box => Hive.box<PlayerModel>(_boxName);

  PlayerModel? getPlayer() => _box.get(_playerKey);
  bool get playerExists     => _box.containsKey(_playerKey);

  Future<PlayerModel> createPlayer(String name) async {
    final player = PlayerModel.newPlayer(
      name: name,
      id: IdGenerator.generate(),
    );
    await _box.put(_playerKey, player);
    return player;
  }

  Future<void> savePlayer(PlayerModel player) async {
    await _box.put(_playerKey, player);
  }

  /// Adds XP, updates peakXp and rank milestone. Returns updated player.
  Future<PlayerModel> addXp(int amount) async {
    final player = getPlayer();
    if (player == null) throw Exception('No player found');

    player.totalXp += amount;
    if (player.totalXp < 0) player.totalXp = 0; // Floor at 0

    // Update peak
    if (player.totalXp > player.peakXp) {
      player.peakXp = player.totalXp;
    }

    // Check if a new rank milestone was reached
    _updateRankMilestone(player);

    await savePlayer(player);
    return player;
  }

  /// Subtracts XP (from habit failure or quest failure).
  /// XP cannot go below 0. Rank is NOT affected.
  Future<PlayerModel> removeXp(int amount) async {
    final player = getPlayer();
    if (player == null) throw Exception('No player found');

    player.totalXp = (player.totalXp - amount).clamp(0, 999999999);
    // Note: peakXp and highestRank are NOT changed here
    await savePlayer(player);
    return player;
  }

  /// Applies rank termination — demotes rank, preserves XP.
  Future<PlayerModel> applyRankTermination() async {
    final player = getPlayer();
    if (player == null) throw Exception('No player found');

    player.highestRank =
        XpCalculator.applyRankTermination(player.highestRank);
    player.rankTerminations++;

    // Also demote peakXp to the new rank's threshold so
    // the player has to re-earn their way back
    final newThreshold =
        XpConstants.rankXpThresholds[player.highestRank] ?? 0;
    if (player.peakXp > newThreshold) {
      player.peakXp = newThreshold;
    }

    await savePlayer(player);
    return player;
  }

  /// Checks if the player now qualifies for Monarch.
  Future<bool> checkAndGrantMonarch(double completionRate) async {
    final player = getPlayer();
    if (player == null) return false;
    if (player.isMonarch) return false;

    final qualifies = XpCalculator.meetsMonarchRequirements(
      totalXp:                   player.totalXp,
      longestStreak:             player.longestStreak,
      completionRate:            completionRate,
      legendaryQuestsCompleted:  player.legendaryQuestsCompleted,
      rankTerminations:          player.rankTerminations,
    );

    if (qualifies) {
      player.isMonarch = true;
      player.highestRank = 'Monarch';
      await savePlayer(player);
      return true;
    }
    return false;
  }

  /// Internal: promotes rank based on peakXp milestones.
  void _updateRankMilestone(PlayerModel player) {
    if (player.isMonarch) return;

    final earned = XpCalculator.rankForXpMilestone(player.peakXp);
    final earnedIndex = XpCalculator.rankIndex(earned);
    final currentIndex = XpCalculator.rankIndex(player.highestRank);

    if (earnedIndex > currentIndex) {
      player.highestRank = earned;
    }
  }

  Future<bool> allocateStat(String stat) async {
    final player = getPlayer();
    if (player == null || player.statPoints <= 0) return false;
    switch (stat.toUpperCase()) {
      case 'STR': player.statStr++;
      case 'INT': player.statInt++;
      case 'CRE': player.statCre++;
      case 'CHA': player.statCha++;
      case 'SKL': player.statSkl++;
      default: return false;
    }
    player.statPoints--;
    await savePlayer(player);
    return true;
  }

  Future<void> updateStreak() async {
    final player = getPlayer();
    if (player == null) return;

    final today = DateTime.now().toIso8601String().split('T').first;
    if (player.lastActiveDate == today) return;

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;

    if (player.lastActiveDate == yesterday) {
      player.currentStreak++;
    } else {
      player.currentStreak = 1;
    }

    if (player.currentStreak > player.longestStreak) {
      player.longestStreak = player.currentStreak;
    }

    player.lastActiveDate = today;
    await savePlayer(player);
  }
}