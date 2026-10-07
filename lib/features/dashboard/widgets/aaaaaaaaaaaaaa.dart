import 'package:fire_evacuation_app/features/dashboard/data/block.dart';
import 'package:flutter/material.dart';

class BlockContainer extends StatelessWidget {
  const BlockContainer({super.key, required this.block});

  final Block block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: block.width.toDouble(),
      height: block.length.toDouble(),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 74, 202, 211).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 3, color: Colors.black),
      ),
      child: Center(
        child: Text(
          block.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
