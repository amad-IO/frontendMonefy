import 'package:flutter/material.dart';

import '../data/models/analytic/analytic_models.dart';
import '../data/services/analytic_service.dart';
import '../data/services/cache_service.dart';

class AnalyticProvider extends ChangeNotifier {
  final AnalyticService _service = AnalyticService();

  AnalyticChartData? _data;
  bool _isLoading = false;
  String? _error;
  String? _activeKey;
  int _requestGeneration = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _data != null;

  AnalyticSummary? getSummary({
    required bool isExpense,
    AnalyticSummary? localComparison,
  }) {
    return _data?.toAnalyticSummary(
      isExpense: isExpense,
      localComparison: localComparison,
    );
  }

  List<String> get chartLabels => _data?.chartLabels ?? const [];
  List<double> get chartIncome => _data?.chartIncome ?? const [];
  List<double> get chartExpense => _data?.chartExpense ?? const [];

  Future<void> loadAnalytic({
    required String token,
    required String trend,
    required int month,
    required int year,
    required int week,
  }) async {
    final key = _cacheKey(trend, month, year, week);
    final generation = ++_requestGeneration;
    _activeKey = key;

    final cached = CacheService.getAnalytic(
      trend: trend,
      month: month,
      year: year,
      week: week,
    );

    if (cached != null) {
      _data = cached;
      _isLoading = false;
      _error = null;
      notifyListeners();

      if (!cached.isStale) {
        _fetchFromServer(
          token: token,
          trend: trend,
          month: month,
          year: year,
          week: week,
          key: key,
          generation: generation,
        );
        return;
      }
    } else {
      _data = null;
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    await _fetchFromServer(
      token: token,
      trend: trend,
      month: month,
      year: year,
      week: week,
      key: key,
      generation: generation,
    );
  }

  Future<void> refresh({
    required String token,
    required String trend,
    required int month,
    required int year,
    required int week,
  }) async {
    final key = _cacheKey(trend, month, year, week);
    final generation = ++_requestGeneration;
    _activeKey = key;

    await CacheService.clearAnalyticKey(
      trend: trend,
      month: month,
      year: year,
      week: week,
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _fetchFromServer(
      token: token,
      trend: trend,
      month: month,
      year: year,
      week: week,
      key: key,
      generation: generation,
    );
  }

  Future<void> _fetchFromServer({
    required String token,
    required String trend,
    required int month,
    required int year,
    required int week,
    required String key,
    required int generation,
  }) async {
    try {
      final fresh = await _service.fetchAnalytic(
        token: token,
        trend: trend,
        month: month,
        year: year,
        week: week,
      );
      await CacheService.saveAnalytic(fresh);

      if (!_isCurrentRequest(key, generation)) return;
      _data = fresh;
      _error = null;
    } catch (e) {
      if (!_isCurrentRequest(key, generation)) return;
      _error = e.toString();
      debugPrint('❌ AnalyticProvider fetch error: $e');
    } finally {
      if (_isCurrentRequest(key, generation)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _isCurrentRequest(String key, int generation) =>
      _activeKey == key && _requestGeneration == generation;

  static String _cacheKey(String trend, int month, int year, int week) =>
      'analytic_${trend}_${year}_${month}_$week';
}
