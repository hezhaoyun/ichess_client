import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
    this.expandChildren = true,
  });

  const BottomBar.empty({super.key})
      : children = const [],
        expandChildren = true,
        mainAxisAlignment = MainAxisAlignment.spaceAround;

  /// Children to display in the bottom bar's [Row]. Typically instances of [BottomBarButton].
  final List<Widget> children;

  /// Alignment of the bottom bar's internal row. Defaults to [MainAxisAlignment.spaceAround].
  final MainAxisAlignment mainAxisAlignment;

  /// Whether to expand the children to fill the available space. Defaults to true.
  final bool expandChildren;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return ColoredBox(
        color: CupertinoTheme.of(context).barBackgroundColor,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: mainAxisAlignment,
              children: expandChildren ? children.map((child) => Expanded(child: child)).toList() : children,
            ),
          ),
        ),
      );
    }

    return BottomAppBar(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: expandChildren ? children.map((child) => Expanded(child: child)).toList() : children,
      ),
    );
  }
}