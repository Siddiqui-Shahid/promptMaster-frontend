import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

void configureWebAdapter(Dio dio) {
  // Bearer JWT only — no cookies. withCredentials=false avoids extra CORS/PNA friction.
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: false);
}
