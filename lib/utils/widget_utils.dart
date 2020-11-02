import 'package:flutter/widgets.dart';

extension WidgetUtils on State {
  void setStateSafely(VoidCallback fn) {
    if (!this.mounted) {
      return;
    }
    // ignore: invalid_use_of_protected_member
    this.setState(fn);
  }
}