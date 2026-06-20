import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/errors/failure.dart';

enum ProviderStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

abstract class BaseProvider extends ChangeNotifier {
  ProviderStatus _status = ProviderStatus.initial;
  Failure? _failure;
  bool _disposed = false;

  ProviderStatus get status => _status;
  Failure? get failure => _failure;
  bool get isInitial => _status == ProviderStatus.initial;
  bool get isLoading => _status == ProviderStatus.loading;
  bool get hasError => _status == ProviderStatus.error;
  bool get isEmpty => _status == ProviderStatus.empty;
  bool get isSuccess => _status == ProviderStatus.success;

  void setLoading() {
    _failure = null;
    _setStatus(ProviderStatus.loading);
  }

  void setSuccess() {
    _failure = null;
    _setStatus(ProviderStatus.success);
  }

  void setEmpty() {
    _failure = null;
    _setStatus(ProviderStatus.empty);
  }

  void setFailure(Object error) {
    _failure = _mapFailure(error);
    _setStatus(ProviderStatus.error);
  }

  void resetState() {
    _failure = null;
    _setStatus(ProviderStatus.initial);
  }

  Future<void> runGuarded(Future<void> Function() action) async {
    setLoading();

    try {
      await action();
      setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Failure _mapFailure(Object error) {
    if (error is AppException) {
      return Failure(
        message: error.message,
        code: error.code,
        cause: error.cause,
      );
    }

    return Failure(message: error.toString(), cause: error);
  }

  void _setStatus(ProviderStatus status) {
    _status = status;
    safeNotifyListeners();
  }

  @protected
  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
