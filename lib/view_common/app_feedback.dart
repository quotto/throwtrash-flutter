import 'package:flutter/material.dart';
import 'package:throwtrash/models/trash_import_message.dart';

class AppFeedbackColors {
  static const successBackground = Colors.green;
  static const errorBackground = Colors.red;
  static const warningBackground = Colors.amber;
  static const foreground = Colors.white;
}

class AppFeedbackSnackBar {
  static SnackBar success(String message, {Duration? duration}) {
    return _build(
      message,
      backgroundColor: AppFeedbackColors.successBackground,
      duration: duration,
    );
  }

  static SnackBar error(String message, {Duration? duration}) {
    return _build(
      message,
      backgroundColor: AppFeedbackColors.errorBackground,
      duration: duration,
    );
  }

  static SnackBar warning(String message, {Duration? duration}) {
    return _build(
      message,
      backgroundColor: AppFeedbackColors.warningBackground,
      duration: duration,
    );
  }

  static SnackBar importMessage(
    TrashImportMessage importMessage, {
    Duration? duration,
  }) {
    return importMessage.isSuccess
        ? success(importMessage.message, duration: duration)
        : error(importMessage.message, duration: duration);
  }

  static SnackBar _build(
    String message, {
    required Color backgroundColor,
    Duration? duration,
  }) {
    return SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        message,
        style: TextStyle(color: AppFeedbackColors.foreground),
      ),
      duration: duration ?? Duration(seconds: 2),
    );
  }
}
