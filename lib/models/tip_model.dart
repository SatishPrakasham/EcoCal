class Tip {
  final String text;
  final String? author;
  final String? category;

  Tip({
    required this.text,
    this.author,
    this.category,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    // Handle different API response formats
    if (json.containsKey('q') && json.containsKey('a')) {
      // Type.fit API format
      return Tip(
        text: json['q'] as String,
        author: json['a'] as String?,
      );
    } else if (json.containsKey('quote') && json.containsKey('author')) {
      // Quotes API format
      return Tip(
        text: json['quote'] as String,
        author: json['author'] as String?,
      );
    } else if (json.containsKey('tip')) {
      // API-Ninjas format
      return Tip(
        text: json['tip'] as String,
        category: json['category'] as String?,
      );
    } else {
      // Fallback for unknown format
      return Tip(
        text: json.toString(),
      );
    }
  }
}
