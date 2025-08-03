part of 'deliveries_cubit.dart';

@immutable
sealed class DeliveriesState {
  final PaginatedData<DeliveryModel>? pageData;
  const DeliveriesState({this.pageData});
}

class DeliveriesInitial extends DeliveriesState {
  const DeliveriesInitial();
}

class FetchDeliveriesLoading extends DeliveriesState {
  const FetchDeliveriesLoading({super.pageData});
}

class FetchDeliveriesSuccess extends DeliveriesState {
  const FetchDeliveriesSuccess({super.pageData});
}

class FetchDeliveriesFailure extends DeliveriesState {
  final ApiError error;
  const FetchDeliveriesFailure({required this.error, super.pageData});
}
