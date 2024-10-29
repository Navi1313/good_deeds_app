import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_fields/form_fields.dart';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:superbase_authentication_client/superbase_authentication_client.dart';
import 'package:user_repository/user_repository.dart';

part 'signup_state.dart';

/// {@template sign_up_cubit}
/// Cubit for sign up state management. It is used to change signup state from
/// initial to in progress, success or error. It also validates email, password,
/// name, surname and phone number fields.
/// {@endtemplate}
class SignUpCubit extends Cubit<SignupState> {
  /// {@macro sign_up_cubit}
  SignUpCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const SignupState.initial());

  final UserRepository _userRepository;

  /// Changes password visibility, making it visible or not.
  void changePasswordVisibility() => emit(
        state.copyWith(showPassword: !state.showPassword),
      );

  /// Emits initial state of signup screen. It is used to reset state.
  void resetState() => emit(const SignupState.initial());

  /// [Email] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [Email] and emmiting new [Email]
  /// validation state.
  void onEmailChanged(String newValue) {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final shouldValidate = previousEmailState.invalid;
    final newEmailState = shouldValidate
        ? Email.dirty(
            newValue,
          )
        : Email.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      email: newEmailState,
    );

    emit(newScreenState);
  }

  /// [Email] field was unfocused, here is checking if previous state
  /// with [Email] was valid, in order to indicate it in state after unfocus.
  void onEmailUnfocused() {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final previousEmailValue = previousEmailState.value;

    final newEmailState = Email.dirty(
      previousEmailValue,
    );
    final newScreenState = previousScreenState.copyWith(
      email: newEmailState,
    );
    emit(newScreenState);
  }

  /// [Password] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [Password] and emmiting new [Password]
  /// validation state.
  void onPasswordChanged(String newValue) {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final shouldValidate = previousPasswordState.invalid;
    final newPasswordState = shouldValidate
        ? Password.dirty(
            newValue,
          )
        : Password.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      password: newPasswordState,
    );

    emit(newScreenState);
  }

  void onPasswordUnfocused() {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final previousPasswordValue = previousPasswordState.value;

    final newPasswordState = Password.dirty(
      previousPasswordValue,
    );
    final newScreenState = previousScreenState.copyWith(
      password: newPasswordState,
    );
    emit(newScreenState);
  }

  /// [FullName] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [FullName] and emmiting new [FullName]
  /// validation state.
  void onFullNameChanged(String newValue) {
    final previousScreenState = state;
    final previousFullNameState = previousScreenState.fullName;
    final shouldValidate = previousFullNameState.invalid;
    final newFullNameState = shouldValidate
        ? FullName.dirty(
            newValue,
          )
        : FullName.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      fullName: newFullNameState,
    );

    emit(newScreenState);
  }

  /// [FullName] field was unfocused, here is checking if previous state with
  /// [FullName] was valid, in order to indicate it in state after unfocus.
  void onFullNameUnfocused() {
    final previousScreenState = state;
    final previousFullNameState = previousScreenState.fullName;
    final previousFullNameValue = previousFullNameState.value;

    final newFullNameState = FullName.dirty(
      previousFullNameValue,
    );
    final newScreenState = previousScreenState.copyWith(
      fullName: newFullNameState,
    );
    emit(newScreenState);
  }

  /// [Username] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [Username] and emmiting new [Username]
  /// validation state.
  void onUsernameChanged(String newValue) {
    final previousScreenState = state;
    final previousUsernameState = previousScreenState.username;
    final shouldValidate = previousUsernameState.invalid;
    final newSurnameState = shouldValidate
        ? Username.dirty(
            newValue,
          )
        : Username.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      username: newSurnameState,
    );

    emit(newScreenState);
  }

  void onUsernameUnfocused() {
    final previousScreenState = state;
    final previousUsernameState = previousScreenState.username;
    final previousUsernameValue = previousUsernameState.value;

    final newUsernameState = Username.dirty(
      previousUsernameValue,
    );
    final newScreenState = previousScreenState.copyWith(
      username: newUsernameState,
    );
    emit(newScreenState);
  }

  /// Toggle isDonor state.
  // ignore: avoid_positional_boolean_parameters
  void toggleIsDonor(bool value) {
    emit(state.copyWith(isDonor: value));
  }

  /// Defines method to submit form. It is used to check if all inputs are valid
  /// and if so, it is used to signup user.
  Future<void> onSubmit(
    File? avatarFile,
  ) async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final fullName = FullName.dirty(state.fullName.value);
    // Username is Orginisation Id :
    final username = Username.dirty(state.username.value);
    final isDonor = state.isDonor;
    final isFormValid =
        FormzValid([email, password, fullName, username]).isFormValid;

    final newState = state.copyWith(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
      submissionStatus: isFormValid ? SignUpSubmissionStatus.inProgress : null,
      isDonor: state.isDonor,
    );

    emit(newState);

    if (!isFormValid) return;

    try {
      String? imageUrlResponse;
      if (avatarFile != null) {
        final imageBytes =
            await PickImage().imageBytes(file: File(avatarFile.path));
        final avatarsStorage = Supabase.instance.client.storage.from('avatars');

        final fileExt = avatarFile.path.split('.').last.toLowerCase();
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = fileName;
        await avatarsStorage.uploadBinary(
          filePath,
          imageBytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
            cacheControl: '360000',
          ),
        );
        imageUrlResponse = await avatarsStorage.createSignedUrl(
          filePath,
          60 * 60 * 24 * 365 * 10,
        );
      }
      // Read the isDonor status from the provider
      await _userRepository.signUpWithPassword(
        password: state.password.value,
        fullName: state.fullName.value,
        username: state.username.value,
        email: state.email.value,
        avatarUrl: imageUrlResponse,
        isDonor: isDonor,
      );
      if (isClosed) return;
      emit(
        state.copyWith(submissionStatus: SignUpSubmissionStatus.success),
      );
    } catch (error, stackTrace) {
      _errorFormatter(error, stackTrace);
    }
  }

  /// Defines method to format error. It is used to format error in order to
  /// show it to user.
  void _errorFormatter(Object e, StackTrace stackTrace) {
    addError(e, stackTrace);

    final submissionStatus = switch (e) {
      SignUpWithPasswordFailure(:final AuthException error) => switch (
            error.statusCode?.parse) {
          HttpStatus.badRequest =>
            SignUpSubmissionStatus.emailAlreadyRegistered,
          _ => SignUpSubmissionStatus.error,
        },
      _ => SignUpSubmissionStatus.error,
    };

    final newState = state.copyWith(
      submissionStatus: submissionStatus,
    );
    emit(newState);
  }
// ignore: eol_at_end_of_file
}
