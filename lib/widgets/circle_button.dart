import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final Color? borderColor;
  final Color? backgroundColor;
  final void Function() onClick;
  final Widget child;

   CircleButton({
    this.padding,
    this.border,
    this.borderColor,
    this.backgroundColor,
    required this.onClick,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(500.0),
          onTap: onClick,
          child: Padding(
            padding: padding == null ? const EdgeInsets.all(16) : padding!,
            child: child,
          ),
        ),
      ),
    );
  }
}
