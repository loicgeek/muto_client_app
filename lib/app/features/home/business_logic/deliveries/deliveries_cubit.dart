import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:muto_driver_app/app/core/network/api_error.dart';
import 'package:muto_driver_app/app/core/network/api_filter.dart';
import 'package:muto_driver_app/app/core/network/pagination.dart';
import 'package:muto_driver_app/app/features/home/data/models/delivery_model.dart';
import 'package:muto_driver_app/app/features/home/repositories/deliveries_repository.dart';

part 'deliveries_state.dart';

class DeliveriesCubit extends Cubit<DeliveriesState> {
  final DeliveriesRepository _deliveriesRepository;
  DeliveriesCubit({required DeliveriesRepository deliveriesRepository})
      : _deliveriesRepository = deliveriesRepository,
        super(DeliveriesInitial());
  Future fetchDeliveries(ApiFilter filter) async {
    emit(FetchDeliveriesLoading());
    try {
      final deliveries = await _deliveriesRepository.fetchDeliveries(filter);
      emit(FetchDeliveriesSuccess(pageData: deliveries));
    } catch (e) {
      emit(FetchDeliveriesFailure(
        error: ApiError.fromResponse(e),
        pageData: state.pageData,
      ));
    }
  }
}
