import 'package:flutter/material.dart';

/// Shown when the user has no favourites in the home panel.
class HomeFavouritesEmpty extends StatelessWidget {
  const HomeFavouritesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No favourites yet. Tap the star on a style to add it!',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
