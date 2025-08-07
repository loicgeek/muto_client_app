import 'package:bloc/bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:meta/meta.dart';
import 'package:muto_client_app/app/core/network/api_error.dart';
import 'package:muto_client_app/app/core/network/api_filter.dart';
import 'package:muto_client_app/app/features/home/data/models/delivery_model.dart';
import 'package:muto_client_app/app/features/home/repositories/deliveries_repository.dart';

part 'current_delivery_state.dart';

class CurrentDeliveryCubit extends Cubit<CurrentDeliveryState> {
  final DeliveriesRepository _deliveriesRepository;
  CurrentDeliveryCubit({required DeliveriesRepository deliveriesRepository})
      : _deliveriesRepository = deliveriesRepository,
        super(CurrentDeliveryInitial());
  Future checkCurrentDelivery({required int courierId}) async {
    emit(ActivateDeliveryLoading());
    try {
      final response = await _deliveriesRepository.fetchDeliveries(ApiFilter()
        ..whereExact("courier_id", courierId)
        ..whereIn("status", ['assigned']));
      if (response.data.isEmpty) {
        FlutterForegroundTask.removeData(key: 'current_delivery_id');
        emit(ActivateDeliverySuccess(delivery: null));
      } else {
        var deliveryDetails =
            await _deliveriesRepository.findOne(response.data.first.id!);
        try {
          FlutterForegroundTask.saveData(
            key: 'current_delivery_id',
            value: deliveryDetails.id!,
          );
        } catch (e) {}
        emit(ActivateDeliverySuccess(delivery: deliveryDetails));
      }
    } catch (e) {
      FlutterForegroundTask.removeData(key: 'current_delivery_id');
      emit(ActivateDeliveryFailure(
        error: ApiError.fromResponse(e),
        delivery: null,
      ));
    }
  }

  Future activate(DeliveryModel delivery) async {
    emit(ActivateDeliveryLoading());
    try {
      final response = await _deliveriesRepository.findOne(delivery.id!);
      emit(ActivateDeliverySuccess(delivery: response));
    } catch (e) {
      emit(ActivateDeliveryFailure(
        error: ApiError.fromResponse(e),
        delivery: state.delivery,
      ));
    }
  }
}
