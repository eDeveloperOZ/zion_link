// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:zion_link/core/models/apartment.dart';
// import 'package:zion_link/core/services/crud/apartment_service.dart';
// import 'package:zion_link/core/services/file_upload_service.dart';
// import 'package:zion_link/features/apartments/add_apartment_dialog.dart';
// import 'package:zion_link/features/apartments/edit_apartment_screen.dart';

// class MockApartmentService extends Mock implements ApartmentService {}

// class MockFileUploadService extends Mock implements FileUploadService {}

// void main() {
//   group('Apartment Flow Tests', () {
//     // Initialize directly here
//     final MockApartmentService mockApartmentService = MockApartmentService();
//     final MockFileUploadService mockFileUploadService = MockFileUploadService();

//     setUp(() {
//       // Reset or re-initialize mocks if necessary
//       reset(mockApartmentService);
//       reset(mockFileUploadService);
//     });

//     testWidgets('Add Apartment Dialog shows correctly',
//         (WidgetTester tester) async {
//       // Setup your mock expectations and widget test environment
//       when(mockApartmentService.addApartment()).thenAnswer((_) async =>
//           Apartment(
//               id: 'testId',
//               buildingId: 'testBuildingId',
//               number: '101',
//               ownerName: 'Owner 101',
//               tenantName: 'Tenant 101',
//               yearlyPaymentAmount: 1000,
//               payments: []));
//       await tester.pumpWidget(MaterialApp(
//         home: AddApartmentDialog(
//           buildingId: 'testBuildingId',
//           onAdd: (apartment) => null,
//           // The 'apartmentService' parameter is not defined in the AddApartmentDialog constructor.
//           // Therefore, this code snippet cannot be directly applied as is.
//           // To resolve this issue, ensure that the AddApartmentDialog widget is updated to accept an 'apartmentService' parameter.
//           // This change should be made in the add_apartment_dialog.dart file.
//         ),
//       ));

//       // Use `find` to locate widgets, buttons, text fields, etc.
//       final nameField = find.byKey(ValueKey('apartmentNameField'));
//       final addButton = find.byKey(ValueKey('addApartmentButton'));

//       // Use `tester.enterText`, `tester.tap`, and other actions to simulate user interaction
//       await tester.enterText(nameField, 'Apartment 101');
//       await tester.tap(addButton);
//       await tester.pumpAndSettle(); // Wait for animations to settle

//       // Verify the outcome
//       verify(mockApartmentService.addApartment(any)).called(1);
//     });

//     testWidgets('Edit Apartment Screen updates apartment correctly',
//         (WidgetTester tester) async {
//       // Setup your mock expectations and widget test environment
//       final testApartment = Apartment(
//           id: 'testId', name: 'Apartment 101', buildingId: 'testBuildingId');
//       when(mockApartmentService.updateApartment(any))
//           .thenAnswer((_) async => testApartment);

//       await tester.pumpWidget(MaterialApp(
//         home: EditApartmentScreen(
//           apartment: testApartment,
//           apartmentService: mockApartmentService,
//         ),
//       ));

//       // Use `find` to locate widgets, buttons, text fields, etc.
//       final nameField = find.byKey(ValueKey('apartmentNameField'));
//       final saveButton = find.byKey(ValueKey('saveApartmentButton'));

//       // Use `tester.enterText`, `tester.tap`, and other actions to simulate user interaction
//       await tester.enterText(nameField, 'Updated Apartment');
//       await tester.tap(saveButton);
//       await tester.pumpAndSettle(); // Wait for animations to settle

//       // Verify the outcome
//       verify(mockApartmentService.updateApartment(any)).called(1);
//     });

//     testWidgets('File Upload works within the Apartment context',
//         (WidgetTester tester) async {
//       // Setup mockFileUploadService to return a successful file upload
//       when(mockFileUploadService.uploadFile(any))
//           .thenAnswer((_) async => 'testFileUrl');

//       // Simulate file upload action within the apartment context (e.g., attaching a document to an apartment)
//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: Builder(
//             builder: (context) {
//               return ElevatedButton(
//                 onPressed: () async {
//                   final fileUrl =
//                       await mockFileUploadService.uploadFile('testFilePath');
//                   // Perform actions with the uploaded file URL
//                 },
//                 child: Text('Upload File'),
//               );
//             },
//           ),
//         ),
//       ));

//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pumpAndSettle();

//       // Verify the file upload was successful and the apartment context was updated accordingly
//       verify(mockFileUploadService.uploadFile(any)).called(1);
//       // Add assertions to verify the apartment context was updated with the file URL
//     });

//     // Add more tests as needed for deleting apartments, managing expenses, etc.
//   });
// }
