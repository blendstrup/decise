import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key,
    required this.flex,
    required this.color,
    required this.text,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final int flex;
  final Color? color;
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.black54),
                  SizedBox(width: 10),
                  Text(text, style: Theme.of(context).textTheme.headline4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
