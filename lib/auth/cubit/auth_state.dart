import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthSendingOtp extends AuthState {} // sending or resending OTP

class AuthVerifyingOtp extends AuthState {} // verifying entered OTP

class AuthCodeSent extends AuthState {
  const AuthCodeSent({required this.verificationId, required this.phoneNumber});
  final String verificationId;
  final String phoneNumber;

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class AuthVerificationFailed extends AuthState {
  const AuthVerificationFailed(this.error);
  final String error;
  @override
  List<Object> get props => [error];
}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  const AuthError(this.error);
  final String error;
  @override
  List<Object> get props => [error];
}
