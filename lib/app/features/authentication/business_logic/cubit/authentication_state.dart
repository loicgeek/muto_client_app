part of 'authentication_cubit.dart';

@immutable
sealed class AuthenticationState {
  final UserModel? user;
  const AuthenticationState({this.user});
}

final class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final UserModel user;

  AuthenticationSuccess({required this.user});
}

class AuthenticationFailure extends AuthenticationState {
  final String message;
  const AuthenticationFailure({required this.message});
}
