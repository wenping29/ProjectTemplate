import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 底部菜单项。
/// 实际项目可由服务端 `GET /api/menus/tree` 下发，实现「底部菜单配置」。
class MenuItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget page;

  const MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.page,
  });
}
