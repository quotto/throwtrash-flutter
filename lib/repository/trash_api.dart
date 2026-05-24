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
    _mobileApiEndpoint = _configProvider.mobileApiUrl;
    _trashSearchApiEndpoint = _configProvider.trashSearchApiEndpoint;
    _trashSearchApiKey = _environmentProvider?.trashSearchApiKey ?? '';
  }

  static TrashApi? _instance;

  static void initialize(
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
    _logger.d("Register user and trash data@$_mobileApiEndpoint/register");
    _logger.d(jsonEncode(allTrashData));
    Uri endpointUri = Uri.parse("$_mobileApiEndpoint/register");
    http.Response response = await _httpClient.post(
      endpointUri,
      headers: {"content-type": "application/json;charset=utf-8"},
      body: json.encode({"platform": _platform}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      _logger.d("Success register: $body");
      return body.containsKey("id") && body.containsKey("timestamp")
          ? RegisterResponse(body["id"] as String, body["timestamp"] as int)
          : null;
    }
    _logger.d("Error register: ${response.body}");
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
    Uri endpointUri = Uri.parse("$_mobileApiEndpoint/update");
    http.Response response = await _httpClient.post(
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
      _logger.d("Success update: $body");
      return body.containsKey("timestamp")
          ? TrashUpdateResult(body["timestamp"] as int, UpdateResult.SUCCESS)
          : TrashUpdateResult(-1, UpdateResult.ERROR);
    } else if (response.statusCode == 400) {
      return TrashUpdateResult(-1, UpdateResult.NO_MATCH);
    } else {
      _logger.d("Error update: ${response.body}");
      return TrashUpdateResult(-1, UpdateResult.ERROR);
    }
  }

  @override
  Future<TrashSyncResult> syncTrashData(String userId) async {
    Uri endpointUri = Uri.parse("$_mobileApiEndpoint/sync?user_id=$userId");
    http.Response response = await _httpClient.get(
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
      return TrashSearchResult.failure('AI取り込み API の設定が不足しています。');
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
        final userFacingMessage = _toSearchErrorMessage(errorType);
        if (errorType != '' && errorType != 'unsupported_schedule') {
          return TrashSearchResult.failure(userFacingMessage);
        }
        final trashes = _decodeSearchTrashData(responseBody['trashes'] as List);
        if (trashes.isEmpty && errorType != '') {
          return TrashSearchResult.failure(userFacingMessage);
        }
        return TrashSearchResult.success(
          trashes,
          message: errorType == 'unsupported_schedule'
              ? userFacingMessage
              : 'ゴミ出し予定を取り込みました',
        );
      }

      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return TrashSearchResult.failure(
          _toUserFacingErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      _logger.e('Failed search trash schedule: $e');
    }
    return TrashSearchResult.failure(_toSearchErrorMessage('unknown'));
  }

  String _toSearchErrorMessage(String errorType) {
    switch (errorType) {
      case 'invalid_address':
        return '入力された住所に対応するゴミ出し予定を特定できませんでした。町名・丁目までのおおよその住所で再度お試しください。';
      case 'invalid_postal_code':
        return '入力された郵便番号に対応するゴミ出し予定を特定できませんでした。住所での取り込みをお試しください。';
      case 'unsupported_schedule':
        return '一部のゴミ出し予定を取り込めませんでした。取り込めなかった内容は手動で確認してください。';
      case 'unknown':
      default:
        return 'ゴミ出し予定の取り込みに失敗しました。時間をおいて再度お試しください。';
    }
  }

  String _toUserFacingErrorMessage(int statusCode) {
    switch (statusCode) {
      case 403:
      case 429:
      case 500:
      case 502:
      case 504:
        return _toSearchErrorMessage('unknown');
      default:
        return _toSearchErrorMessage('unknown');
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
