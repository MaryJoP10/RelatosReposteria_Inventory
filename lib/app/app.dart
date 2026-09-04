import 'package:flutter/material.dart';

import '../core/brand/brand_config.dart';
import '../core/theme/relatos_theme.dart';
import 'shell/main_shell.dart';

class RelatosApp extends StatelessWidget {
  const RelatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: BrandConfig.name,
      debugShowCheckedModeBanner: false,
      theme: RelatosTheme.light(),
      home: const MainShell(),
    );
  }
}
