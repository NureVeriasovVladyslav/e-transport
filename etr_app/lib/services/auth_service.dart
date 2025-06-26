// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import '../models/user.dart';

// class AuthService extends ChangeNotifier {
//   static const _storage = FlutterSecureStorage();
//   static const String _tokenKey = 'jwt_token';
  
//   User? _user;
//   bool _isAuthenticated = false;
//   bool _isLoading = false;
//   String? _currentToken;

//   User? get user => _user;
//   bool get isAuthenticated => _isAuthenticated;
//   bool get isLoading => _isLoading;

//   //rent func
//   String? _activeRentalId;
//   String? _activeRentalVehicleId;
//   bool _hasActiveRental = false;

//   bool get hasActiveRental => _hasActiveRental;
//   String? get activeRentalId => _activeRentalId;
//   String? get activeRentalVehicleId => _activeRentalVehicleId;

//   static const String baseUrl = String.fromEnvironment('BACKEND_URL', 
//     defaultValue: 'http://10.0.2.2:3000');

// // Почати оренду
// Future<bool> startRental(String vehicleId, double lat, double lon) async {
//   final userId = _user?.id;
//   if (userId == null) return false;
//   final response = await authenticatedPost('/rental/full', {
//     'userId': userId,
//     'vehicleId': vehicleId,
//     'startLocation': {'latitude': lat, 'longitude': lon},
//     'distance': 0.0,
//     'avgSpeed': 0.0,
//     'maxSpeed': 0.0,
//     'energyConsumed': 0.0,
//   });
//   if (response.statusCode == 200 || response.statusCode == 201) {
//     final data = json.decode(response.body);
//     _activeRentalId = data['id'];
//     _activeRentalVehicleId = data['vehicleId'];
//     _hasActiveRental = true;
//     notifyListeners();
//     return true;
//   }
//   return false;
// }

// // Завершити оренду
// Future<bool> endRental(double lat, double lon, String paymentMethod) async {
//   if (!_hasActiveRental || _activeRentalVehicleId == null) return false;
//   final response = await authenticatedPost('/rental/end', {
//     'rentalVehicleId': _activeRentalVehicleId,
//     'endLocation': {'latitude': lat, 'longitude': lon},
//     'paymentMethod': paymentMethod,
//   });
//   if (response.statusCode == 200) {
//     _activeRentalId = null;
//     _activeRentalVehicleId = null;
//     _hasActiveRental = false;
//     notifyListeners();
//     return true;
//   }
//   return false;
// }

//   // Декодування JWT токена для отримання user ID
//   String? _getUserIdFromToken(String token) {
//     try {
//       final parts = token.split('.');
//       if (parts.length != 3) return null;
      
//       final payload = parts[1];
//       // Додаємо padding якщо потрібно
//       final normalized = base64Url.normalize(payload);
//       final decoded = utf8.decode(base64Url.decode(normalized));
//       final data = json.decode(decoded) as Map<String, dynamic>;
      
//       return data['sub']?.toString(); // JWT стандартний claim для user ID
//     } catch (e) {
//       debugPrint('Token decode error: $e');
//       return null;
//     }
//   }

//   Future<bool> login(String email, String password) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'email': email,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final token = data['access_token'];
        
//         await _storage.write(key: _tokenKey, value: token);
//         _currentToken = token;
//         await _loadUserProfile();
        
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       }
//     } catch (e) {
//       debugPrint('Login error: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//     return false;
//   }

//   Future<bool> register({
//     required String email,
//     required String password,
//     required String name,
//     required String phoneNumber,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'email': email,
//           'password': password,
//           'name': name,
//           'phoneNumber': phoneNumber,
//           'role': 'USER',
//         //   'role': role,
//           'bonusAccount': '0',
//           'notification': true,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final token = data['access_token'];
        
//         await _storage.write(key: _tokenKey, value: token);
//         _currentToken = token;
//         await _loadUserProfile();
        
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       }
//     } catch (e) {
//       debugPrint('Register error: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//     return false;
//   }

// Future<void> _loadUserProfile() async {
//   if (_currentToken == null) return; // Перевіряємо наявність токена[1]

//   try {
//     // Декодуємо token, отримуємо userId
//     final userId = _getUserIdFromToken(_currentToken!); // Викликаємо _getUserIdFromToken[2]
//     if (userId == null) {
//       debugPrint('Cannot extract user ID from token'); // Логування помилки[3]
//       await logout();
//       return;
//     }

//     // Робимо запит за правильним шляхом з userId
//     final response = await http.get(
//       Uri.parse('$baseUrl/user/by-id/$userId'), // Використання userId замість $sub[4]
//       headers: {
//         'Authorization': 'Bearer $_currentToken', // Додаємо заголовок авторизації[5]
//         'accept': '*/*',
//       },
//     );

//     if (response.statusCode == 200) {
//       final userData = json.decode(response.body) as Map<String, dynamic>; // Парсимо JSON[6]
//       _user = User.fromJson(userData); // Ініціалізуємо модель користувача[7]
//       _isAuthenticated = true;         // Встановлюємо прапорець аутентифікації[8]
//       debugPrint('User profile loaded: ${_user?.name}'); // Вивід у консоль[9]
//     } else {
//       debugPrint('Profile load failed: ${response.statusCode} - ${response.body}'); // Логування помилки сервера[10]
//       await logout();
//     }
//   } catch (e) {
//     debugPrint('Load profile error: $e'); // Обробка винятків[11]
//     await logout();
//   }
// }


//   Future<void> logout() async {
//     await _storage.delete(key: _tokenKey);
//     _user = null;
//     _isAuthenticated = false;
//     _currentToken = null;
//     notifyListeners();
//   }

//   Future<String?> getToken() async {
//     return _currentToken ?? await _storage.read(key: _tokenKey);
//   }

//   // Метод для виконання авторизованих запитів
//   // Future<http.Response> authenticatedGet(String endpoint) async {
//   //   final token = await getToken();
//   //   if (token == null) throw Exception('No authentication token');

//   //   return await http.get(
//   //     Uri.parse('$baseUrl$endpoint'),
//   //     headers: {
//   //       'Authorization': 'Bearer $token',
//   //       'accept': '*/*',
//   //     },
//   //   );
//   // }
//   Future<http.Response> authenticatedGet(String endpoint, {Map<String, dynamic>? queryParams}) async {
//     final token = await getToken();
//     if (token == null) throw Exception('No authentication token');

//     // Формуємо URI з параметрами запиту
//     final uri = Uri.parse('$baseUrl$endpoint').replace(
//       queryParameters: queryParams,
//     );

//     return await http.get(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'accept': '*/*',
//       },
//     );
//   }


//   Future<http.Response> authenticatedPost(String endpoint, Map<String, dynamic> body) async {
//     final token = await getToken();
//     if (token == null) throw Exception('No authentication token');

//     return await http.post(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode(body),
//     );
//   }

//   Future<bool> rentScooter(String scooterId) async {
//     final resp = await authenticatedPost('/rental', {'vehicleId': scooterId});
//     return resp.statusCode == 200;
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _currentToken;

  // Поля для оренди
  String? _activeRentalId;
  String? _activeRentalVehicleId;
  bool _hasActiveRental = false;

  // Геттери
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get hasActiveRental => _hasActiveRental;
  String? get activeRentalId => _activeRentalId;
  String? get activeRentalVehicleId => _activeRentalVehicleId;

  static const String baseUrl = String.fromEnvironment('BACKEND_URL', 
    defaultValue: 'http://10.0.2.2:3000');

  // ВАЖЛИВИЙ МЕТОД INIT - ЦЕ ТЕ, ЩО БУЛО ВІДСУТНЄ
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      _currentToken = token;
      await _loadUserProfile();
      // Перевіряємо активну оренду після завантаження профілю
      if (_isAuthenticated) {
        await checkActiveRental();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

    // Декодування JWT токена для отримання user ID
  String? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      // Додаємо padding якщо потрібно
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded) as Map<String, dynamic>;
      
      return data['sub']?.toString(); // JWT стандартний claim для user ID
    } catch (e) {
      debugPrint('Token decode error: $e');
      return null;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        
        await _storage.write(key: _tokenKey, value: token);
        _currentToken = token;
        await _loadUserProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'phoneNumber': phoneNumber,
          'role': 'USER',
        //   'role': role,
          'bonusAccount': '0',
          'notification': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        
        await _storage.write(key: _tokenKey, value: token);
        _currentToken = token;
        await _loadUserProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

Future<void> _loadUserProfile() async {
  if (_currentToken == null) return; // Перевіряємо наявність токена[1]

  try {
    // Декодуємо token, отримуємо userId
    final userId = _getUserIdFromToken(_currentToken!); // Викликаємо _getUserIdFromToken[2]
    if (userId == null) {
      debugPrint('Cannot extract user ID from token'); // Логування помилки[3]
      await logout();
      return;
    }

    // Робимо запит за правильним шляхом з userId
    final response = await http.get(
      Uri.parse('$baseUrl/user/by-id/$userId'), // Використання userId замість $sub[4]
      headers: {
        'Authorization': 'Bearer $_currentToken', // Додаємо заголовок авторизації[5]
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body) as Map<String, dynamic>; // Парсимо JSON[6]
      _user = User.fromJson(userData); // Ініціалізуємо модель користувача[7]
      _isAuthenticated = true;         // Встановлюємо прапорець аутентифікації[8]
      debugPrint('User profile loaded: ${_user?.name}'); // Вивід у консоль[9]
    } else {
      debugPrint('Profile load failed: ${response.statusCode} - ${response.body}'); // Логування помилки сервера[10]
      await logout();
    }
  } catch (e) {
    debugPrint('Load profile error: $e'); // Обробка винятків[11]
    await logout();
  }
}


  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _user = null;
    _isAuthenticated = false;
    _currentToken = null;
    notifyListeners();
  }

  Future<String?> getToken() async {
    return _currentToken ?? await _storage.read(key: _tokenKey);
  }

  // Перевірка активної оренди
  Future<void> checkActiveRental() async {
    try {
      final response = await authenticatedGet('/rental/active');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['isActive'] == true) {
          _activeRentalId = data['id'];
          _activeRentalVehicleId = data['rentalVehicle']?[0]?['id'];
          _hasActiveRental = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Check active rental error: $e');
    }
  }

  // Початок оренди
  Future<bool> startRental(String vehicleId, double lat, double lon) async {
    debugPrint('Starting rental for vehicle: $vehicleId at ($lat, $lon)');
    final userId = _user?.id;
    if (userId == null) return false;
    debugPrint('User ID: $userId');
    try {
      final now = DateTime.now().toIso8601String();
      final response = await authenticatedPost('/rental/full/start', {
        'isActive': true,
        'dateRented': now,
        'dateReturned': 'not returned',
        'distance': 0,
        'avgSpeed': 0,
        'maxSpeed': 0,
        'energyConsumed': 0,
        'userId': userId,
        'vehicleId': vehicleId,
        'startLocation': {
          'latitude': lat,
          'longitude': lon,
        },
      });

      debugPrint('Start rental response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _activeRentalId = data['id'];
        _activeRentalVehicleId = vehicleId;
        _hasActiveRental = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Start rental error: $e');
    }
    return false;
  }


  // Завершення оренди
  Future<bool> endRental(double lat, double lon, String paymentMethod) async {
    if (!_hasActiveRental || _activeRentalVehicleId == null) return false;
    
    try {
      final response = await authenticatedPost('/rental/end', {
        'rentalVehicleId': _activeRentalVehicleId,
        'endLocation': {'latitude': lat, 'longitude': lon},
        'paymentMethod': paymentMethod,
        'dateReturned': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        _activeRentalId = null;
        _activeRentalVehicleId = null;
        _hasActiveRental = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('End rental error: $e');
    }
    return false;
  }

  // // Вихід з системи
  // Future<void> logout() async {
  //   await _storage.delete(key: _tokenKey);
  //   _user = null;
  //   _isAuthenticated = false;
  //   _currentToken = null;
  //   _activeRentalId = null;
  //   _activeRentalVehicleId = null;
  //   _hasActiveRental = false;
  //   notifyListeners();
  // }



  // Авторизований GET запит
  Future<http.Response> authenticatedGet(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final token = await getToken();
    if (token == null) throw Exception('No authentication token');

    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );

    return await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );
  }

  // Авторизований POST запит
  Future<http.Response> authenticatedPost(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) throw Exception('No authentication token');

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
  }

  // Застарілий метод (для зворотної сумісності)
  Future<bool> rentScooter(String scooterId) async {
    final resp = await authenticatedPost('/rental', {'vehicleId': scooterId});
    return resp.statusCode == 200;
  }
}
