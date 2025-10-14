abstract class Failure implements Exception {
  String message = "Failure";

  @override
  String toString() {
    return "$runtimeType: $message";
  }
}
