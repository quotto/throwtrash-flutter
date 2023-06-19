import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:throwtrash/models/activate_response.dart';
import 'package:throwtrash/models/trash_data_response.dart';
import 'package:throwtrash/usecase/crash_report_interface.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/usecase/activation_api_interface.dart';
import 'package:throwtrash/usecase/trash_repository_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

class ShareService implements ShareServiceInterface {
  final ActivationApiInterface _activationApi;
  final UserServiceInterface _userService;
  final TrashRepositoryInterface _trashRepository;
  final _logger = Logger();
  final CrashReportInterface _crashReport;
  ShareService(this._activationApi, this._userService, this._trashRepository, this._crashReport);

  @override
  Future<String> getActivationCode() async {
    return await _activationApi.requestActivationCode(this._userService.user.id);
  }

  @override
  Future<bool> importSchedule(String activationCode) async {
    ActivateResponse? activateResponse = await this._activationApi.requestAuthorizationActivationCode(activationCode, _userService.user.id);
    if(activateResponse != null) {
      await _trashRepository.truncateAllTrashData();
      List<Future> insertList = [];
      (jsonDecode(activateResponse.description) as List<dynamic>).forEach((element) {
        insertList.add(_trashRepository.insertTrashData(TrashDataResponse.fromJson(element).toTrashData()));
      });
      try {
        await Future.wait(insertList);
        final updateResult = await _trashRepository.updateLastUpdateTime(
            activateResponse.timestamp);
        if(!updateResult) {
          _logger.e("最終更新日時の更新に失敗しました。");
          _crashReport.reportCrash(Exception("最終更新日時の更新に失敗しました。"), fatal: true);
        }
        return updateResult;
      } on Exception catch (e) {
        _logger.e(e);
        _crashReport.reportCrash(e, fatal: true);
        return false;
      }
    } else {
      final String message = "アクティベーションに失敗しました。";
      _logger.e(message);
      _crashReport.reportCrash(Exception(message), fatal: true);
      return false;
    }
  }
}