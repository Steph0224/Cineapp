import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoviePosterLink extends StatelessWidget {
  final Movie movie;

  const MoviePosterLink({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () => context.push('/home/0/movie/${movie.id}'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            movie.posterPath,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress != null) {
                return Image.asset(
                  'assets/poster-asset.png',
                  height: 220,
                  width: 146.7,
                );
              }

              return child;
            },
          ),
        ),
      ),
    );
  }
}
