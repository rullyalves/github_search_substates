class SearchState {}

class SearchError extends SearchState {}

class SearchSuccess extends SearchState {
  List results;
  SearchSuccess(this.results);
}

class SearchLoading extends SearchState {}

class SearchEmpty extends SearchState{}

class SearchNoTerm extends SearchState{}