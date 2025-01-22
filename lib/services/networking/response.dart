class Response<T> {
  final Status status;
  final T? data;
  final String? message;

  Response.loading([this.message]) 
    : status = Status.LOADING,
      data = null;

  Response.completed(this.data)
    : status = Status.COMPLETED,
      message = null;

  Response.error(this.message)
    : status = Status.ERROR,
      data = null;

  @override
  String toString() {
    return "Status: $status\nMessage: ${message ?? 'No message'}\nData: ${data ?? 'No data'}";
  }
}

enum Status { LOADING, COMPLETED, ERROR }