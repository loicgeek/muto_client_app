part of 'authentication_cubit.dart';

@immutable
sealed class AuthenticationState {
  final UserModel? user;
  const AuthenticationState({this.user});
}

final class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading({super.user});
}

class AuthenticationSuccess extends AuthenticationState {
  const AuthenticationSuccess({super.user});
}

class AuthenticationFailure extends AuthenticationState {
  final String message;
  const AuthenticationFailure({required this.message, super.user});
}
