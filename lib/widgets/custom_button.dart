import 'package:flutter/material.dart';

/// Primary filled button
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final Widget? prefix;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.width,
    this.height = 52,
    this.icon,
    this.color,
    this.textColor,
    this.borderRadius = 14,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final finalTextColor = textColor ?? (outlined ? buttonColor : Colors.white);

    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: theme.outlinedButtonTheme.style?.copyWith(
            foregroundColor: WidgetStateProperty.all(finalTextColor),
            side: WidgetStateProperty.all(BorderSide(color: buttonColor, width: 1.2)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          child: _buildChild(finalTextColor),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return buttonColor.withValues(alpha: 0.5);
            }
            return buttonColor;
          }),
          foregroundColor: WidgetStateProperty.all(finalTextColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        child: _buildChild(finalTextColor),
      ),
    );
  }

  Widget _buildChild(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    Widget label = Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: contentColor,
        fontFamily: 'Poppins',
      ),
    );

    List<Widget> children = [];
    if (prefix != null) {
      children.add(prefix!);
      children.add(const SizedBox(width: 12));
    } else if (icon != null) {
      children.add(Icon(icon, size: 18, color: contentColor));
      children.add(const SizedBox(width: 8));
    }
    
    children.add(label);

    if (children.length == 1) return label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

/// Small icon button with label
class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    
    return TextButton.icon(
      onPressed: onPressed,
      style: theme.textButtonTheme.style?.copyWith(
        foregroundColor: WidgetStateProperty.all(buttonColor),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
