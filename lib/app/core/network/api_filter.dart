// Enum for filter types
enum FilterType {
  exact,
  partial,
  callback,
  range,
  array,
}

// Enum for sort direction
enum SortDirection {
  asc,
  desc,
}

// Base filter class
abstract class Filter {
  final String field;
  final FilterType type;
  final dynamic value;

  Filter({
    required this.field,
    required this.type,
    required this.value,
  });

  // Convert filter to query parameter format
  Map<String, dynamic> toQueryParam();
}

// Exact filter implementation
class ExactFilter extends Filter {
  ExactFilter({
    required String field,
    required dynamic value,
  }) : super(field: field, type: FilterType.exact, value: value);

  @override
  Map<String, dynamic> toQueryParam() {
    return {'filter[$field]': value};
  }
}

// Partial filter implementation
class PartialFilter extends Filter {
  PartialFilter({
    required super.field,
    required String super.value,
  }) : super(type: FilterType.partial);

  @override
  Map<String, dynamic> toQueryParam() {
    return {'filter[$field]': value};
  }
}

// Range filter implementation (for dates, numbers, etc.)
class RangeFilter extends Filter {
  final dynamic from;
  final dynamic to;

  RangeFilter({
    required String field,
    required this.from,
    required this.to,
  }) : super(field: field, type: FilterType.range, value: [from, to]);

  @override
  Map<String, dynamic> toQueryParam() {
    if (from is DateTime && to is DateTime) {
      return {
        'filter[$field][]': (from as DateTime).toIso8601String().split('T')[0],
        'filter[$field][]': (to as DateTime).toIso8601String().split('T')[0],
      };
    }
    return {
      'filter[$field][]': from,
      'filter[$field][]': to,
    };
  }
}

// Array filter implementation
class ArrayFilter extends Filter {
  ArrayFilter({
    required String field,
    required List<dynamic> values,
  }) : super(field: field, type: FilterType.array, value: values);

  @override
  Map<String, dynamic> toQueryParam() {
    final Map<String, dynamic> params = {};
    params['filter[$field]'] = (value as List).join(",");
    return params;
  }
}

// Custom callback filter implementation
class CallbackFilter extends Filter {
  final String callbackName;

  CallbackFilter({
    required String field,
    required this.callbackName,
    required dynamic value,
  }) : super(field: field, type: FilterType.callback, value: value);

  @override
  Map<String, dynamic> toQueryParam() {
    if (value is List) {
      final Map<String, dynamic> params = {};
      for (int i = 0; i < (value as List).length; i++) {
        params['filter[$callbackName][]'] = (value as List)[i];
      }
      return params;
    }
    return {'filter[$callbackName]': value};
  }
}

// Sort class
class Sort {
  final String field;
  final SortDirection direction;

  Sort({
    required this.field,
    this.direction = SortDirection.desc,
  });

  String toQueryParam() {
    return direction == SortDirection.asc ? field : '-$field';
  }

  // Static methods for common sorts
  static Sort byCreatedAt({SortDirection direction = SortDirection.desc}) =>
      Sort(field: 'created_at', direction: direction);

  static Sort byPrice({SortDirection direction = SortDirection.asc}) =>
      Sort(field: 'price', direction: direction);

  static Sort byPickupTime({SortDirection direction = SortDirection.asc}) =>
      Sort(field: 'pickup_scheduled_at', direction: direction);

  static Sort byDropoffTime({SortDirection direction = SortDirection.asc}) =>
      Sort(field: 'dropoff_scheduled_at', direction: direction);

  static Sort byDistance({SortDirection direction = SortDirection.asc}) =>
      Sort(field: 'distance_km', direction: direction);
}

// Include class
class Include {
  final String relation;

  Include(this.relation);

  static Include custom(String relation) => Include(relation);
}

// Main DeliveryFilter class
class ApiFilter {
  final List<Filter> _filters = [];
  final List<Sort> _sorts = [];
  final List<Include> _includes = [];
  int _perPage = 20;
  int _page = 1;

  // Pagination methods
  ApiFilter perPage(int count) {
    _perPage = count;
    return this;
  }

  ApiFilter page(int pageNumber) {
    _page = pageNumber;
    return this;
  }

  ApiFilter whereBetween(String field, dynamic from, dynamic to) {
    _filters.add(RangeFilter(field: field, from: from, to: to));
    return this;
  }

  // Generic filter methods
  ApiFilter whereExact(String field, dynamic value) {
    _filters.add(ExactFilter(field: field, value: value));
    return this;
  }

  ApiFilter wherePartial(String field, String value) {
    _filters.add(PartialFilter(field: field, value: value));
    return this;
  }

  ApiFilter whereRange(String field, dynamic from, dynamic to) {
    _filters.add(RangeFilter(field: field, from: from, to: to));
    return this;
  }

  ApiFilter whereIn(String field, List<dynamic> values) {
    _filters.add(ArrayFilter(field: field, values: values));
    return this;
  }

  ApiFilter whereCallback(String callbackName, dynamic value) {
    _filters.add(CallbackFilter(
      field: callbackName,
      callbackName: callbackName,
      value: value,
    ));
    return this;
  }

  // Sort methods
  ApiFilter orderBy(String field,
      {SortDirection direction = SortDirection.asc}) {
    _sorts.add(Sort(field: field, direction: direction));
    return this;
  }

  ApiFilter withRelation(String relation) {
    _includes.add(Include.custom(relation));
    return this;
  }

  ApiFilter withRelations(List<String> relations) {
    for (String relation in relations) {
      _includes.add(Include.custom(relation));
    }
    return this;
  }

  // Reset methods
  ApiFilter clearFilters() {
    _filters.clear();
    return this;
  }

  ApiFilter clearSorts() {
    _sorts.clear();
    return this;
  }

  ApiFilter clearIncludes() {
    _includes.clear();
    return this;
  }

  ApiFilter reset() {
    _filters.clear();
    _sorts.clear();
    _includes.clear();
    _perPage = 20;
    _page = 1;
    return this;
  }

  // Build query parameters
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'per_page': _perPage,
      'page': _page,
    };

    // Add filters
    for (Filter filter in _filters) {
      params.addAll(filter.toQueryParam());
    }

    // Add sorts
    if (_sorts.isNotEmpty) {
      params['sort'] = _sorts.map((sort) => sort.toQueryParam()).join(',');
    }

    // Add includes
    if (_includes.isNotEmpty) {
      params['include'] =
          _includes.map((include) => include.relation).join(',');
    }

    return params;
  }

  // Clone the filter for reuse
  ApiFilter clone() {
    final cloned = ApiFilter()
      .._perPage = _perPage
      .._page = _page;

    cloned._filters.addAll(_filters);
    cloned._sorts.addAll(_sorts);
    cloned._includes.addAll(_includes);

    return cloned;
  }
}
