import 'dart:convert';

import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProductProvider with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  ProductProvider({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    _setFavValue(!isFavorite);

    final url = Uri.https(
      'flutter-practice-eba68-default-rtdb.firebaseio.com',
      '/userFavorites/$userId/$id.json',
      {'auth': token},
    );
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );

      if (response.statusCode >= 400) {
        throw HttpException("Failed to ${isFavorite ? "" : "un"}like");
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
