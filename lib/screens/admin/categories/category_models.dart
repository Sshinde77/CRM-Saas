class CategoryRecord {
  final String name;
  final String description;
  final String imageLabel;
  final String? imageUrl;
  final List<String> subcategories;

  const CategoryRecord({
    required this.name,
    required this.description,
    required this.imageLabel,
    required this.imageUrl,
    required this.subcategories,
  });
}
