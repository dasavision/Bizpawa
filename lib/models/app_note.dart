import 'package:hive/hive.dart';

part 'app_note.g.dart';

@HiveType(typeId: 11)
class AppNote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  AppNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}