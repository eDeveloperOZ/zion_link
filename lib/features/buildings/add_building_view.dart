import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/services/crud/building_service.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/utils/logger.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';
import 'package:tachles/features/buildings/apartment_bulk_add_screen.dart';

class AddBuildingView extends StatefulWidget {
  final Function addBuildingCallback;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberOfApartmentsController =
      TextEditingController();
  bool addApartmentCallback = true;

  AddBuildingView({required this.addBuildingCallback});

  @override
  _AddBuildingViewState createState() => _AddBuildingViewState();
}

class _AddBuildingViewState extends State<AddBuildingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('הוסף בניין'),
      ),
      body: Column(
        children: [
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(labelText: 'שם בניין: כתובת'),
          ),
          TextField(
            controller: widget.numberOfApartmentsController,
            decoration: InputDecoration(labelText: 'מספר דירות'),
            keyboardType: TextInputType.number,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (widget.nameController.text.isEmpty ||
                      widget.numberOfApartmentsController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      ErrorMessageWidget.create(
                          message:
                              'שגיאה ביצירת הבניין: שם הבניין ומספר הדירות הם שדות חובה'),
                    );
                    return;
                  }

                  final int numberOfApartments =
                      int.tryParse(widget.numberOfApartmentsController.text) ??
                          0;
                  if (numberOfApartments < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      ErrorMessageWidget.create(
                          message:
                              'שגיאה ביצירת הבניין: מספר הדירות חייב להיות גדול מ-1'),
                    );
                    return;
                  }

                  // Create a new building object without apartments
                  final newBuilding = Building(
                    id: UniqueKey().toString(),
                    name: widget.nameController.text,
                    balance: 0.0,
                    address: widget
                        .nameController.text, // Use the name field for address
                  );

                  List<Apartment> apartments =
                      List.generate(numberOfApartments, (index) {
                    return Apartment(
                      id: UniqueKey().toString(),
                      buildingId: newBuilding.id,
                      number: "${index + 1}",
                      ownerId: "",
                      tenantId: "",
                      yearlyPaymentAmount: 0,
                      pastDebt: 0,
                    );
                  });

                  // Use BuildingService to create the new building
                  try {
                    await BuildingService().createBuilding(newBuilding,
                        Supabase.instance.client.auth.currentUser!.id);

                    for (var apartment in apartments) {
                      await ApartmentService().createApartment(apartment);
                    }
                  } catch (e) {
                    Logger.error('Error creating building: $e');
                    BuildingService().deleteBuilding(newBuilding.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      ErrorMessageWidget.create(message: 'שגיאה ביצירת הבניין'),
                    );
                  }
                  try {
                    if (widget.addApartmentCallback) {
                      if (widget.addApartmentCallback) {
                        Future.delayed(Duration.zero, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApartmentBulkAddScreen(
                                  apartments: apartments),
                            ),
                          );
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SuccessMessageWidget.create(
                            message: 'הבניין נוצר בהצלחה'),
                      );
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    Logger.error('Error creating apartments: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      ErrorMessageWidget.create(message: 'שגיאה ביצירת הדירות'),
                    );
                  }

                  // Callback and navigation remain the same
                  widget.addBuildingCallback();
                },
                child: Text('הוסף'),
              ),
              Text('ערוך דירות'),
              Checkbox(
                value: widget.addApartmentCallback,
                onChanged: (value) {
                  setState(() {
                    widget.addApartmentCallback = value!;
                    print(widget.addApartmentCallback);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
