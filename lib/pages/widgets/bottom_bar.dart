import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    Key? key,
    required this.color,
    this.primaryOnTap,
    this.primaryChild,
    this.showPrimaryButton = true,
    this.showSecondaryButton = false,
    this.secondaryOnTap,
    this.secondaryChild,
    this.backHeroTag,
    this.primaryHeroTag,
    this.secondaryHeroTag,
  }) : super(key: key);

  final Color? color;
  final bool showPrimaryButton;
  final bool showSecondaryButton;
  final VoidCallback? primaryOnTap;
  final VoidCallback? secondaryOnTap;
  final Widget? primaryChild;
  final Widget? secondaryChild;
  final String? backHeroTag;
  final String? primaryHeroTag;
  final String? secondaryHeroTag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            elevation: 0,
            heroTag: backHeroTag ?? 'back',
            backgroundColor: color,
            onPressed: () => Navigator.of(context).pop(),
            highlightElevation: 1,
            child: Icon(
              getBackIcon(),
              color: Colors.black54,
            ),
          ),
          Visibility(
            visible: showPrimaryButton,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: SizedBox(
              width: 100,
              height: 100,
              child: FittedBox(
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: primaryHeroTag ?? 'primary',
                  backgroundColor: color,
                  onPressed: primaryOnTap,
                  highlightElevation: 2,
                  child: primaryChild,
                ),
              ),
            ),
          ),
          Visibility(
            visible: showSecondaryButton,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: FloatingActionButton(
              elevation: 0,
              heroTag: secondaryHeroTag ?? 'secondary',
              backgroundColor: color,
              onPressed: secondaryOnTap,
              highlightElevation: 1,
              child: secondaryChild,
            ),
          ),
        ],
      ),
    );
  }

  IconData getBackIcon() {
    if (Platform.isIOS)
      return Icons.arrow_back_ios_new;
    else
      return Icons.arrow_back;
  }
}
