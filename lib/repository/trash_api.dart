import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/models/trash_search_result.dart';
import 'package:throwtrash/models/trash_sync_result.dart';
import 'package:throwtrash/models/trash_update_result.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';
import 'package:throwtrash/usecase/repository/trash_api_interface.dart';
import 'package:uuid/uuid.dart';

import '../models/trash_data_response.dart';

class TrashApi implements TrashApiInterface {
  final AppConfigProviderInterface _configProvider;
  final EnvironmentProviderInterface? _environmentProvider;
  final http.Client _httpClient;
  final _logger = Logger();
  late final String _mobileApiEndpoint;
  late final String _trashSearchApiEndpoint;
  late final String _trashSearchApiKey;
  String _platform = "web";
  TrashApi._(
    this._configProvider,
    this._httpClient, [
    this._environmentProvider,
  ]) {
    if (Platform.isAndroid) {
      _platform = "android";
    } else if (Platform.isIOS) {
      _platform = "ios";
    }
    this._mobileApiEndpoint = this._configProvider.mobileApiUrl;
    this._trashSearchApiEndpoint =
        _environmentProvider?.trashSearchApiEndpoint ?? '';
    this._trashSearchApiKey = _environmentProvider?.trashSearchApiKey ?? '';
  }

  static TrashApi? _instance;

  static initialize(
    AppConfigProviderInterface configProvider,
    http.Client httpClient, [
    EnvironmentProviderInterface? environmentProvider,
  ]) {
    if (_instance != null) {
      throw StateError("TrashApi is already initialized");
    }
    _instance = TrashApi._(configProvider, httpClient, environmentProvider);
  }

  factory TrashApi.createForTest(
    AppConfigProviderInterface configProvider,
    http.Client httpClient,
    EnvironmentProviderInterface environmentProvider,
  ) {
    return TrashApi._(configProvider, httpClient, environmentProvider);
  }

  factory TrashApi() {
    if (_instance == null) {
      throw StateError("TrashApi is not initialized");
    }
    return _instance!;
  }

  @override
  Future<RegisterResponse?> registerUserAndTrashData(
    List<TrashData> allTrashData,
  ) async {
    _logger.d(
      "Register user and trash data@${this._mobileApiEndpoint}/register",
    );
    _logger.d(jsonEncode(allTrashData));
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/register");
    http.Response response = await this._httpClient.post(
      endpointUri,
      headers: {"content-type": "application/json;charset=utf-8"},
      body: json.encode({"platform": _platform}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      _logger.d("Success register: " + body.toString());
      return body.containsKey("id") && body.containsKey("timestamp")
          ? RegisterResponse(body["id"] as String, body["timestamp"] as int)
          : null;
    }
    _logger.d("Error register: " + response.body);
    return null;
  }

  @override
  Future<TrashUpdateResult> updateTrashData(
    String id,
    List<TrashData> localSchedule,
    List<ExcludeDate> globalExcludes,
    int timestamp,
  ) async {
    _logger.d("Update trash data");
    Uri endpointUri = Uri.parse("${this._mobileApiEndpoint}/update");
    http.Response response = await this._httpClient.post(
      endpointUri,
      headers: {
        "content-type": "application/json;charset=utf-8",
        "Accept": "application/json",
      },
      body: json.encode({
        "id": id,
        "description": jsonEncode(localSchedule),
        "globalExcludes": globalExcludes.map((e) => e.toJson()).toList(),
        "platform": _platform,
        "timestamp": timestamp,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      _logger.d("Success update: " + body.toString());
      return body.containsKey("timestamp")
          ? TrashUpdateResult(body["timestamp"] as int, UpdateResult.SUCCESS)
          : TrashUpdateResult(-1, UpdateResult.ERROR);
    } else if (response.statusCode == 400) {
      return TrashUpdateResult(-1, UpdateResult.NO_MATCH);
    } else {
      _logger.d("Error update: " + response.body);
      return TrashUpdateResult(-1, UpdateResult.ERROR);
    }
  }

  @override
  Future<TrashSyncResult> syncTrashData(String userId) async {
    Uri endpointUri = Uri.parse(
      "${this._mobileApiEndpoint}/sync?user_id=$userId",
    );
    http.Response response = await this._httpClient.get(
      endpointUri,
      headers: {
        "content-type": "text/html;charset=utf8",
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        TrashApiSyncDataResponse trashResponse =
            TrashApiSyncDataResponse.fromJson(
              jsonDecode(utf8.decode(response.bodyBytes)),
            );
        _logger.d(trashResponse.description);
        List<TrashData> trashDataList =
            (jsonDecode(trashResponse.description) as List<dynamic>)
                .map<TrashData>((element) {
                  _logger.d(element);
                  return TrashDataResponse.fromJson(element).toTrashData();
                })
                .toList();
        return TrashSyncResult(
          trashDataList,
          trashResponse.globalExcludes,
          trashResponse.timestamp,
          TrashApiSyncStatus.SUCCESS,
        );
      } catch (e) {
        _logger.e("failed decode remote trash data cause by: $e");
        return TrashSyncResult([], [], -1, TrashApiSyncStatus.ERROR);
      }
    } else {
      _logger.e("failed get remote trash data cause by: ${response.body}");
      return TrashSyncResult([], [], -1, TrashApiSyncStatus.ERROR);
    }
  }

  @override
  Future<TrashSearchResult> searchTrashSchedule(
    String input,
    TrashSearchInputType inputType,
  ) async {
    if (_trashSearchApiEndpoint.isEmpty || _trashSearchApiKey.isEmpty) {
      return TrashSearchResult.failure('自動取り込み API の設定が不足しています。');
    }
    try {
      Uri endpointUri = Uri.parse("$_trashSearchApiEndpoint/search");
      final body = inputType == TrashSearchInputType.postalCode
          ? {'postal_code': input}
          : {'address': input};
      http.Response response = await _httpClient.post(
        endpointUri,
        headers: {
          "content-type": "application/json;charset=utf-8",
          "Accept": "application/json",
          "x-api-key": _trashSearchApiKey,
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final responseBody = decoded as Map<String, dynamic>;
        final errorType = responseBody['error_type'] as String? ?? '';
        if (errorType != '' && errorType != 'unsupported_schedule') {
          return TrashSearchResult.failure(
            responseBody['message'] as String? ?? '自動取り込みに失敗しました。',
          );
        }
        final trashes = _decodeSearchTrashData(responseBody['trashes'] as List);
        if (trashes.isEmpty && errorType != '') {
          return TrashSearchResult.failure(
            responseBody['message'] as String? ?? '自動取り込みに失敗しました。',
          );
        }
        return TrashSearchResult.success(trashes);
      }

      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return TrashSearchResult.failure(
          _toUserFacingErrorMessage(
            response.statusCode,
            decoded['message'] as String,
          ),
        );
      }
    } catch (e) {
      _logger.e('Failed search trash schedule: $e');
    }
    return TrashSearchResult.failure('自動取り込みに失敗しました。');
  }

  String _toUserFacingErrorMessage(int statusCode, String message) {
    switch (statusCode) {
      case 403:
        return '自動取り込み API の認証に失敗しました。';
      case 429:
        return '自動取り込み API が混み合っています。時間をおいて再度お試しください。';
      case 500:
      case 502:
        return 'ゴミ出し予定の調査中に予期しないエラーが発生しました。';
      case 504:
        return 'ゴミ出し予定の調査がタイムアウトしました。';
      default:
        return message;
    }
  }

  List<TrashData> _decodeSearchTrashData(List<dynamic> rawTrashes) {
    return rawTrashes
        .map((rawTrash) => rawTrash as Map<String, dynamic>)
        .map((rawTrash) {
          final schedules = (rawTrash['schedule'] as List<dynamic>? ?? [])
              .where((raw) {
                final rawSchedule = raw as Map<String, dynamic>;
                return rawSchedule['type'] != 'unsupported';
              })
              .map((raw) {
                final rawSchedule = raw as Map<String, dynamic>;
                final type = rawSchedule['type'] as String;
                final value = rawSchedule['value'];
                if (type == 'month') {
                  return TrashSchedule(type, value.toString());
                }
                if (type == 'evweek') {
                  final rawValue = value as Map<String, dynamic>;
                  return TrashSchedule(type, {
                    'weekday': rawValue['weekday'].toString(),
                    'interval': rawValue['interval'],
                    'start': rawValue['start_date'],
                  });
                }
                return TrashSchedule(type, value.toString());
              })
              .toList();
          if (schedules.isEmpty) {
            return null;
          }
          final type = rawTrash['type'] as String;
          return TrashData(
            id: Uuid().v4(),
            type: type,
            trashVal: type == 'other'
                ? rawTrash['trash_name'] as String? ?? 'その他'
                : '',
            schedules: schedules,
            excludes: [],
          );
        })
        .whereType<TrashData>()
        .toList();
  }
}
