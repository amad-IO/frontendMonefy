import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../models/analytic/analytic_chart_data.dart';

class AnalyticService {
  Future<AnalyticChartData> fetchAnalytic({
    required String token,
    required String trend,
    required int month,
    required int year,
    required int week,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final queryParameters = {
      'trend': trend,
      'month': month.toString(),
      'year': year.toString(),
      if (trend == 'weekly') 'week': week.toString(),
    };

    final summaryUri = Uri.parse(
      '${AppConfig.baseUrl}/analytics/summary',
    ).replace(queryParameters: queryParameters);
    final categoryUri = Uri.parse(
      '${AppConfig.baseUrl}/analytics/top-categories',
    ).replace(queryParameters: {
      'trend': trend,
      'month': month.toString(),
      'year':  year.toString(),
      if (trend == 'weekly') 'week': week.toString(),
    });

    debugPrint('📊 Fetch analytic: $trend $year/$month week=$week');

    final responses = await Future.wait([
      http.get(summaryUri, headers: headers),
      http.get(categoryUri, headers: headers),
    ]);
    final summaryResponse = responses[0];
    final categoryResponse = responses[1];

    if (summaryResponse.statusCode != 200) {
      throw Exception(
        'Gagal memuat analytic summary '
        '(${summaryResponse.statusCode}): ${summaryResponse.body}',
      );
    }
    if (categoryResponse.statusCode != 200) {
      throw Exception(
        'Gagal memuat kategori analytic '
        '(${categoryResponse.statusCode}): ${categoryResponse.body}',
      );
    }

    return AnalyticChartData.fromJson(
      json.decode(summaryResponse.body) as Map<String, dynamic>,
      json.decode(categoryResponse.body) as Map<String, dynamic>,
      trend,
      month,
      year,
      week,
    );
  }
}
