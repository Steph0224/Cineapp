import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key,
    required this.movieId,
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if (movie == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FadeIn(
            delay: const Duration(seconds: 1),
            child: Image.network(
              movie.posterPath,
              height: size.height * 0.75,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              _CustomSliverAppBar(movie: movie),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                childCount: 1,
                (context, index) => _MovieDetails(movie: movie),
              ))
            ],
          )
        ],
      ),
    );
  }
}

final isFavoriteProvider =
    FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.read(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId);
});

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, ref) {
    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      actions: [
        IconButton(
            onPressed: () async {
              await ref
                  .read(favoriteMoviesProvider.notifier)
                  .toggleFavorite(movie);
              ref.invalidate(isFavoriteProvider(movie.id));
            },
            icon: isFavoriteFuture.when(
              loading: () => const Icon(Icons.favorite_border),
              data: (isFavorite) => isFavorite
                  ? const Icon(Icons.favorite_rounded, color: Colors.red)
                  : const Icon(Icons.favorite_border),
              error: (_, __) => throw UnimplementedError(),
            ))
      ],
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        centerTitle: true,
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: child,
                  );
                },
              ),
            ),
            _CustomGradien(
              colors: [Colors.black87.withOpacity(0.4), Colors.transparent],
              stops: const [0.0, 0.17],
              begin: Alignment.topRight,
              end: Alignment.centerLeft,
            ),
            _CustomGradien(
              colors: [Colors.black87.withOpacity(0.4), Colors.transparent],
              stops: const [0.0, 0.17],
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
            ),
          ],
        ),
      ),
      // f
    );
  }
}

class _CustomGradien extends StatelessWidget {
  final List<Color> colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<double> stops;

  const _CustomGradien({
    required this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: colors, begin: begin!, end: end!, stops: stops)),
      ),
    );
  }
}

class _MovieDetails extends StatelessWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8), topLeft: Radius.circular(8)),
      child: Container(
        color: Colors.white,
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Imagen
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        movie.posterPath,
                        width: size.width * 0.3,
                        height: 225,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Descripcion
                    SizedBox(
                      width: (size.width - 40) * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.titleLarge,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            movie.overview,
                            maxLines: 9,
                            overflow: TextOverflow.ellipsis,
                            // style: textStyles.titleLarge,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    ...movie.genreIds.map((genre) => Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Chip(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            label: Text(genre),
                          ),
                        ))
                  ],
                ),
              ),
              _ActorsByMovie(movieId: movie.id.toString()),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;

  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final actorsByMovie = ref.watch(actorsByMovieProvider);

    if (actorsByMovie[movieId] == null) {
      return const CircularProgressIndicator(strokeWidth: 2);
    }

    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      actor.profilePath,
                      height: 180,
                      width: 135,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(actor.name, maxLines: 2),
                Text(
                  actor.character ?? '',
                  maxLines: 2,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
