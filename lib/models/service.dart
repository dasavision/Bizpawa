class Service {
  final String id;
  final String name;
  final String category;
  final int price;
  final String? description;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
  });
}
