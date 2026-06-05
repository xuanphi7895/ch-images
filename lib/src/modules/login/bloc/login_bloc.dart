import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/login/bloc/login_event.dart';
import 'package:images/src/modules/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEmailChanged>((event, emit) {
      emit(
        state.copyWith(
          email: event.email,
          status: LoginStatus.initial,
          errorMessage: null,
        ),
      );
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(
        state.copyWith(
          password: event.password,
          status: LoginStatus.initial,
          errorMessage: null,
        ),
      );
    });

    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Please enter a valid email and password.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final success =
        state.email == 'demo@images.app' && state.password == '123456';

    if (success) {
      emit(state.copyWith(status: LoginStatus.success, errorMessage: null));
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Invalid credentials. Use demo@images.app / 123456',
      ),
    );
  }
}
