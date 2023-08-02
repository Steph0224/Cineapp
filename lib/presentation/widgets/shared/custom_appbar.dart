import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.movie_creation_outlined, color: colors.primary),
                const SizedBox(width: 5),
                Text('Cinemapedia', style: titleStyle),
                const Spacer(),
                // const Expanded(child: SizedBox()),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search))
              ],
            ),
          ),
        ));
  }
}
