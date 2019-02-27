import 'package:github_search/blocs/SearchState.dart';
import 'package:github_search/models/SearchResult.dart';
import 'package:github_search/services/data/GithubService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';

class SearchBloc {
  GithubService _service = new GithubService();

  final _searchController = new BehaviorSubject<String>();
  Observable<String> get searchFlux => _searchController.stream;
  Sink<String> get searchEvent => _searchController.sink;

  Observable<SearchState> apiResultFlux;

  Observable<String> message;

  SearchBloc() {
    apiResultFlux = Observable.retryWhen(
        // stream
        () => searchFlux
            .distinct()
            //   .where((valor) => valor.length > 2)
            .debounce(Duration(milliseconds: 500))
            //   .asyncMap(_service.search)
            .switchMap(search),
        // lock stream

        (e, s) {
      print("TENTANDO NOVAMENTE KRL");
      return Observable.timer("a", Duration(seconds: 3));
    }).asBroadcastStream();

    message = Observable.combineLatest2<SearchState, String, String>(
        apiResultFlux, searchFlux, (a, b) {
      return b;
    }).asBroadcastStream();
  }

/*
  Stream<SearchResult> search(String term) async* {
    try {
      SearchResult result = await _service.search(term);
      if (result.items.isNotEmpty) {
        yield result;
      }
    } on DioError catch (error) {
      print(
          "erro aqui ----------------------------------------------------------------------------------------->>>>>>>>>>>>>>>>>");
      throw DioError(message: error.message, error: error);
    }
  }
*/

  Stream<SearchState> search(String term) async* {
    if (term.isEmpty) {
      yield SearchNoTerm();
    } else {
      yield SearchLoading();
      try {
        SearchResult result = await _service.search(term);
        if (result.items.isNotEmpty) {
          yield SearchSuccess(result.items);
        } else {
          yield SearchEmpty();
        }
      } on DioError catch (error) {
        yield SearchError();
        print(error.message);
        print(
            "erro aqui ----------------------------------------------------------------------------------------->>>>>>>>>>>>>>>>>");
        throw DioError(message: error.message, error: error);
      }
    }
  }

  void dispose() {
    _searchController?.close();
  }
}
