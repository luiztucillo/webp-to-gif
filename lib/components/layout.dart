import 'package:flutter/material.dart';

import 'custom_bar.dart';

class Layout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? barActions;
  final bool showLeading;

  const Layout({
    Key? key,
    required this.title,
    required this.body,
    this.subtitle,
    this.barActions,
    this.showLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomBar(
            title: title,
            subtitle: subtitle,
            showLeading: showLeading,
            actions: barActions,
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}
