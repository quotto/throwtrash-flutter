import 'dart:convert';

import 'package:throwtrash/models/activate_response.dart';
import 'package:throwtrash/models/trash_data_response.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/repository/activation_api_interface.dart';
import 'package:throwtrash/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

class ShareService implements ShareServiceInterface {
  final ActivationApiInterface _activationApi;
  final UserServiceInterface _userService;
  final TrashRepositoryInterface _trashRepository;
  ShareService(this._activationApi, this._userService, this._trashRepository);
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
      await Future.wait(insertList);
      return await _trashRepository.updateLastUpdateTime(activateResponse.timestamp);
    }
    return false;
  }
}