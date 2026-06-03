import '../constants/xp_constants.dart';

/// All XP math and rank logic.
/// Pure Dart — no Flutter, no Hive. Fully testable.
class XpCalculator {
  XpCalculator._();

  // ── XP / Level (kept for backward compat with stats screen) ───

  static int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += xpNeededForLevel(i);
    }
    return total;
  }

  static int xpNeededForLevel(int level) {
    return (XpConstants.xpBaseAmount * level * XpConstants.xpScalingFactor)
        .round();
  }

  static int levelFromTotalXp(int totalXp) {
    int level = 1;
    while (totalXp >= totalXpForLevel(level + 1)) {
      level++;
      if (level >= 100) break;
    }
    return level;
  }

  static int currentLevelXp(int totalXp) {
    int level = levelFromTotalXp(totalXp);
    return totalXp - totalXpForLevel(level);
  }

  static double levelProgress(int totalXp) {
    int level = levelFromTotalXp(totalXp);
    int currentXp = currentLevelXp(totalXp);
    int needed = xpNeededForLevel(level);
    if (needed == 0) return 1.0;
    return (currentXp / needed).clamp(0.0, 1.0);
  }

  // ── New Rank System ────────────────────────────────────────────

  /// Returns the highest rank the player has EARNED based on
  /// their all-time peak XP milestone. XP loss does not reduce rank.
  static String rankForXpMilestone(int peakXp) {
    String earned = 'F';
    for (final rank in XpConstants.ranks) {
      final threshold = XpConstants.rankXpThresholds[rank] ?? 0;
      if (peakXp >= threshold && rank != 'Monarch') {
        earned = rank;
      }
    }
    return earned;
  }

  /// Returns the rank index in the ranks list (0 = F, 9 = Monarch).
  static int rankIndex(String rank) {
    return XpConstants.ranks.indexOf(rank).clamp(0, XpConstants.ranks.length - 1);
  }

  /// Demotes rank by one step. Used for rank termination.
  static String demoteRank(String currentRank) {
    final index = rankIndex(currentRank);
    if (index <= 0) return 'F';
    return XpConstants.ranks[index - 1];
  }

  /// Applies rank termination based on configured mode.
  static String applyRankTermination(String currentRank) {
    if (XpConstants.rankTerminationMode == 'full_reset') {
      return 'F';
    }
    return demoteRank(currentRank);
  }

  /// Returns the XP threshold needed to reach the next rank.
  static int? xpToNextRank(int peakXp) {
    for (final rank in XpConstants.ranks) {
      if (rank == 'Monarch') continue;
      final threshold = XpConstants.rankXpThresholds[rank] ?? 0;
      if (peakXp < threshold) return threshold;
    }
    return null; // Already at top earnable rank
  }

  /// Progress (0.0–1.0) toward the next rank threshold.
  static double rankProgress(int peakXp) {
    String currentEarned = 'F';
    for (final rank in XpConstants.ranks) {
      if (rank == 'Monarch') continue;
      final threshold = XpConstants.rankXpThresholds[rank] ?? 0;
      if (peakXp >= threshold) currentEarned = rank;
    }

    final currentThreshold =
        XpConstants.rankXpThresholds[currentEarned] ?? 0;
    final nextXp = xpToNextRank(peakXp);
    if (nextXp == null) return 1.0;

    final span = nextXp - currentThreshold;
    if (span <= 0) return 1.0;
    return ((peakXp - currentThreshold) / span).clamp(0.0, 1.0);
  }

  // ── Habit XP ──────────────────────────────────────────────────

  static int habitReward(String difficulty) {
    return XpConstants.habitXpReward[difficulty.toLowerCase()] ?? 5;
  }

  static int habitPenalty(String difficulty) {
    return XpConstants.habitXpPenalty[difficulty.toLowerCase()] ?? 2;
  }

  // ── Quest XP auto-calc ────────────────────────────────────────

  /// Calculates the suggested XP reward for a quest.
  /// formula: days × multiplier (based on difficulty)
  static int suggestedQuestXp(String difficulty, int days) {
    final multiplier =
        XpConstants.questXpPerDay[difficulty.toLowerCase()] ?? 10;
    return days * multiplier;
  }

  // ── Monarch check ─────────────────────────────────────────────

  /// Returns true if all Monarch requirements are met.
  static bool meetsMonarchRequirements({
    required int totalXp,
    required int longestStreak,
    required double completionRate,
    required int legendaryQuestsCompleted,
    required int rankTerminations,
  }) {
    return totalXp >= XpConstants.monarchRequiredXp &&
        longestStreak >= XpConstants.monarchRequiredStreak &&
        completionRate >= XpConstants.monarchRequiredCompletionRate &&
        legendaryQuestsCompleted >= XpConstants.monarchRequiredLegendaryQuests &&
        rankTerminations <= XpConstants.monarchMaxRankTerminations;
  }

  /// Returns a map of which Monarch requirements are met/unmet.
  static Map<String, bool> monarchRequirementStatus({
    required int totalXp,
    required int longestStreak,
    required double completionRate,
    required int legendaryQuestsCompleted,
    required int rankTerminations,
  }) {
    return {
      'XP (${XpConstants.monarchRequiredXp})':
          totalXp >= XpConstants.monarchRequiredXp,
      '${XpConstants.monarchRequiredStreak}-Day Streak':
          longestStreak >= XpConstants.monarchRequiredStreak,
      '${(XpConstants.monarchRequiredCompletionRate * 100).toInt()}% Completion':
          completionRate >= XpConstants.monarchRequiredCompletionRate,
      '${XpConstants.monarchRequiredLegendaryQuests} Legendary Quests':
          legendaryQuestsCompleted >= XpConstants.monarchRequiredLegendaryQuests,
      'No Rank Terminations':
          rankTerminations <= XpConstants.monarchMaxRankTerminations,
    };
  }

  // ── Kept for backward compat ──────────────────────────────────
  static String rankForLevel(int level) => rankForXpMilestone(level * 100);
  static bool causesLevelUp(int currentTotalXp, int xpGained) {
    return levelFromTotalXp(currentTotalXp + xpGained) >
        levelFromTotalXp(currentTotalXp);
  }
}