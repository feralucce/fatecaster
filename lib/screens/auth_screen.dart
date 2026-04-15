import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';

/// Entry-point auth screen with sign in / sign up selection.
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.casino_rounded,
                size: 96,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'FateCaster',
                style: AppStyles.heading1.copyWith(fontSize: 36),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Roll the dice. Shape your fate.',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                label: 'Sign In',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.login),
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Create Account',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.signup),
                variant: CustomButtonVariant.outlined,
                width: double.infinity,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
