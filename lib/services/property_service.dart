import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:house_renting/utils/api_constants.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyService {
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('********** DEBUG START **********');
    print('DEBUG: Token from prefs: "$token"');
    if (token != null && token.isNotEmpty) {
      final cleanToken = token.trim();
      headers['Authorization'] = 'Bearer $cleanToken';
      print('DEBUG: Authorization header set: "Bearer $cleanToken"');
    } else {
      print('DEBUG: No token found or token is empty');
    }
    print('********** DEBUG END **********');
    return headers;
  }

  Future<List<Property>> getProperties({
    String? location,
    double? minRent,
    double? maxRent,
    int? bedrooms,
    String? rentalType,
    String? propertyType,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (location != null && location != 'Any')
        queryParams['location'] = location;
      if (minRent != null) queryParams['min_rent'] = minRent.toString();
      if (maxRent != null) queryParams['max_rent'] = maxRent.toString();
      if (bedrooms != null && bedrooms > 0)
        queryParams['bedrooms'] = bedrooms.toString();
      if (rentalType != null && rentalType != 'Any')
        queryParams['rental_type'] = rentalType.toLowerCase();
      if (propertyType != null && propertyType != 'Any')
        queryParams['property_type'] = propertyType;

      final uri = Uri.parse(
        ApiConstants.propertiesEndpoint,
      ).replace(queryParameters: queryParams);

      print('Fetching properties from: $uri');
      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      print('Response Status: ${response.statusCode}');
      // Truncate overly long body logging if needed, or keeping it for debug.
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        // Handle if response is wrapped in { "data": [...] }
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map &&
            decoded.containsKey('data') &&
            decoded['data'] is List) {
          data = decoded['data'];
        } else {
          // If it's a Map but not the expected format, or something else
          throw Exception('Unexpected JSON format: $decoded');
        }

        if (data.isNotEmpty) {
          print('DEBUG: First Property JSON: ${json.encode(data.first)}');
        }

        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load properties: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error in PropertyService: $e');
      throw Exception('Error fetching properties: $e');
    }
  }

  Future<Property> getPropertyDetails(String id) async {
    try {
      final url = '${ApiConstants.propertiesEndpoint}/$id';
      print('Fetching property details from: $url');
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      print('Details Response Status: ${response.statusCode}');
      // print('Details Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        // Expecting { "success": true, "data": { ... } }
        if (decoded is Map && decoded.containsKey('data')) {
          return Property.fromJson(decoded['data']);
        } else {
          throw Exception('Unexpected JSON format for details: $decoded');
        }
      } else {
        throw Exception(
          'Failed to load property details: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error in PropertyService (details): $e');
      throw Exception('Error fetching property details: $e');
    }
  }

  Future<void> addToFavorites(String id) async {
    try {
      final url = '${ApiConstants.propertiesEndpoint}/$id/favourite';
      // Remove Content-Type from headers for this endpoint
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      print('DEBUG: Adding to favorites - URL: $url');
      final response = await http.post(Uri.parse(url), headers: headers);

      print(
        'DEBUG: Add favorite response - Status: ${response.statusCode}, Body: ${response.body}',
      );

      // Parse response
      final decoded = json.decode(response.body);

      // Accept 200-299 status codes for success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] == true) {
          print('DEBUG: Successfully added to favorites');
          return;
        }
      }

      // Handle "Property already in favourites" case
      if (decoded['success'] == false &&
          decoded['message'] == 'Property already in favourites') {
        print('DEBUG: Property already in favorites, treating as success');
        return;
      }

      throw Exception(
        'Failed to add to favorites: ${decoded['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      print('ERROR: Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String id) async {
    try {
      final url = '${ApiConstants.propertiesEndpoint}/$id/favourite';
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      print('DEBUG: Removing from favorites - URL: $url');
      final response = await http.delete(Uri.parse(url), headers: headers);

      print(
        'DEBUG: Remove favorite response - Status: ${response.statusCode}, Body: ${response.body}',
      );

      // Parse response
      final decoded = json.decode(response.body);

      // Accept 200-299 status codes for success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] == true) {
          print('DEBUG: Successfully removed from favorites');
          return;
        }
      }

      throw Exception(
        'Failed to remove from favorites: ${decoded['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      print('ERROR: Error removing favorite: $e');
      rethrow;
    }
  }
}
