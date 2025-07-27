import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:muto_driver_app/app/core/network/api_error.dart';
import 'package:muto_driver_app/app/features/authentication/data/auth_repository.dart';
import 'package:muto_driver_app/app/features/authentication/data/models/user_model.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepository _authRepository;
  AuthenticationCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthenticationInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthenticationLoading());
    try {
      final user =
          await _authRepository.login(email: email, password: password);
      emit(AuthenticationSuccess(user: user));
    } catch (e) {
      final error = ApiError.fromResponse(e);
      emit(AuthenticationFailure(message: error.message));
    }
  }

  Future<void> checkAuth() async {
    emit(AuthenticationLoading());
    try {
      final user = await _authRepository.getAuthenticatedUser();
      emit(AuthenticationSuccess(user: user));
    } catch (e) {
      final error = ApiError.fromResponse(e);
      emit(AuthenticationFailure(message: error.message));
    }
  }
}
