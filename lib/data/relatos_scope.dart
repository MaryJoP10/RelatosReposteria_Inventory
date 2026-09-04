import 'package:flutter/material.dart';

import '../data/relatos_store.dart';

class RelatosScope extends InheritedNotifier<RelatosStore> {
  const RelatosScope({
    super.key,
    required RelatosStore store,
    required super.child,
  }) : super(notifier: store);

  static RelatosStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RelatosScope>();
    assert(scope != null, 'RelatosScope no encontrado.');
    return scope!.notifier!;
  }
}
