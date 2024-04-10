abstract class DataServiceInterface {
  // Define the common methods for data operations
  Future<List<T>> readAll<T>();
  Future<T?> readById<T>(String id);
  Future<void> create<T>(T item);
  Future<void> update<T>(T item);
  Future<void> delete<T>(String id);
}
