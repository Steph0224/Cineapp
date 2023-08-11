import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMovieCallBack = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  List<Movie> initialMovies;
  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  StreamController<bool> isLoading = StreamController.broadcast();
  Timer? _debounceTimer;
  final SearchMovieCallBack searchMovies;

  SearchMovieDelegate({
    required this.initialMovies,
    required this.searchMovies,
  });

  void clearStreams() {
    debouncedMovies.close();
  }

  void _onQueryChanged(String query) {
    isLoading.add(true);

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    if (query.isEmpty) isLoading.add(false);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      isLoading.add(false);
      final movies = await searchMovies(query);
      initialMovies = movies;
      debouncedMovies.add(movies);
    });
  }

  Widget resultsAndSugestions() {
    return StreamBuilder(
      stream: debouncedMovies.stream,
      initialData: initialMovies,
      builder: (context, snapshot) {
        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return _MovieItem(
              movie: movies[index],
              onMovieSelected: (context, movie) {
                clearStreams();
                close(context, movie);
              },
            );
          },
        );
      },
    );
  }

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        stream: isLoading.stream,
        initialData: false,
        builder: (context, snapshot) {
          final loading = snapshot.data;

          if (loading == true) {
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 20,
              infinite: true,
              // animate: query.isNotEmpty,
              child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => query = ''),
            );
          }

          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
                icon: const Icon(Icons.clear_outlined),
                onPressed: () => query = ''),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          clearStreams();
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios_new_outlined));
  }

  @override
  Widget buildResults(BuildContext context) {
    return resultsAndSugestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);

    return resultsAndSugestions();
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({required this.movie, required this.onMovieSelected});
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            FadeIn(
              child: SizedBox(
                width: size.width * 0.2,
                height: 144,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    movie.posterPath,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress != null) {
                        return Image.asset('assets/poster-asset.png');
                      }

                      return FadeIn(child: child);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: textStyle.titleMedium,
                  ),
                  movie.overview.length > 100
                      ? Text('${movie.overview.substring(0, 100)}...')
                      : Text(movie.overview),
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded,
                          color: Colors.yellow.shade800),
                      const SizedBox(width: 5),
                      Text(
                        HumanFormats.number(movie.voteAverage, 1).toString(),
                        style: textStyle.bodyMedium!
                            .copyWith(color: Colors.yellow.shade800),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
