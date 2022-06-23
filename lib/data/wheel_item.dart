import 'package:hive/hive.dart';

part 'wheel_item.g.dart';

@HiveType(typeId: 1)
class WheelItem extends HiveObject {
  WheelItem({
    required this.id,
    required this.text,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;
}
