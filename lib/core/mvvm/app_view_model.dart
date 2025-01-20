import 'dart:async';
import 'package:pknives/util/app_settings.dart';

import 'view_model.dart';

abstract class AppViewModel extends ViewModel {
  String _info = '';
  String _error = '';
  bool _locked = false;
  bool _isLoading = true;

  @override
  void notify() {
    super.notify();
    _clearMessages();
    if (_locked) {
      Timer(Delays.unlock, unlock);
    }
  }

  void lock() {
    _locked = true;
    super.notify();
  }

  void unlock() {
    _locked = false;
    super.notify();
  }

  void markAsLoaded() {
    _isLoading = false;
    notify();
  }

  void _clearMessages() {
    _info = '';
    _error = '';
  }

  void showAndQuit(String message) {
    _info = message;
    super.notify();
  }

  void refresh(void Function() prepare) {
    reset();
    prepare();
    notify();
  }

  void setDefaultMode() => refresh(() => {});
  void reset() {}

  set info(String val) => refresh(() => _info = val);
  set error(String val) => refresh(() => _error = val);

  String get info => _info;
  String get error => _error;
  bool get locked => _locked;
  bool get isLoading => _isLoading;
}