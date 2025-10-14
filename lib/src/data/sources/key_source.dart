abstract class KeySource {
  Future<bool> setKeyValue({
    required String nameKey,
    required dynamic value,
  });
  Future<Object?> getKeyValue({
    required String nameKey,
  });

  Future<bool> deleteKeyValue({
    required String nameKey,
  });
}
