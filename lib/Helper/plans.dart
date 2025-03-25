class Plan {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String price;
  final int duration;
  final String durationUnit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.duration,
    required this.durationUnit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: json['price'],
      duration: json['duration'],
      durationUnit: json['duration_unit'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'duration': duration,
      'duration_unit': durationUnit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
