import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/expense.dart';
import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/models/user.dart' as User;
import 'package:tachles/core/models/user_building_association.dart';
import 'package:tachles/core/services/data_service_interface.dart';
import 'package:tachles/core/utils/logger.dart';

class SupabaseService implements DataServiceInterface {
  final supabase = Supabase.instance.client;

  @override
  Future<List<T>> readAll<T>() async {
    try {
      final response = await supabase.from(getTableName<T>()).select();
      final itemsJson = response as List<dynamic>;
      return itemsJson.map((json) => fromJson<T>(json)).toList();
    } catch (error) {
      Logger.error('Error fetching items of type $T: $error');
      return [];
    }
  }

  @override
  Future<T?> readById<T>(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await supabase
          .from(getTableName<T>())
          .select()
          .eq('id', id)
          .limit(1)
          .single();
      return fromJson<T>(response);
    } catch (error) {
      Logger.error('Error fetching item of type $T: with id $id: $error');
      return null;
    }
  }

  @override
  Future<void> create<T>(T item) async {
    try {
      await supabase.from(getTableName<T>()).insert(toJson(item));
    } catch (error) {
      Logger.error('Error creating item $item of type $T: $error');
      rethrow;
    }
  }

  @override
  Future<void> update<T>(T item) async {
    try {
      await supabase
          .from(getTableName<T>())
          .update(toJson(item))
          .eq('id', getId(item));
    } catch (error) {
      Logger.error('Error updating item $item of type $T: $error');
      rethrow;
    }
  }

  @override
  Future<void> delete<T>(String id) async {
    try {
      await supabase.from(getTableName<T>()).delete().eq('id', id);
    } catch (error) {
      Logger.error('Error deleting item of type $T: with id $id: $error');
      rethrow;
    }
  }

  Future<void> deleteWhere<T>(String column, dynamic value) async {
    try {
      await supabase.from(getTableName<T>()).delete().eq(column, value);
    } catch (error) {
      Logger.error(
          'Error deleting item of type $T: with column $column and value $value: $error');
      rethrow;
    }
  }

  Future<List<T>> readAllForBuilding<T>(String buildingId) async {
    try {
      final response = await supabase
          .from(getTableName<T>())
          .select()
          .eq('buildingId', buildingId);
      final itemsJson = response as List<dynamic>;
      return itemsJson.map((json) => fromJson<T>(json)).toList();
    } catch (error) {
      Logger.error('Error fetching items for building $buildingId: $error');
      return [];
    }
  }

  Future<List<T>> readAllForUser<T>(String id) async {
    try {
      final response =
          await supabase.from(getTableName<T>()).select().eq('id', id);
      final itemsJson = response as List<dynamic>;
      return itemsJson.map((json) => fromJson<T>(json)).toList();
    } catch (error) {
      Logger.error('Error fetching items for user $id: $error');
      return [];
    }
  }

  Future<List<T>> readAllForApartment<T>(String apartmentId) async {
    try {
      final response = await supabase
          .from(getTableName<T>())
          .select()
          .eq('apartmentId', apartmentId);
      final itemsJson = response as List<dynamic>;
      return itemsJson.map((json) => fromJson<T>(json)).toList();
    } catch (error) {
      Logger.error('Error fetching items for apartment $apartmentId: $error');
      return [];
    }
  }

  Future<T?> readByUserAndBuilding<T>(String userId, String buildingId) async {
    try {
      final response = await supabase
          .from(getTableName<T>())
          .select()
          .eq('userId', userId)
          .eq('buildingId', buildingId)
          .single();
      return fromJson<T>(response);
    } catch (error) {
      Logger.error(
          'Error fetching item of type $T for user $userId and building $buildingId: $error');
      return null;
    }
  }

  String getTableName<T>() {
    if (T == Building) return 'buildings';
    if (T == Apartment) return 'apartments';
    if (T == Expense) return 'expenses';
    if (T == Payment) return 'payments';
    if (T == User.User) return 'users';
    if (T == UserBuildingAssociation) return 'user_building_associations';
    throw Exception('Unknown type: $T');
  }

  dynamic getId<T>(T item) {
    if (item is Building) return item.id;
    if (item is Apartment) return item.id;
    if (item is Expense) return item.id;
    if (item is Payment) return item.id;
    if (item is User.User) return item.id;
    if (item is UserBuildingAssociation)
      return '${item.userId}_${item.buildingId}';
    throw Exception('Unknown type: $T');
  }

  T fromJson<T>(Map<String, dynamic> json) {
    if (T == Building) return Building.fromJson(json) as T;
    if (T == Apartment) return Apartment.fromJson(json) as T;
    if (T == Expense) return Expense.fromJson(json) as T;
    if (T == Payment) return Payment.fromJson(json) as T;
    if (T == User.User) return User.User.fromJson(json) as T;
    if (T == UserBuildingAssociation)
      return UserBuildingAssociation.fromJson(json) as T;
    throw Exception('Unknown type: $T');
  }

  Map<String, dynamic> toJson<T>(T item) {
    if (item is Building) return item.toJson();
    if (item is Apartment) return item.toJson();
    if (item is Expense) return item.toJson();
    if (item is Payment) return item.toJson();
    if (item is User.User) return item.toJson();
    if (item is UserBuildingAssociation) return item.toJson();
    throw Exception('Unknown type: $T');
  }
}
