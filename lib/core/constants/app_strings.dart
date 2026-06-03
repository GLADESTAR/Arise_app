/// All user-facing strings in one place.
/// Makes it easy to change wording or add localization later.
class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────
  static const String appName        = 'ARISE';
  static const String appTagline     = 'Level up your life';

  // ── Navigation ────────────────────────────────────────────────
  static const String navDashboard   = 'Home';
  static const String navTasks       = 'Tasks';
  static const String navHabits      = 'Habits';
  static const String navStats       = 'Stats';
  static const String navAnalytics   = 'Analytics';

  // ── Dashboard ────────────────────────────────────────────────
  static const String greetingMorning   = 'Good morning, Hunter';
  static const String greetingAfternoon = 'Good afternoon, Hunter';
  static const String greetingEvening   = 'Good evening, Hunter';
  static const String dailyQuests       = 'Daily Quests';
  static const String weeklyQuests      = 'Weekly Quests';
  static const String streakLabel       = 'Day Streak';
  static const String levelLabel        = 'Level';
  static const String rankLabel         = 'Rank';
  static const String xpLabel           = 'XP';

  // ── Level up ─────────────────────────────────────────────────
  static const String levelUpTitle     = 'LEVEL UP!';
  static const String levelUpSub       = 'You have grown stronger, Hunter.';
  static const String statPointsAwarded = 'Stat points awarded';

  // ── Tasks ─────────────────────────────────────────────────────
  static const String tasksTitle       = 'Quest Board';
  static const String addTask          = 'Add Task';
  static const String editTask         = 'Edit Task';
  static const String deleteTask       = 'Delete Task';
  static const String taskComplete     = 'Task Complete!';
  static const String noTasks          = 'No tasks yet.\nAdd your first quest.';

  // ── Habits ────────────────────────────────────────────────────
  static const String habitsTitle      = 'Daily Rituals';
  static const String addHabit         = 'Add Habit';
  static const String streakFire       = '🔥';
  static const String noHabits         = 'No habits tracked yet.';

  // ── Stats ─────────────────────────────────────────────────────
  static const String statsTitle       = 'Player Stats';
  static const String availablePoints  = 'Available Points';
  static const String allocate         = 'Allocate';
  static const String strength         = 'Strength';
  static const String intelligence     = 'Intelligence';
  static const String creativity       = 'Creativity';
  static const String charisma         = 'Charisma';
  static const String skill            = 'Skill';
  static const String navCalendar      = 'Calendar';

  // ── Ranks ─────────────────────────────────────────────────────
  static const Map<String, String> rankNames = {
    'E': 'E-Rank Hunter',
    'D': 'D-Rank Hunter',
    'C': 'C-Rank Hunter',
    'B': 'B-Rank Hunter',
    'A': 'A-Rank Hunter',
    'S': 'S-Rank Hunter',
  };

  static String rankName(String rank) =>
      rankNames[rank.toUpperCase()] ?? 'E-Rank Hunter';
}