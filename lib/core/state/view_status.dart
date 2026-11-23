enum ViewStatus { initial, loading, success, failure }

extension ViewStatusX on ViewStatus {
  bool get isLoading =>
      this == ViewStatus.loading || this == ViewStatus.initial;
  bool get hasData => this == ViewStatus.success;
  bool get hasError => this == ViewStatus.failure;
}
