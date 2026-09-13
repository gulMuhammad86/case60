import 'models/mystery.dart';

abstract interface class MysteryRepository {
  Future<List<Mystery>> getMysteries();

  Future<Mystery?> getMysteryById(String id);

  Future<Mystery> getTodayMystery({DateTime? date});
}
