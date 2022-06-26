import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product_provider.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<ProductProvider> _items = [];

  // var _showFavoriteOnly = false;

  // void showFavoritesOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<ProductProvider> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<ProductProvider> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  ProductProvider findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterQuery = filterByUser
        ? {
            'auth': authToken,
            'orderBy': "\"creatorId\"",
            'equalTo': "\"" + userId + "\"",
          }
        : {
            'auth': authToken,
          };

    final productsUrl = Uri.https(
      'flutter-practice-eba68-default-rtdb.firebaseio.com',
      '/products.json',
      filterQuery,
    );
    try {
      final response = await http.get(productsUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final favoriteUrl = Uri.https(
        'flutter-practice-eba68-default-rtdb.firebaseio.com',
        '/userFavorites/$userId.json',
        {'auth': authToken},
      );
      final favoriteResponse = await http.get(favoriteUrl);
      final extractedFavoriteData =
          json.decode(favoriteResponse.body) as Map<String, dynamic>;
      final List<ProductProvider> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(ProductProvider(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: extractedFavoriteData == null
              ? false
              : extractedFavoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(ProductProvider product) async {
    final url = Uri.https(
      'flutter-practice-eba68-default-rtdb.firebaseio.com',
      '/products.json',
      {'auth': authToken},
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = ProductProvider(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(ProductProvider newProduct, String id) async {
    final prodIndex = items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'flutter-practice-eba68-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': authToken},
      );
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }),
        );
        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    if (existingProductIndex >= 0) {
      final url = Uri.https(
        'flutter-practice-eba68-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': authToken},
      );

      _items.removeAt(existingProductIndex);
      notifyListeners();

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete product.');
      }
      existingProduct = null;
    }
  }

  // Future<void> toggleFavorites(String id) async {
  //   final url = Uri.https('flutter-practice-eba68-default-rtdb.firebaseio.com',
  //       '/products/$id.json');
  //   final prodIndex = _items.indexWhere((prod) => prod.id == id);
  //   final prodFavoriteStatus = _items[prodIndex].isFavorite;

  //   _items[prodIndex] = ProductProvider(
  //     id: _items[prodIndex].id,
  //     title: _items[prodIndex].title,
  //     description: _items[prodIndex].description,
  //     price: _items[prodIndex].price,
  //     imageUrl: _items[prodIndex].imageUrl,
  //     isFavorite: !_items[prodIndex].isFavorite,
  //   );
  //   notifyListeners();
  //   final response = await http.patch(
  //     url,
  //     body: json.encode({
  //       'isFavorite': !prodFavoriteStatus,
  //     }),
  //   );

  //   if (response.statusCode >= 400) {
  //     _items[prodIndex] = ProductProvider(
  //       id: _items[prodIndex].id,
  //       title: _items[prodIndex].title,
  //       description: _items[prodIndex].description,
  //       price: _items[prodIndex].price,
  //       imageUrl: _items[prodIndex].imageUrl,
  //       isFavorite: prodFavoriteStatus,
  //     );
  //     notifyListeners();
  //     if (prodFavoriteStatus)
  //       throw HttpException('Failed to unlike');
  //     else
  //       throw HttpException('Failed to like.');
  //   }
  // }
}
