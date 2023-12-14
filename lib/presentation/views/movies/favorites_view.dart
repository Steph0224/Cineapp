import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {
  bool isLoading = false;
  bool isLastPage = false;

  void loadNextPage() async {
    if (isLastPage || isLastPage) return;
    isLoading = true;

    final movies =
        await ref.read(favoriteMoviesProvider.notifier).loadNextPage();

    if (movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  void initState() {
    super.initState();
    loadNextPage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final List<Movie> favoriteMovies =
        ref.watch(favoriteMoviesProvider).values.toList();

    return Scaffold(
        body: (favoriteMovies.isEmpty)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.movie_creation_outlined,
                        size: 60, color: colors.primary),
                    Text('Ohhh no!!',
                        style: TextStyle(fontSize: 30, color: colors.primary)),
                    Text('¡Marca tus peliculas favoritas!',
                        style:
                            TextStyle(fontSize: 20, color: colors.secondary)),
                    const SizedBox(height: 25),
                    FilledButton.tonal(
                        onPressed: () => context.go('/home/0'),
                        child: Text(
                          'Comienza a buscar',
                          style: TextStyle(color: colors.onBackground),
                        ))
                  ]))
            : MovieMasonry(movies: favoriteMovies, loadNextPage: loadNextPage));
  }
}
