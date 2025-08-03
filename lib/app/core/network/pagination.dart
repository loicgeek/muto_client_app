class PaginatedData<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedData({
    required this.data,
    required this.meta,
  });

  factory PaginatedData.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedData(
      data:
          (json['data'] as List? ?? []).map((item) => fromJson(item)).toList(),
      meta: PaginationMeta.fromJson({
        'current_page': json['current_page'],
        'from': json['from'],
        'last_page': json['last_page'],
        'path': json['path'],
        'per_page': json['per_page'],
        'to': json['to'],
        'total': json['total'],
      }),
    );
  }
}

class PaginationMeta {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;

  PaginationMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}
