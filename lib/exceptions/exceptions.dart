import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/storage_controll_dialogs.dart';

class Catcher {
  Catcher._();
  static final _instance = Catcher._();
  factory Catcher() => _instance;
  AppExceptionAbstract? _lastException;
  bool _isShowing = false;

  void showDialogForError(dynamic exception) {
    if (exception.toString().contains("Invalid statusCode") ||
        exception.toString().contains("No host")) {
      return;
    }
    late final AppExceptionAbstract exceptionToShow;
    if (exception is! AppExceptionAbstract) {
      exceptionToShow = AppException(exception.toString());
    } else {
      exceptionToShow = exception;
    }
    if (_lastException == exception && _isShowing) {
      return;
    }
    _isShowing = true;
    showDialog(
      builder: (context) {
        return exceptionToShow.dialogWidget(context);
      },
      context: Modular.routerDelegate.navigatorKey.currentContext!,
    ).then((value) => _isShowing = false);
  }
}

abstract class AppExceptionAbstract extends Equatable {
  final String message;
  const AppExceptionAbstract(this.message);

  Widget dialogWidget(BuildContext context);

  @override
  String toString() {
    return message;
  }

  @override
  List<Object?> get props => [message];
}

class AppException extends AppExceptionAbstract {
  const AppException(super.message);

  @override
  Widget dialogWidget(BuildContext context) {
    return AlertDialog(
      title: const Text('Error!'),
      actionsAlignment: MainAxisAlignment.center,
      content: Text(message),
      actions: [
        CustomButton(
          primary: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'OK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class NotEnoughStorageBalanceException extends AppExceptionAbstract {
  const NotEnoughStorageBalanceException()
      : super('Not enough storage balance');

  @override
  Widget dialogWidget(BuildContext context) {
    return BuyStorageDialog();
  }
}

class AccountNotActivatedException extends AppExceptionAbstract {
  const AccountNotActivatedException() : super('Account not activated');

  @override
  Widget dialogWidget(BuildContext context) {
    return ActivateAccountDialog();
  }
}
