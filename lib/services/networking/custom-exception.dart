class CustomException implements Exception {
  final String? message;
  final String prefix;

  CustomException(this.message, this.prefix);

  @override
  String toString() {
    return "$prefix${message ?? 'Unknown error'}";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([String? message]) : super(message, "Unauthorised: ");
}

class NotFoundException extends CustomException {
  NotFoundException([String? message]) : super(message, "Not Found: ");
}

class ServerException extends CustomException {
  ServerException([String? message]) : super(message, "Server Error: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}