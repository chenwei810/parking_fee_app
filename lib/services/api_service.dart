// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/api_result.dart';
// import '../config/api_config.dart';
//
// class ApiService {
//   final http.Client _client = http.Client();
//
//   // 單一縣市查詢
//   Future<CityQueryResult> queryCityParkingBill(
//       String cityName,
//       String apiUrl,
//       String carId,
//       String carType,
//       {int timeout = 10}
//       ) async {
//     try {
//       // 替換 URL 中的參數
//       String url;
//       if (cityName == "高雄市" || cityName == "宜蘭縣") {
//         url = apiUrl
//             .replaceAll("{carid}", carId.toUpperCase())
//             .replaceAll("{cartype}", carType.toUpperCase());
//       } else if (cityName == "臺南市") {
//         url = apiUrl
//             .replaceAll("{CarID}", carId)
//             .replaceAll("{CarType}", carType);
//       } else {
//         url = apiUrl
//             .replaceAll("{CarID}", carId)
//             .replaceAll("{CarType}", carType);
//       }
//
//       // 設置請求頭
//       Map<String, String> headers = {
//         'accept': 'application/json',
//         'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
//       };
//
//       // 處理特殊的新北市請求
//       if (cityName == "新北市") {
//         headers['Content-Type'] = 'application/json';
//       }
//
//       // 發送請求
//       final response = await _client
//           .get(Uri.parse(url), headers: headers)
//           .timeout(Duration(seconds: timeout));
//
//       if (response.statusCode == 200) {
//         // 處理宜蘭縣可能存在的UTF-8 BOM問題
//         String responseBody;
//         if (cityName == "宜蘭縣") {
//           final List<int> bytes = response.bodyBytes;
//           if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
//             responseBody = utf8.decode(bytes.sublist(3));
//           } else {
//             responseBody = utf8.decode(bytes);
//           }
//         } else {
//           responseBody = response.body;
//         }
//
//         // 空回應的處理
//         if (responseBody.isEmpty) {
//           return CityQueryResult.error(cityName, "API回應為空");
//         }
//
//         // 解析JSON
//         final data = json.decode(responseBody);
//
//         // 處理查詢成功但無資料的情況（情境A）
//         if (data['Status'] == 'SUCCESS' && data['Result'] == null) {
//           return CityQueryResult(
//             city: cityName,
//             status: 'SUCCESS',
//             message: data['Message'] ?? '查詢成功，無待繳費用',
//             result: null,
//             rawResponse: data,
//           );
//         }
//
//         // 處理查詢成功且有資料的情況（情境B、C、D）
//         else if (data['Status'] == 'SUCCESS' && data['Result'] != null) {
//           return CityQueryResult(
//             city: cityName,
//             status: 'SUCCESS',
//             message: data['Message'] ?? '查詢成功',
//             result: ParkingBillResult.fromJson(data['Result']),
//             rawResponse: data,
//           );
//         }
//
//         // 處理查詢失敗的情況
//         else {
//           return CityQueryResult(
//             city: cityName,
//             status: data['Status'] ?? 'ERROR',
//             message: data['Message'] ?? '查詢失敗',
//             result: null,
//             rawResponse: data,
//           );
//         }
//       } else {
//         return CityQueryResult.error(cityName, "HTTP錯誤: ${response.statusCode}");
//       }
//     } on TimeoutException {
//       return CityQueryResult(
//         city: cityName,
//         status: "TIMEOUT",
//         message: "請求超時",
//         result: null,
//       );
//     } catch (e) {
//       // 高雄市特殊處理
//       if (e.toString().contains("500 Server Error") && cityName == "高雄市") {
//         try {
//           final alternateUrl = "https://kpp.tbkc.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{carid}/CarType/{cartype}"
//               .replaceAll("{carid}", carId.toUpperCase())
//               .replaceAll("{cartype}", carType.toUpperCase());
//
//           final altResponse = await _client
//               .get(Uri.parse(alternateUrl), headers: {
//             'accept': 'application/json',
//             'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
//           })
//               .timeout(Duration(seconds: timeout));
//
//           if (altResponse.statusCode == 200) {
//             final data = json.decode(altResponse.body);
//             return CityQueryResult(
//               city: cityName,
//               status: data['Status'] ?? 'ERROR',
//               message: data['Message'] ?? '',
//               result: data['Result'] != null ? ParkingBillResult.fromJson(data['Result']) : null,
//               rawResponse: data,
//             );
//           }
//         } catch (_) {
//           // 備用請求也失敗，繼續返回原始錯誤
//         }
//       }
//       return CityQueryResult.error(cityName, "異常: ${e.toString()}");
//     }
//   }
//
//   // 多縣市並行查詢
//   Future<List<CityQueryResult>> queryMultipleCities(
//       String carId,
//       String carType,
//       {List<String>? selectedCities}
//       ) async {
//     List<CityQueryResult> results = [];
//     List<Future<CityQueryResult>> futures = [];
//
//     // 確定查詢範圍
//     Map<String, CityAPI> citiesToQuery = {};
//     if (selectedCities != null && selectedCities.isNotEmpty) {
//       for (var city in selectedCities) {
//         final cityApi = ApiConfig.cityApis[city];
//         if (cityApi != null) {
//           citiesToQuery[city] = cityApi;
//         }
//       }
//     } else {
//       citiesToQuery = ApiConfig.cityApis;
//     }
//
//     // 依序提交查詢請求
//     for (var entry in citiesToQuery.entries) {
//       final cityName = entry.key;
//       final cityApi = entry.value;
//
//       int timeout = (cityName == "高雄市") ? 20 : 10;
//
//       futures.add(
//           queryCityParkingBill(cityName, cityApi.url, carId, carType, timeout: timeout)
//       );
//
//       // 為了不讓伺服器負載過大，每5個請求暫停一下
//       if (futures.length % 5 == 0) {
//         final partialResults = await Future.wait(futures);
//         results.addAll(partialResults);
//         futures = [];
//         await Future.delayed(Duration(milliseconds: 500));
//       }
//     }
//
//     // 處理剩餘的請求
//     if (futures.isNotEmpty) {
//       final partialResults = await Future.wait(futures);
//       results.addAll(partialResults);
//     }
//
//     return results;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/api_result.dart';
import '../config/api_config.dart';

class ApiService {
  final http.Client _client = http.Client();

  // CORS 代理服務的 URL (公共代理例子，實際使用時可能需要自己的代理)
  // final String _corsProxyUrl = 'http://myworks2.com/parkingfee/proxy.php?url=';
  final String _corsProxyUrl = 'https://myworks2.com/parkingfee/proxy.php?url=';
  // 單一縣市查詢
  Future<CityQueryResult> queryCityParkingBill(
      String cityName,
      String apiUrl,
      String carId,
      String carType,
      {int timeout = 10}
      ) async {
    try {
      // 替換 URL 中的參數
      String url;
      if (cityName == "高雄市" || cityName == "宜蘭縣") {
        url = apiUrl
            .replaceAll("{carid}", carId.toUpperCase())
            .replaceAll("{cartype}", carType.toUpperCase());
      } else if (cityName == "臺南市") {
        url = apiUrl
            .replaceAll("{CarID}", carId)
            .replaceAll("{CarType}", carType);
      } else {
        url = apiUrl
            .replaceAll("{CarID}", carId)
            .replaceAll("{CarType}", carType);
      }

      // 在 Web 環境中使用 CORS 代理
      if (kIsWeb) {
        url = _corsProxyUrl + url;
      }

      // 設置請求頭
      Map<String, String> headers = {
        'accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      };

      // 在 Web 環境中添加必要的 CORS 請求頭
      if (kIsWeb) {
        headers['Origin'] = 'https://myworks2.com';
        headers['X-Requested-With'] = 'XMLHttpRequest';
      }

      // 處理特殊的新北市請求
      if (cityName == "新北市") {
        headers['Content-Type'] = 'application/json';
      }

      // 發送請求
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        // 處理宜蘭縣可能存在的UTF-8 BOM問題
        String responseBody;
        if (cityName == "宜蘭縣") {
          final List<int> bytes = response.bodyBytes;
          if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
            responseBody = utf8.decode(bytes.sublist(3));
          } else {
            responseBody = utf8.decode(bytes);
          }
        } else {
          responseBody = response.body;
        }

        // 空回應的處理
        if (responseBody.isEmpty) {
          return CityQueryResult.error(cityName, "API回應為空");
        }

        // 解析JSON
        final data = json.decode(responseBody);

        // 處理查詢成功但無資料的情況（情境A）
        if (data['Status'] == 'SUCCESS' && data['Result'] == null) {
          return CityQueryResult(
            city: cityName,
            status: 'SUCCESS',
            message: data['Message'] ?? '查詢成功，無待繳費用',
            result: null,
            rawResponse: data,
          );
        }

        // 處理查詢成功且有資料的情況（情境B、C、D）
        else if (data['Status'] == 'SUCCESS' && data['Result'] != null) {
          return CityQueryResult(
            city: cityName,
            status: 'SUCCESS',
            message: data['Message'] ?? '查詢成功',
            result: ParkingBillResult.fromJson(data['Result']),
            rawResponse: data,
          );
        }

        // 處理查詢失敗的情況
        else {
          return CityQueryResult(
            city: cityName,
            status: data['Status'] ?? 'ERROR',
            message: data['Message'] ?? '查詢失敗',
            result: null,
            rawResponse: data,
          );
        }
      } else {
        return CityQueryResult.error(cityName, "HTTP錯誤: ${response.statusCode}");
      }
    } on TimeoutException {
      return CityQueryResult(
        city: cityName,
        status: "TIMEOUT",
        message: "請求超時",
        result: null,
      );
    } catch (e) {
      // 高雄市特殊處理
      if (e.toString().contains("500 Server Error") && cityName == "高雄市") {
        try {
          String alternateUrl = "https://kpp.tbkc.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{carid}/CarType/{cartype}"
              .replaceAll("{carid}", carId.toUpperCase())
              .replaceAll("{cartype}", carType.toUpperCase());

          // 在 Web 環境中使用 CORS 代理
          if (kIsWeb) {
            alternateUrl = _corsProxyUrl + alternateUrl;
          }

          Map<String, String> altHeaders = {
            'accept': 'application/json',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
          };

          // 在 Web 環境中添加必要的 CORS 請求頭
          if (kIsWeb) {
            altHeaders['Origin'] = 'https://myworks2.com';
            altHeaders['X-Requested-With'] = 'XMLHttpRequest';
          }

          final altResponse = await _client
              .get(Uri.parse(alternateUrl), headers: altHeaders)
              .timeout(Duration(seconds: timeout));

          if (altResponse.statusCode == 200) {
            final data = json.decode(altResponse.body);
            return CityQueryResult(
              city: cityName,
              status: data['Status'] ?? 'ERROR',
              message: data['Message'] ?? '',
              result: data['Result'] != null ? ParkingBillResult.fromJson(data['Result']) : null,
              rawResponse: data,
            );
          }
        } catch (_) {
          // 備用請求也失敗，繼續返回原始錯誤
        }
      }
      return CityQueryResult.error(cityName, "異常: ${e.toString()}");
    }
  }

  // 多縣市並行查詢
  Future<List<CityQueryResult>> queryMultipleCities(
      String carId,
      String carType,
      {List<String>? selectedCities}
      ) async {
    List<CityQueryResult> results = [];
    List<Future<CityQueryResult>> futures = [];

    // 確定查詢範圍
    Map<String, CityAPI> citiesToQuery = {};
    if (selectedCities != null && selectedCities.isNotEmpty) {
      for (var city in selectedCities) {
        final cityApi = ApiConfig.cityApis[city];
        if (cityApi != null) {
          citiesToQuery[city] = cityApi;
        }
      }
    } else {
      citiesToQuery = ApiConfig.cityApis;
    }

    // 依序提交查詢請求
    for (var entry in citiesToQuery.entries) {
      final cityName = entry.key;
      final cityApi = entry.value;

      int timeout = (cityName == "高雄市") ? 20 : 10;

      futures.add(
          queryCityParkingBill(cityName, cityApi.url, carId, carType, timeout: timeout)
      );

      // 為了不讓伺服器負載過大，每5個請求暫停一下
      if (futures.length % 5 == 0) {
        final partialResults = await Future.wait(futures);
        results.addAll(partialResults);
        futures = [];
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    // 處理剩餘的請求
    if (futures.isNotEmpty) {
      final partialResults = await Future.wait(futures);
      results.addAll(partialResults);
    }

    return results;
  }
}