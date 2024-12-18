import 'package:flutter/material.dart';
import 'package:duration/duration.dart';

class PlayerListItem extends StatelessWidget {
  final String name;
  final int lives;
  final int tile;
  final int timeInGame;
  final int maxLives = 5;

  const PlayerListItem({
    super.key,
    required this.name,
    required this.lives,
    required this.tile,
    required this.timeInGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (tile != -1)
            Text(
              tile.toString(),
              style: const TextStyle(fontSize: 18),
            ),
          // Player's name
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (timeInGame > 0)
            Text(
              Duration(seconds: timeInGame)
                  .pretty(abbreviated: true, tersity: DurationTersity.second),
              style: const TextStyle(fontSize: 18),
            ),
          // Heart icons for lives
          if (lives != -1)
            Row(
              children: List.generate(
                lives,
                (index) => const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 24,
                ),
              )..addAll(
                  List.generate(
                    maxLives - lives, // Assume 5 is the maximum number of lives
                    (index) => const Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
            ),
        ],
      ),
    );
  }
}
