import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../models/app_user.dart';
import '../../screens/home/home_screen.dart';
import '../../utils/app_validators.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.owner;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create PetPal account')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Padding(
              padding: const EdgeInsets.all(24),
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    DialogUtils.showErrorDialog(context, state.errorMessage!);
                  }
                  if (state.status == AuthStatus.authenticated) {
                    Navigator.pushReplacementNamed(
                      context,
                      HomeScreen.routeName,
                    );
                  }
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Full name',
                        validator: (value) =>
                            AppValidators.required(value, fieldName: 'Name'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: AppValidators.password,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<UserRole>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        onChanged: (role) =>
                            setState(() => _role = role ?? UserRole.owner),
                        items: UserRole.values
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                      ),
                      const Spacer(),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            label: 'Create account',
                            isLoading: state.isLoading,
                            onPressed: _submit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
            return constraints.maxWidth > 600
                ? Center(child: SizedBox(width: 480, child: content))
                : SingleChildScrollView(
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: content,
                    ),
                  );
          },
        ),
      ),
    );
  }
}
