import 'package:throwtrash/models/trash_response.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/repository/activation_api_interface.dart';
import 'package:throwtrash/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';

class ShareService implements ShareServiceInterface {
  final ActivationApiInterface _activationApi;
  final UserServiceInterface _userService;
  final TrashRepositoryInterface _trashRepository;
  final TrashDataServiceInterface _trashDataService;
  ShareService(this._activationApi, this._userService, this._trashRepository, this._trashDataService);
  @override
  Future<String> getActivationCode() async {
    return await _activationApi.requestActivationCode(this._userService.user.id);
  }

  @override
  Future<bool> importSchedule(String activationCode) async {
    TrashResponse? trashResponse = await this._activationApi.requestAuthorizationActivationCode(activationCode);
    if(trashResponse != null) {
      // TODO 全てのスケジュールを差し替えるためTrashDataServiceを呼び出す
    }
    // TODO あとで消す
    return true;
  }

}