import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/relatos_scope.dart';
import 'data/relatos_store.dart';
import 'data/sqlite_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = SqliteRelatosRepository();
  await repository.init();
  final store = RelatosStore(repository);
  await store.load();

  runApp(
    RelatosScope(
      store: store,
      child: const RelatosApp(),
    ),
  );
}
