import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/login/bloc/login_bloc.dart';
import 'package:images/src/modules/login/bloc/login_event.dart';
import 'package:images/src/modules/login/bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => LoginBloc(), child: const _LoginView());
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }

        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Login',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use demo@images.app and 123456',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              context.read<LoginBloc>().add(
                                LoginEmailChanged(value),
                              );
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'demo@images.app',
                              errorText:
                                  state.email.isEmpty || state.isEmailValid
                                  ? null
                                  : 'Enter a valid email',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: true,
                            onChanged: (value) {
                              context.read<LoginBloc>().add(
                                LoginPasswordChanged(value),
                              );
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              errorText:
                                  state.password.isEmpty ||
                                      state.isPasswordValid
                                  ? null
                                  : 'Minimum 6 characters',
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: state.canSubmit
                                  ? () {
                                      context.read<LoginBloc>().add(
                                        const LoginSubmitted(),
                                      );
                                    }
                                  : null,
                              child: state.status == LoginStatus.loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
