import 'package:dio/dio.dart';

/// The year, make, and model returned from a successful VIN decode.
class VinResult {
  final String? year;
  final String? make;
  final String? model;

  VinResult({this.year, this.make, this.model});

  /// True if the decode returned at least one useful field.
  bool get hasData => year != null || make != null || model != null;
}

/// Calls the free NHTSA vPIC API to decode a 17-character VIN.
/// Returns null if the VIN is invalid or the request fails.
class VinService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  static Future<VinResult?> decode(String vin) async {
    if (vin.length != 17) return null;
    // Legal VINs use A-H, J-N, P-R, S-Z, 0-9 only (no I, O, or Q).
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin.toUpperCase())) return null;
    try {
      final response = await _dio.get(
        'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$vin',
        queryParameters: {'format': 'json'},
      );
      final results = response.data['Results'] as List?;
      if (results == null) return null;

      String? getValue(String variable) {
        for (final item in results) {
          if (item['Variable'] == variable) {
            final val = item['Value']?.toString() ?? '';
            if (val.isEmpty || val == 'Not Applicable' || val == '0') {
              return null;
            }
            return val;
          }
        }
        return null;
      }

      final result = VinResult(
        year: getValue('Model Year'),
        make: getValue('Make'),
        model: getValue('Model'),
      );
      return result.hasData ? result : null;
    } catch (_) {
      return null;
    }
  }
}
