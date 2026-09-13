import '../../../core/errors/app_exception.dart';

class MysteryDataException extends AppException {
  const MysteryDataException(super.message, {super.cause});
}

class MysteryValidationException extends AppException {
  const MysteryValidationException(super.message, {this.errors = const []});

  final List<String> errors;
}