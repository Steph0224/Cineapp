import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MovieMasonry extends StatefulWidget {
  final List<Movie> movies;
  final VoidCallback? loadNextPage;

  const MovieMasonry({super.key, required this.movies, this.loadNextPage});

  @override
  State<MovieMasonry> createState() => _MovieMasonryState();
}

class _MovieMasonryState extends State<MovieMasonry> {
  final ScrollController masonryScrollController =
      ScrollController(initialScrollOffset: 1);

  @override
  void initState() {
    super.initState();
    masonryScrollController.addListener(() async {
      if (widget.loadNextPage == null) return;

      await Future.delayed(const Duration(milliseconds: 500));
      if ((masonryScrollController.position.pixels + 100) >=
          (masonryScrollController.position.maxScrollExtent)) {
        widget.loadNextPage!();
      }
    });
  }

  @override
  void dispose() {
    masonryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        controller: masonryScrollController,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: widget.movies.length,
        crossAxisCount: 3,
        itemBuilder: (context, index) {
          if (index == 1) {
            return Column(
              children: [
                const SizedBox(height: 40),
                MoviePosterLink(
                  movie: widget.movies[index],
                )
              ],
            );
          }

          return MoviePosterLink(movie: widget.movies[index]);
        },
      ),
    );
  }
}
