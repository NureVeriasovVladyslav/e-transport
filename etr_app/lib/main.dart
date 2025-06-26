// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart' as geo;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
// import 'package:provider/provider.dart';
// import 'services/auth_service.dart';
// import 'pages/auth_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   const ACCESS_TOKEN = String.fromEnvironment('ACCESS_TOKEN');
//   mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) => ChangeNotifierProvider(
//     create: (context) => AuthService()..init(),
//     child: const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MainNavigation(),
//     ),
//   );
// }

// /// ---------------------------
// ///      BOTTOM NAVIGATION
// /// ---------------------------
// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});
//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _current = 0;

//   final pages = const [
//     MapPage(),
//     RidesPage(),
//     WalletPage(),
//     ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: pages[_current],
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _current,
//           onTap: (i) => setState(() => _current = i),
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
//             BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trips'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           ],
//         ),
//       );
// }

// /// ---------------------------
// ///            MAP
// /// ---------------------------
// class MapPage extends StatefulWidget {
//   const MapPage({super.key});
//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final PanelController _panelController = PanelController();
//   Scooter? _selectedScooter;
//   mapbox.MapboxMap? _map;
//   mapbox.PointAnnotationManager? _scooterManager;
//   mapbox.PointAnnotationManager? _userManager;
//   Timer? _ticker;
//   double _currentUserLat = 0;
//   double _currentUserLon = 0;
  
//   // Додаємо список скутерів для зберігання
//   List<Scooter> _scooters = [];

//   void _startRental(Scooter scooter) async {
//     final auth = Provider.of<AuthService>(context, listen: false);
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Підтвердження'),
//         content: Text('Розпочати оренду самокату ${scooter.id.substring(0, 8)}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Скасувати'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Підтвердити'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       final success = await auth.startRental(
//         scooter.id,
//         scooter.lat,
//         scooter.lng,
//       );

//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Оренда розпочата успішно!')),
//         );
//         _panelController.close();
//         _fetchAndShowScooters();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Помилка початку оренди')),
//         );
//       }
//     }
//   }

//   void _endRental() async {
//     final auth = Provider.of<AuthService>(context, listen: false);
//     final paymentMethod = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Завершення оренди'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Оберіть спосіб оплати:'),
//             const SizedBox(height: 16),
//             ListTile(
//               leading: const Icon(Icons.credit_card),
//               title: const Text('Банківська картка'),
//               onTap: () => Navigator.of(context).pop('CARD'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance_wallet),
//               title: const Text('Бонусний рахунок'),
//               onTap: () => Navigator.of(context).pop('BONUS'),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (paymentMethod != null) {
//       final success = await auth.endRental(
//         _currentUserLat,
//         _currentUserLon,
//         paymentMethod,
//       );

//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Оренда завершена успішно!')),
//         );
//         _panelController.close();
//         _fetchAndShowScooters();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Помилка завершення оренди')),
//         );
//       }
//     }
//   }
//   // Метод для отримання відстані до самокату
//  Future<String?> _fetchDistance(double userLat, double userLon, String scooterId) async {
//   final auth = Provider.of<AuthService>(context, listen: false);
  
//   // Формуємо шлях з параметрами запиту
//   final path = '/vehicle/$scooterId/distance';
//   final queryParams = {
//     'userLat': userLat.toString(),
//     'userLon': userLon.toString(),
//   };
  
//   debugPrint('userLat: $userLat, userLon: $userLon, scooterId: $scooterId');
//   debugPrint('Fetching distance from: ${AuthService.baseUrl}$path?${Uri(queryParameters: queryParams).query}');
  
//   try {
//     // Використовуємо authenticatedGet зі шляхом та параметрами
//     final response = await auth.authenticatedGet(
//       path,
//       queryParams: queryParams,
//     );
    
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as Map<String, dynamic>;
//       return data['distance'] as String;
//     }
//   } catch (e) {
//     debugPrint('Distance fetch error: $e');
//   }
//   return null;
// }



// // Widget _buildScooterPanel(ScrollController sc) {
// //     if (_selectedScooter == null) return Center(child: Text('Виберіть самокат'));

// //     return FutureBuilder<String?>(
// //       future: _fetchDistance(
// //         _currentUserLat, 
// //         _currentUserLon, 
// //         _selectedScooter!.id
// //       ),
// //       builder: (context, snapshot) {
// //         final distance = snapshot.data ?? '...';
// //         final s = _selectedScooter!;
// //         return ListView(
// //           controller: sc,
// //           padding: const EdgeInsets.all(16),
// //           children: [
// //             Center(
// //               child: Container(
// //                 width: 40, 
// //                 height: 5,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[300], 
// //                   borderRadius: BorderRadius.circular(12)
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               'Самокат ${s.id.substring(0, 8)}', 
// //               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
// //             ),
// //             const SizedBox(height: 8),
// //             Text('Статус: ${s.status}'),
// //             Text('Пробіг: ${s.runnedDistance.toStringAsFixed(1)} км'),
// //             Text('Дата випуску: ${s.releaseDate.toLocal()}'),
// //             Text('Відстань до вас: $distance', style: const TextStyle(fontSize: 16)),
// //             const SizedBox(height: 16),
// //             ElevatedButton.icon(
// //               icon: const Icon(Icons.electric_scooter), 
// //               label: const Text('Орендувати'),
// //               onPressed: () => _startRental(s.id),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _ticker = Timer.periodic(const Duration(seconds: 15), (_) {
// //       _fetchAndShowScooters();
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _ticker?.cancel();
// //     super.dispose();
// //   }

// //   Future<void> _initLocationAndCamera() async {
// //     final perm = await geo.Geolocator.requestPermission();
// //     if (perm == geo.LocationPermission.denied ||
// //         perm == geo.LocationPermission.deniedForever) {
// //       return;
// //     }

// //     final pos = await geo.Geolocator.getCurrentPosition();
// //     final point =
// //         mapbox.Point(coordinates: mapbox.Position(pos.longitude, pos.latitude));
// //     setState(() {
// //       _currentUserLat = pos.latitude;
// //       _currentUserLon = pos.longitude;
// //     });
// //     await _map?.flyTo(
// //       mapbox.CameraOptions(center: point, zoom: 3),
// //       mapbox.MapAnimationOptions(duration: 1500),
// //     );

// //     _userManager ??= await _map!.annotations.createPointAnnotationManager();
// //     await _userManager!.deleteAll();

// //     final icon = await _loadBytes('assets/images/pointer.png');
// //     await _userManager!.create(
// //       mapbox.PointAnnotationOptions(
// //         geometry: point,
// //         image: icon,
// //         iconSize: 0.15,
// //       ),
// //     );
// //   }

// //   Future<void> _fetchAndShowScooters() async {
// //     if (_map == null) return;

// //     try {
// //       final authService = Provider.of<AuthService>(context, listen: false);
      
// //       // Перевіряємо чи користувач авторизований
// //       if (!authService.isAuthenticated) {
// //         debugPrint('User not authenticated, skipping vehicle fetch');
// //         return;
// //       }

// //       final response = await authService.authenticatedGet('/vehicle');

// //       if (response.statusCode != 200) {
// //         debugPrint('Vehicle HTTP ${response.statusCode}: ${response.body}');
// //         return;
// //       }

// //       final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
      
// //       debugPrint('First vehicle: ${raw.isNotEmpty ? json.encode(raw.first) : "none"}');
      
// //       _scooters = raw
// //           .where((e) => e['currentLocation'] != null)
// //           .map((e) => Scooter.fromJson(e as Map<String, dynamic>))
// //           .toList(growable: false);
      
// //       debugPrint('Loaded ${_scooters.length} scooters');
      
// //       await _drawScooterMarkers(_scooters);
// //     } catch (e, stackTrace) {
// //       debugPrint('Vehicle request error: $e');
// //       debugPrint('Stack trace: $stackTrace');
// //     }
// //   }

// //   Future<void> _drawScooterMarkers(List<Scooter> list) async {
// //     // Створюємо новий менеджер анотацій
// //     _scooterManager = await _map!.annotations.createPointAnnotationManager();
// //     await _scooterManager!.deleteAll();
    
// //     // Створюємо клас-слухач для обробки натискань
// //     final clickListener = ScooterClickListener(this);
// //     _scooterManager!.addOnPointAnnotationClickListener(clickListener);
    
// //     final icon = await _loadBytes('assets/images/scooter.png');
// //     for (final s in list) {
// //       await _scooterManager!.create(
// //         mapbox.PointAnnotationOptions(
// //           geometry: mapbox.Point(coordinates: mapbox.Position(s.lng, s.lat)),
// //           image: icon,
// //           iconSize: 0.12,
// //           textSize: 12,
// //           textOffset: [0.0, 1.5],
// //           // Додаємо ідентифікатор для пошуку скутера при натисканні
// //           textField: s.id,
// //         ),
// //       );
// //     }
// //   }

// //   // Клас для обробки натискань на маркери
// //   void handleScooterClick(String scooterId) {
// //     final tapped = _scooters.firstWhere((s) => s.id == scooterId);
// //     setState(() => _selectedScooter = tapped);
// //     _panelController.open();
// //   }

// //   Future<Uint8List> _loadBytes(String path) async {
// //     final bytes = await rootBundle.load(path);
// //     return bytes.buffer.asUint8List();
// //   }

// //   void _startRental(String id) async {
// //     debugPrint('Starting rental for scooter: $id');
// //     final ok = await Provider.of<AuthService>(context, listen: false).rentScooter(id);
// //     if (ok) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Оренда почалася')));
// //       _panelController.close();
// //     }
// //   }
// //   void _startRental(Scooter scooter) async {
// //     final auth = Provider.of<AuthService>(context, listen: false);
    
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Підтвердження'),
// //         content: Text('Розпочати оренду самокату ${scooter.id.substring(0, 8)}?'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(false),
// //             child: const Text('Скасувати'),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(true),
// //             child: const Text('Підтвердити'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirmed == true) {
// //       final success = await auth.startRental(
// //         scooter.id,
// //         scooter.lat,
// //         scooter.lng,
// //       );

// //       if (success) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Оренда розпочата успішно!')),
// //         );
// //         _panelController.close();
// //         _fetchAndShowScooters();
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Помилка початку оренди')),
// //         );
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SlidingUpPanel(
// //         controller: _panelController,
// //         minHeight: 0,
// //         maxHeight: MediaQuery.of(context).size.height * 0.5,
// //         panelBuilder: (sc) => _buildScooterPanel(sc),
// //         body: mapbox.MapWidget(
// //           key: const ValueKey('map'),
// //           cameraOptions: mapbox.CameraOptions(
// //             center: mapbox.Point(coordinates: mapbox.Position(0.0, 0.0)),
// //             zoom: 1,
// //           ),
// //           onMapCreated: (controller) {
// //             _map = controller;
// //             _initLocationAndCamera();
// //             _fetchAndShowScooters();
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
// Widget _buildScooterPanel(ScrollController sc) {
//   if (_selectedScooter == null) return Center(child: Text('Виберіть самокат'));
//   final s = _selectedScooter!;

//   return Consumer<AuthService>(
//     builder: (context, auth, child) {
//       return FutureBuilder<String?>(
//         future: _fetchDistance(_currentUserLat, _currentUserLon, s.id),
//         builder: (context, snapshot) {
//           final distance = snapshot.data ?? '...';
//           final isScooterInUse = s.status == 'INUSE';
//           final isMyActiveRental = auth.hasActiveRental && auth.activeRentalVehicleId == s.id;

//           return ListView(
//             controller: sc,
//             padding: const EdgeInsets.all(16),
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text('Самокат ${s.id.substring(0, 8)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text('Статус: ${s.status}'),
//               Text('Пробіг: ${s.runnedDistance.toStringAsFixed(1)} км'),
//               Text('Дата випуску: ${s.releaseDate.toLocal()}'),
//               Text('Відстань до вас: $distance', style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 16),

//               // Кнопка "Орендувати"
//               if (!auth.hasActiveRental && !isScooterInUse)
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.electric_scooter),
//                   label: const Text('Орендувати'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   onPressed: () => _startRental(s),
//                 ),

//               // Кнопка "Завершити оренду"
//               if (isMyActiveRental)
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.stop),
//                   label: const Text('Завершити оренду'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   onPressed: () => _endRental(),
//                 ),

//               // Інформування про зайнятість
//               if (isScooterInUse && !isMyActiveRental)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'Самокат зараз використовується',
//                     style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
//                   ),
//                 ),

//               // Інформування про активну оренду іншого самокату
//               if (auth.hasActiveRental && !isMyActiveRental)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'У вас вже є активна оренда',
//                     style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }


// // Клас-слухач для обробки натискань на маркери
// class ScooterClickListener extends mapbox.OnPointAnnotationClickListener {
//   final _MapPageState _mapState;
  
//   ScooterClickListener(this._mapState);
  
//   @override
//   void onPointAnnotationClick(mapbox.PointAnnotation annotation) {
//     // Використовуємо textField як ідентифікатор скутера
//     if (annotation.textField != null) {
//       _mapState.handleScooterClick(annotation.textField!);
//     }
//   }
// }

// /// ---------------------------
// ///        DATA MODEL
// /// ---------------------------
// class Scooter {
//   final String id;
//   final double lat;
//   final double lng;
//   final String status;
//   final double runnedDistance;
//   final DateTime releaseDate;

//   const Scooter({
//     required this.id,
//     required this.lat,
//     required this.lng,
//     required this.status,
//     required this.runnedDistance,
//     required this.releaseDate,
//   });

//   factory Scooter.fromJson(Map<String, dynamic> json) => Scooter(
//         id: json['id'] as String,
//         lat: (json['currentLocation']['latitude'] as num).toDouble(),
//         lng: (json['currentLocation']['longitude'] as num).toDouble(),
//         status: json['status'] as String,
//         runnedDistance: (json['runnedDistance'] as num).toDouble(),
//         releaseDate: DateTime.parse(json['releaseDate'] as String),
//       );
// }

// /// ---------------------------
// ///      ІНШІ СТОРІНКИ
// /// ---------------------------
// class RidesPage extends StatelessWidget {
//   const RidesPage({super.key});
//   @override
//   Widget build(BuildContext context) =>
//       const Center(child: Text('Історія поїздок'));
// }

// class WalletPage extends StatelessWidget {
//   const WalletPage({super.key});
//   @override
//   Widget build(BuildContext context) =>
//       const Center(child: Text('Гаманець'));
// }

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthService>(
//       builder: (context, authService, child) {
//         if (!authService.isAuthenticated) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Профіль'),
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.person_outline, size: 64, color: Colors.grey),
//                   const SizedBox(height: 16),
//                   const Text('Увійдіть до свого акаунту'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const AuthPage()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('Увійти / Зареєструватися'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (authService.isLoading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = authService.user;
//         if (user == null) {
//           return const Scaffold(
//             body: Center(child: Text('Помилка завантаження профілю')),
//           );
//         }

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Профіль'),
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.logout),
//                 onPressed: () async {
//                   await authService.logout();
//                 },
//               ),
//             ],
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundColor: Colors.blue,
//                           child: Text(
//                             user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
//                             style: const TextStyle(fontSize: 32, color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           user.name,
//                           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(user.email, style: const TextStyle(color: Colors.grey)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Card(
//                   child: Column(
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.phone),
//                         title: const Text('Телефон'),
//                         subtitle: Text(user.phoneNumber),
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.account_balance_wallet),
//                         title: const Text('Бонусний рахунок'),
//                         subtitle: Text('${user.bonusAccount} грн'),
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.notifications),
//                         title: const Text('Сповіщення'),
//                         subtitle: Text(user.notification ? 'Увімкнено' : 'Вимкнено'),
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.admin_panel_settings),
//                         title: const Text('Роль'),
//                         subtitle: Text(user.role),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'services/auth_service.dart';
import 'pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const ACCESS_TOKEN = String.fromEnvironment('ACCESS_TOKEN');
  mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => AuthService()..init(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),
    ),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _current = 0;

  final pages = const [
    MapPage(),
    RidesPage(),
    WalletPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: pages[_current],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _current,
          onTap: (i) => setState(() => _current = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trips'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final PanelController _panelController = PanelController();
  Scooter? _selectedScooter;
  mapbox.MapboxMap? _map;
  mapbox.PointAnnotationManager? _scooterManager;
  mapbox.PointAnnotationManager? _userManager;
  Timer? _ticker;
  double _currentUserLat = 0;
  double _currentUserLon = 0;
  List<Scooter> _scooters = [];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 25), (_) {
      _fetchAndShowScooters();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndCamera() async {
    final perm = await geo.Geolocator.requestPermission();
    if (perm == geo.LocationPermission.denied ||
        perm == geo.LocationPermission.deniedForever) {
      return;
    }

    final pos = await geo.Geolocator.getCurrentPosition();
    final point =
        mapbox.Point(coordinates: mapbox.Position(pos.longitude, pos.latitude));
    setState(() {
      _currentUserLat = pos.latitude;
      _currentUserLon = pos.longitude;
    });
    await _map?.flyTo(
      mapbox.CameraOptions(center: point, zoom: 4),
      mapbox.MapAnimationOptions(duration: 1500),
    );

    _userManager ??= await _map!.annotations.createPointAnnotationManager();
    await _userManager!.deleteAll();

    final icon = await _loadBytes('assets/images/pointer.png');
    await _userManager!.create(
      mapbox.PointAnnotationOptions(
        geometry: point,
        image: icon,
        iconSize: 0.15,
      ),
    );
  }

  Future<void> _fetchAndShowScooters() async {
    if (_map == null) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    final response = await authService.authenticatedGet('/vehicle');
    if (response.statusCode != 200) return;

    final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
    _scooters = raw
        .where((e) => e['currentLocation'] != null)
        .map((e) => Scooter.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    await _drawScooterMarkers(_scooters);
  }

  Future<void> _drawScooterMarkers(List<Scooter> list) async {
    _scooterManager ??= await _map!.annotations.createPointAnnotationManager();
    await _scooterManager!.deleteAll();
    final icon = await _loadBytes('assets/images/scooter.png');

    final options = list.map((s) => mapbox.PointAnnotationOptions(
      geometry: mapbox.Point(coordinates: mapbox.Position(s.lng, s.lat)),
      image: icon,
      iconSize: 0.12,
      textField: s.id,
    )).toList();

    await _scooterManager!.createMulti(options);

    _scooterManager!.addOnPointAnnotationClickListener(
      ScooterClickListener(list, (Scooter tapped) {
        setState(() {
          _selectedScooter = tapped;
        });
        _panelController.open();
      }),
    );
  }

  Future<Uint8List> _loadBytes(String path) async {
    final bytes = await rootBundle.load(path);
    return bytes.buffer.asUint8List();
  }

  Future<String?> _fetchDistance(double userLat, double userLon, String scooterId) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final path = '/vehicle/$scooterId/distance';
    final queryParams = {
      'userLat': userLat.toString(),
      'userLon': userLon.toString(),
    };
    try {
      final response = await auth.authenticatedGet(
        path,
        queryParams: queryParams,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['distance'] as String;
      }
    } catch (e) {
      debugPrint('Distance fetch error: $e');
    }
    return null;
  }

  void _startRental(Scooter scooter) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердження'),
        content: Text('Розпочати оренду самокату ${scooter.id.substring(0, 8)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Підтвердити'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await auth.startRental(
        scooter.id,
        scooter.lat,
        scooter.lng,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оренда розпочата успішно!')),
        );
        _panelController.close();
        _fetchAndShowScooters();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Помилка початку оренди')),
        );
      }
    }
  }

  void _endRental() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершення оренди'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Оберіть спосіб оплати:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Банківська картка'),
              onTap: () => Navigator.of(context).pop('CARD'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Бонусний рахунок'),
              onTap: () => Navigator.of(context).pop('BONUS'),
            ),
          ],
        ),
      ),
    );

    if (paymentMethod != null) {
      final success = await auth.endRental(
        _currentUserLat,
        _currentUserLon,
        paymentMethod,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оренда завершена успішно!')),
        );
        _panelController.close();
        _fetchAndShowScooters();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Помилка завершення оренди')),
        );
      }
    }
  }

  Widget _buildScooterPanel(ScrollController sc) {
    if (_selectedScooter == null) return Center(child: Text('Виберіть самокат'));
    final s = _selectedScooter!;
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        return FutureBuilder<String?>(
          future: _fetchDistance(_currentUserLat, _currentUserLon, s.id),
          builder: (context, snapshot) {
            final distance = snapshot.data ?? '...';
            final isScooterInUse = s.status == 'INUSE';
            final isMyActiveRental = auth.hasActiveRental && auth.activeRentalVehicleId == s.id;

            return ListView(
              controller: sc,
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Самокат ${s.id.substring(0, 8)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Статус: ${s.status}'),
                Text('Пробіг: ${s.runnedDistance.toStringAsFixed(1)} км'),
                Text('Дата випуску: ${s.releaseDate.toLocal()}'),
                Text('Відстань до вас: $distance', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                if (!auth.hasActiveRental && !isScooterInUse)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.electric_scooter),
                    label: const Text('Орендувати'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _startRental(s),
                  ),

                if (isMyActiveRental)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Завершити оренду'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _endRental(),
                  ),

                if (isScooterInUse && !isMyActiveRental)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Самокат зараз використовується',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),

                if (auth.hasActiveRental && !isMyActiveRental)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'У вас вже є активна оренда',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
        panelBuilder: (sc) => _buildScooterPanel(sc),
        body: mapbox.MapWidget(
          key: const ValueKey('map'),
          cameraOptions: mapbox.CameraOptions(
            center: mapbox.Point(coordinates: mapbox.Position(0.0, 0.0)),
            zoom: 1,
          ),
          onMapCreated: (controller) {
            _map = controller;
            _initLocationAndCamera();
            _fetchAndShowScooters();
          },
        ),
      ),
    );
  }
}

class Scooter {
  final String id;
  final double lat;
  final double lng;
  final String status;
  final double runnedDistance;
  final DateTime releaseDate;

  const Scooter({
    required this.id,
    required this.lat,
    required this.lng,
    required this.status,
    required this.runnedDistance,
    required this.releaseDate,
  });

  factory Scooter.fromJson(Map<String, dynamic> json) => Scooter(
        id: json['id'] as String,
        lat: (json['currentLocation']['latitude'] as num).toDouble(),
        lng: (json['currentLocation']['longitude'] as num).toDouble(),
        status: json['status'] as String,
        runnedDistance: (json['runnedDistance'] as num).toDouble(),
        releaseDate: DateTime.parse(json['releaseDate'] as String),
      );
}

class ScooterClickListener extends mapbox.OnPointAnnotationClickListener {
  final List<Scooter> scooters;
  final void Function(Scooter) onScooterTap;

  ScooterClickListener(this.scooters, this.onScooterTap);

  @override
  void onPointAnnotationClick(mapbox.PointAnnotation annotation) {
    final scooterId = annotation.textField;
    if (scooterId != null) {
      final index = scooters.indexWhere((s) => s.id == scooterId);
      if (index != -1) {
        final tapped = scooters[index];
        onScooterTap(tapped);
      }
    }
  }
}

class RidesPage extends StatelessWidget {
  const RidesPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Історія поїздок'));
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Гаманець'));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Профіль'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Увійдіть до свого акаунту'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Увійти / Зареєструватися'),
                  ),
                ],
              ),
            ),
          );
        }

        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authService.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Помилка завантаження профілю')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профіль'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authService.logout();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(user.email, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Телефон'),
                        subtitle: Text(user.phoneNumber),
                      ),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: const Text('Бонусний рахунок'),
                        subtitle: Text('${user.bonusAccount} грн'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Сповіщення'),
                        subtitle: Text(user.notification ? 'Увімкнено' : 'Вимкнено'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text('Роль'),
                        subtitle: Text(user.role),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
