class CustomException implements Exception {
  final String? message;
  final String prefix;

  CustomException({
    required this.prefix,
    this.message,
  });

  @override
  String toString() {
    return '$prefix${message != null ? ': $message' : ''}';
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
      : super(
          prefix: 'Error During Communication',
          message: message,
        );
}

class BadRequestException extends CustomException {
  BadRequestException([String? message])
      : super(
          prefix: 'Invalid Request',
          message: message,
        );
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([String? message])
      : super(
          prefix: 'Unauthorised',
          message: message,
        );
}

class NotFoundException extends CustomException {
  NotFoundException([String? message])
      : super(
          prefix: 'Not Found',
          message: message,
        );
}

class ServerException extends CustomException {
  ServerException([String? message])
      : super(
          prefix: 'Server Error',
          message: message,
        );
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message])
      : super(
          prefix: 'Invalid Input',
          message: message,
        );
} 