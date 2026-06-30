class OccupationItem {
  final String  id;
  final String  name;
  final String? image;

  const OccupationItem({
    required this.id,
    required this.name,
    this.image,
  });

  factory OccupationItem.fromJson(Map<String, dynamic> json) {
    return OccupationItem(
      id:    json['id']    as String,
      name:  json['name']  as String,
      image: json['image'] as String?,
    );
  }
}