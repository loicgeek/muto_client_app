part of 'current_delivery_cubit.dart';

@immutable
sealed class CurrentDeliveryState {
  final DeliveryModel? delivery;
  const CurrentDeliveryState({this.delivery});
}

class CurrentDeliveryInitial extends CurrentDeliveryState {
  const CurrentDeliveryInitial();
}

class ActivateDeliveryLoading extends CurrentDeliveryState {
  const ActivateDeliveryLoading({super.delivery});
}

class ActivateDeliverySuccess extends CurrentDeliveryState {
  const ActivateDeliverySuccess({super.delivery});
}

class ActivateDeliveryFailure extends CurrentDeliveryState {
  final ApiError error;
  const ActivateDeliveryFailure({required this.error, super.delivery});
}
