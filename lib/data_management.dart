import 'package:hive/hive.dart';

class MyDataRepository {
  // Define the box name
  static const String _boxName = 'myBox';

  // Function to open the Hive box
  static Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  // CRUD functions

  static Future<void> createData(String key, dynamic value) async {
    final box = await _openBox();
    await box.put(key, value);
    await box.close();
  }

  static Future<dynamic> readData(String key) async {
    final box = await _openBox();
    final value = box.get(key);
    await box.close();
    return value;
  }

  static Future<void> updateData(String key, dynamic value) async {
    final box = await _openBox();
    await box.put(key, value);
    await box.close();
  }

  static Future<void> deleteData(String key) async {
    final box = await _openBox();
    await box.delete(key);
    await box.close();
  }
}