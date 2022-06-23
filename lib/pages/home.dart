import 'package:flutter/material.dart';

import 'widgets/home_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    'Decise',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
              ),
            ),
            HomeCard(
              flex: 3,
              text: 'Numbers',
              color: Colors.yellow[300],
              icon: Icons.crop_square_rounded,
              onTap: () => Navigator.of(context).pushNamed('/number'),
            ),
            HomeCard(
              flex: 3,
              text: 'Wheel',
              color: Colors.red[300],
              icon: Icons.panorama_fish_eye_rounded,
              onTap: () => Navigator.of(context).pushNamed('/wheel'),
            ),
            Flexible(
              flex: 2,
              child: Center(
                child: Icon(
                  Icons.sentiment_very_satisfied,
                  size: 32,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
