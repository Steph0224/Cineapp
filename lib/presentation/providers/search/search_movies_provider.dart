import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedMoviesProvider =
    StateNotifierProvider<SearchedMoviesNotifier, List<Movie>>((ref) {
  final searchMovies = ref.read(movieRepositoryProvider);

  return SearchedMoviesNotifier(
      ref: ref, searchMovies: searchMovies.searchMovies);
});

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchedMoviesNotifier extends StateNotifier<List<Movie>> {
  final Ref ref;
  final SearchMoviesCallback searchMovies;

  SearchedMoviesNotifier({required this.ref, required this.searchMovies})
      : super([]);

  Future<List<Movie>> searchMoviesByQuery(String query) async {
    ref.read(searchQueryProvider.notifier).update((state) => query);
    final List<Movie> movies = await searchMovies(query);
    state = movies;
    return movies;
  }
}
