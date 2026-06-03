import 'package:uuid/uuid.dart';

/// Simple utility for generating unique IDs for all models.
class IdGenerator {
  IdGenerator._();
  static const _uuid = Uuid();

  /// Generates a new unique ID string. Call this when creating any new model.
  static String generate() => _uuid.v4();
}