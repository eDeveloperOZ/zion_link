// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:zion_link/core/models/building.dart';
// import 'package:zion_link/core/services/building_service.dart';
// import 'package:zion_link/core/services/storage_service.dart';

// class MockStorageService extends Mock implements StorageService {}

// void main() {
//   group('BuildingService Tests', () {
//     test('getAllBuildings returns a list of Building objects', () async {
//       final mockStorageService = MockStorageService();
//       final buildingService =
//           BuildingService(storageService: mockStorageService);

//       // Mock the response from the StorageService
//       when(mockStorageService.getAllBuildings()).thenAnswer((_) async => [
//             {
//               'id': '1',
//               'name': 'Test Building',
//               'address': '123 Test St',
//               'apartments': [],
//               'expenses': []
//             },
//           ]);

//       final buildings = await buildingService.getAllBuildings();

//       expect(buildings, isA<List<Building>>());
//       expect(buildings.length, 1);
//       expect(buildings.first.name, 'Test Building');
//     });
//   });
// }
