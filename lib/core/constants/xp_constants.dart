/// All XP values, rank thresholds, and system configuration.
/// Change values here — nothing else needs to change.
class XpConstants {
  XpConstants._();

  // ── Rank Termination Mode ─────────────────────────────────────
  // 'one_rank' = drop one rank (B → C)
  // 'full_reset' = drop to F rank
  static const String rankTerminationMode = 'one_rank';

  // ── Rank definitions in order (lowest → highest) ──────────────
  static const List<String> ranks = [
    'F', 'E', 'D', 'C', 'B', 'A', 'S',
    'National', 'Monarch Candidate', 'Monarch',
  ];

  // ── XP required to UNLOCK each rank (milestone) ───────────────
  // Once unlocked, losing XP does NOT demote the user.
  // Monarch is NOT unlocked by XP alone — see MonarchRequirements.
  static const Map<String, int> rankXpThresholds = {
    'F':                  0,
    'E':                  500,
    'D':                  1500,
    'C':                  3500,
    'B':                  7000,
    'A':                  13000,
    'S':                  22000,
    'National':           35000,
    'Monarch Candidate':  52000,
    'Monarch':            999999999, // Never reached via XP alone
  };

  // ── Habit XP rewards by difficulty ───────────────────────────
  static const Map<String, int> habitXpReward = {
    'easy':   5,
    'medium': 10,
    'hard':   20,
  };

  // ── Habit XP penalties (missed at end of day) ─────────────────
  static const Map<String, int> habitXpPenalty = {
    'easy':   2,
    'medium': 5,
    'hard':   10,
  };

  // ── Quest XP auto-calculation (XP = days × multiplier) ────────
  static const Map<String, int> questXpPerDay = {
    'easy':      10,
    'medium':    20,
    'hard':      40,
    'legendary': 60,
  };

  // ── Quest categories ──────────────────────────────────────────
  // 'normal'    → no penalty on failure
  // 'important' → XP penalty on failure
  // 'legendary' → rank termination on failure
  static const String categoryNormal    = 'normal';
  static const String categoryImportant = 'important';
  static const String categoryLegendary = 'legendary';

  // ── Important quest failure XP penalty ────────────────────────
  static const int importantQuestFailurePenalty = 100;

  // ── Monarch endgame requirements (all must be met) ────────────
  static const int    monarchRequiredXp              = 52000;
  static const int    monarchRequiredStreak          = 365;
  static const double monarchRequiredCompletionRate  = 0.90; // 90%
  static const int    monarchRequiredLegendaryQuests = 10;
  static const int    monarchMaxRankTerminations     = 0;

  // ── Legacy fields kept for backward compatibility ─────────────
  static const int statPointsPerLevel = 3;
  static const int xpBaseAmount       = 100;
  static const double xpScalingFactor = 1.5;
  static const int streakMilestone    = 7;
  static const int streakBonusXp      = 50;
}