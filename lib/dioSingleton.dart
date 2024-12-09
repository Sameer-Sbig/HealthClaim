import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioSingleton {
  static var _dioInstance;

  DioSingleton._(); // private constructor to prevent instantiation

  static Dio get dio {
    if (_dioInstance == null) {
      _dioInstance = Dio(BaseOptions(responseType: ResponseType.plain));
      // _dioInstance.httpClientAdapter = DefaultHttpClientAdapter()
      //   ..onHttpClientCreate = (client) {
      //     client.findProxy = (uri) {
      //       return "PROXY 10.22.101.31:8080";
      //     };
      //   };
    }
    return _dioInstance;
  }
}
