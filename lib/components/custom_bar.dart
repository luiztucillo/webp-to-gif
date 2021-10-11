import 'package:flutter/material.dart';

class CustomBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? actions;
  final bool showLeading;

  const CustomBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            !showLeading || !Navigator.of(context).canPop()
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  subtitle == null
                      ? Container()
                      : Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                ],
              ),
            ),
            actions == null ? Container() : actions!,
          ],
        ),
      ),
    );
  }
}
