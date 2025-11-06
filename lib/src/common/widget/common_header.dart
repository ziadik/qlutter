import 'package:flutter/material.dart';
import 'package:qlutter/src/common/widget/common_action.dart';

class SliverCommonHeader extends SliverAppBar {
  SliverCommonHeader({
    super.leading,
    super.automaticallyImplyLeading = true,
    super.pinned = true,
    super.floating = true,
    super.snap = true,
    super.title = const Text('Level'),
    super.surfaceTintColor = Colors.transparent,
    List<Widget>? actions,
    super.key,
  }) : super(actions: actions ?? CommonActions());
}

class CommonHeader extends AppBar {
  CommonHeader({
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title = const Text('Levels'),
    super.surfaceTintColor = Colors.transparent,
    List<Widget>? actions,
    super.key,
  }) : super(actions: actions ?? CommonActions());
}
