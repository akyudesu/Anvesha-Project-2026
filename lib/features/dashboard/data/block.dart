class Block {
  final String id;
  final String title;
  List classes = [];
  final int width;
  final int length;

  Block({
    required this.id,
    required this.title,
    this.classes = const [],
    required this.width,
    required this.length,
  });
}
class Exit{

  final String id;
  final String title;
  final int width;
  final int length;

  Exit({
    required this.id,
    required this.title,
    required this.width,
    required this.length,
  });




}