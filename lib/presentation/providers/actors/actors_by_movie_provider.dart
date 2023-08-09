import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/presentation/providers/actors/actors_repositories_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actorsByMovieProvider =
    StateNotifierProvider<ActorMapNotifier, Map<String, List<Actor>>>((ref) {
  final actorsRepository = ref.watch(actorRepositoryProvider).getActorsByMovie;

  return ActorMapNotifier(getActors: actorsRepository);
});

typedef GetActorCallBack = Future<List<Actor>> Function(String movieId);

class ActorMapNotifier extends StateNotifier<Map<String, List<Actor>>> {
  final GetActorCallBack getActors;

  ActorMapNotifier({required this.getActors}) : super({});

  Future<void> loadActors(String movieId) async {
    if (state[movieId] != null) return;

    final actors = await getActors(movieId);
    state = {...state, movieId: actors};
  }
}
