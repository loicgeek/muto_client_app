import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:muto_client_app/app/core/network/api_error.dart';
import 'package:muto_client_app/app/features/authentication/data/auth_repository.dart';
import 'package:muto_client_app/app/features/authentication/data/models/user_model.dart';

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

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthenticationLoading());
    try {
      final user = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(AuthenticationSuccess(user: user));
    } catch (e) {
      final error = ApiError.fromResponse(e);
      emit(AuthenticationFailure(message: error.message));
    }
  }

  Future<void> logout() async {
    emit(AuthenticationLoading(user: state.user));
    try {
      await _authRepository.logout();
      emit(AuthenticationInitial());
    } catch (e) {
      final error = ApiError.fromResponse(e);
      emit(AuthenticationFailure(message: error.message));
    }
  }

  Future<void> updateCourierOnlineStatus({required bool isOnline}) async {
    emit(AuthenticationLoading(user: state.user));
    try {
      var courier = await _authRepository.updateCourierOnlineStatus(
        id: state.user!.courier!.id!,
        isOnline: isOnline,
      );
      var user = state.user!;
      user.courier = courier;
      emit(AuthenticationSuccess(user: user));
    } catch (e) {
      final error = ApiError.fromResponse(e);
      emit(AuthenticationFailure(message: error.message));
    }
  }

  Future<void> checkAuth() async {
    emit(AuthenticationLoading(user: state.user));
    try {
      final user = await _authRepository.getAuthenticatedUser();
      emit(AuthenticationSuccess(user: user));
    } catch (e) {
      final error = ApiError.fromResponse(e);
      emit(AuthenticationFailure(
        message: error.message,
      ));
    }
  }
}
