import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';

enum ActivationStatus {
  NONE,
  SUCCESS,
  FAILED,
  SENDING,
}

class ActivationModel extends ChangeNotifier {
  String _publishedCode = '';
  ActivationStatus _activationStatus = ActivationStatus.NONE;
  get status => _activationStatus;
  get publishedCode => _publishedCode;
  final List<String> _activateCodeChars = List.generate(10, (index) => "");
  get activateCodeChars => _activateCodeChars;
  final ShareServiceInterface _shareService;
  final Logger _logger = Logger();
  ActivationModel(this._shareService);
  Future<void> getActivationCode() async {
    _activationStatus = ActivationStatus.SENDING;
    _shareService.getActivationCode().then((value) {
      this._publishedCode = value;
      _logger.d("got activation code: $_publishedCode");
      _activationStatus = _publishedCode.length > 0 ? ActivationStatus.SUCCESS : ActivationStatus.FAILED;
    }).onError((error, stackTrace) {
      _logger.e("failed get activation code cause:${error.toString()}");
      _logger.e(stackTrace);
      _activationStatus = ActivationStatus.FAILED;
    }).whenComplete(() => notifyListeners());
  }
  void setCodeValue(String value, int index) {
    _activateCodeChars[index] = value;
    String _activationCode = _activateCodeChars.join();
    if(_activationCode.length == 10) {
      _activationStatus = ActivationStatus.SENDING;
      notifyListeners();

      _shareService.importSchedule(_activationCode).then((result){
        _activationStatus = result ? ActivationStatus.SUCCESS : ActivationStatus.FAILED;
      }).onError((error, stackTrace) {
        _logger.e("failed activate");
        _logger.e(stackTrace);
        _activationStatus = ActivationStatus.FAILED;
      }).whenComplete(() {
        notifyListeners();
      });
    }
  }

  Future<ActivationStatus> activateCode(String _inputCode) async{
    _publishedCode = _inputCode;
    if(_publishedCode.length == 10) {
      _shareService.importSchedule(_publishedCode).then((result){
        return result ? ActivationStatus.SUCCESS : ActivationStatus.FAILED;
      }).onError((error, stackTrace) {
        _logger.e("failed activate cause by: ${error.toString()}");
        _logger.e(stackTrace);
        return ActivationStatus.FAILED;
      });
    }
    return ActivationStatus.FAILED;
  }
}