import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'data/relatos_scope.dart';
import 'data/relatos_store.dart';
import 'data/sqlite_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  final repository = await SqliteRelatosRepository.open();
  final store = RelatosStore(repository);
  await store.load();

  runApp(
    RelatosScope(
      store: store,
      child: const RelatosApp(),
    ),
  );
}
