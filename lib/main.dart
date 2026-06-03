import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/player/data/models/player_model.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/habits/data/models/habit_model.dart';
import 'features/habits/data/models/achievement_model.dart';
import 'features/calendar/data/models/calendar_day_model.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(PlayerModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskDifficultyAdapter());
  Hive.registerAdapter(TaskRecurrenceAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(AchievementModelAdapter());
  Hive.registerAdapter(CalendarDayModelAdapter());

  await Hive.openBox<PlayerModel>('player');
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<AchievementModel>('achievements');
  await Hive.openBox<CalendarDayModel>('calendar');

  runApp(const ProviderScope(child: AriseApp()));
}