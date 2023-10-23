import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_ballet/auth/sign_up/models/sign_up_validation_result.dart';
import 'package:prime_ballet/auth/sign_up/provider/sign_up_provider.dart';
import 'package:prime_ballet/auth/sign_up/provider/sign_up_state.dart';

void main() {
  final ref = ProviderContainer();

  const validName = 'Name';
  const validEmail = 'Test@mail.com';
  const validPassword = 'Password12345';

  const serverObjectReturnedOnError = ['Incorrect field'];

  late StateNotifierProvider<SignUpProvider, SignUpState> provider;

  setUp(() {
    provider = StateNotifierProvider<SignUpProvider, SignUpState>(
      (ref) => SignUpProvider(),
    );
  });

  DioException createDioException({required Map<String, dynamic> data}) {
    return DioException(
      response: Response(
        data: data,
        requestOptions: RequestOptions(),
      ),
      requestOptions: RequestOptions(),
    );
  }

  test('Check initial state', () {
    expect(ref.read(provider), const SignUpState());
  });

  test('Check `nameFieldListener` method', () async {
    final notifier = ref.read(provider.notifier);

    await expectLater(ref.read(provider), const SignUpState());

    notifier.nameFieldValueHandler('test');
    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isNameEmpty: false),
      ),
    );

    notifier.nameFieldValueHandler('');
    await expectLater(ref.read(provider), const SignUpState());
  });

  test('Check `emailFieldListener` method', () async {
    final notifier = ref.read(provider.notifier);

    await expectLater(ref.read(provider), const SignUpState());

    notifier.emailFieldValueHandler('test');
    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isEmailEmpty: false),
      ),
    );

    notifier.emailFieldValueHandler('');
    await expectLater(ref.read(provider), const SignUpState());
  });

  test('Check `passwordFieldListener` method', () async {
    final notifier = ref.read(provider.notifier);

    await expectLater(ref.read(provider), const SignUpState());

    notifier.passwordFieldValueHandler('test');
    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isPasswordEmpty: false),
      ),
    );

    notifier.passwordFieldValueHandler('');
    await expectLater(ref.read(provider), const SignUpState());
  });

  test('Check `confirmPasswordFieldListener` method', () async {
    final notifier = ref.read(provider.notifier);

    await expectLater(ref.read(provider), const SignUpState());

    notifier.confirmPasswordFieldValueHandler('test');
    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isConfirmPasswordEmpty: false),
      ),
    );

    notifier.confirmPasswordFieldValueHandler('');
    await expectLater(ref.read(provider), const SignUpState());
  });

  test('check `isSetUpButtonEnable` state property', () async {
    final notifier = ref.read(provider.notifier)
      ..nameFieldValueHandler('test')
      ..emailFieldValueHandler('test')
      ..passwordFieldValueHandler('test')
      ..confirmPasswordFieldValueHandler('test');

    await expectLater(ref.read(provider).isSetUpButtonEnable, true);

    notifier.nameFieldValueHandler('');
    await expectLater(ref.read(provider).isSetUpButtonEnable, false);
  });

  test('Check `validate` method when name is not valid', () async {
    await ref.read(provider.notifier).validate(
          name: '_',
          email: validEmail,
          password: validPassword,
          confirmPassword: validPassword,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isNameInvalidError: true),
      ),
    );
  });

  test('Check `validate` method when email is not valid', () async {
    await ref.read(provider.notifier).validate(
          name: validName,
          email: '_',
          password: validPassword,
          confirmPassword: validPassword,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isEmailInvalidError: true),
      ),
    );
  });

  test('Check `validate` method when password is not valid', () async {
    const passwordAsLetters = 'password';

    await ref.read(provider.notifier).validate(
          name: validName,
          email: validEmail,
          password: passwordAsLetters,
          confirmPassword: passwordAsLetters,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isPasswordInvalidError: true),
      ),
    );

    const passwordAsNumbers = '12345678';

    await ref.read(provider.notifier).validate(
          name: validName,
          email: validEmail,
          password: passwordAsNumbers,
          confirmPassword: passwordAsNumbers,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isPasswordInvalidError: true),
      ),
    );

    const isPasswordShort = 'pass123';

    await ref.read(provider.notifier).validate(
          name: validName,
          email: validEmail,
          password: isPasswordShort,
          confirmPassword: isPasswordShort,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isPasswordInvalidError: true),
      ),
    );
  });

  test('Check `validate` method when confirm password is not match', () async {
    await ref.read(provider.notifier).validate(
          name: validName,
          email: validEmail,
          password: validPassword,
          confirmPassword: '_',
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(
        validationResult: SignUpValidationResult(isPasswordMismatchError: true),
      ),
    );
  });

  test('Check successful execution `validate` method', () async {
    await ref.read(provider.notifier).validate(
          name: validName,
          email: validEmail,
          password: validPassword,
          confirmPassword: validPassword,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(isValidationFinished: true),
    );
  });

  test('Check `resetValidationFinished` method', () async {
    await ref.read(provider.notifier).validate(
          name: validName,
          email: validEmail,
          password: validPassword,
          confirmPassword: validPassword,
        );

    await expectLater(
      ref.read(provider),
      const SignUpState(isValidationFinished: true),
    );

    ref.read(provider.notifier).resetValidationFinished();

    await expectLater(ref.read(provider).isValidationFinished, false);
  });

  test(
    'Check `handleVerificationResult` method when the passed `verificationResult`'
    ' argument is not of type `DioException`',
    () {
      expect(
        () => ref.read(provider.notifier).handleServerValidation('Test'),
        returnsNormally,
      );
    },
  );

  test(
    'Check `handleVerificationResult` method when name is not valid',
    () {
      ref
          .read(provider.notifier)
          .handleServerValidation(createDioException(data: {
            'name': serverObjectReturnedOnError,
          }));

      expect(
        ref.read(provider),
        const SignUpState(
          validationResult: SignUpValidationResult(
            isServerValidateError: true,
            serverValidateErrorTexts: serverObjectReturnedOnError,
            isNameInvalidError: true,
          ),
        ),
      );
    },
  );

  test(
    'Check `handleVerificationResult` method when email is not valid',
    () {
      ref
          .read(provider.notifier)
          .handleServerValidation(createDioException(data: {
            'email': serverObjectReturnedOnError,
          }));

      expect(
        ref.read(provider),
        const SignUpState(
          validationResult: SignUpValidationResult(
            isServerValidateError: true,
            serverValidateErrorTexts: serverObjectReturnedOnError,
            isEmailInvalidError: true,
          ),
        ),
      );
    },
  );

  test(
    'Check `handleVerificationResult` method when password is not valid',
    () {
      ref
          .read(provider.notifier)
          .handleServerValidation(createDioException(data: {
            'password': serverObjectReturnedOnError,
          }));

      expect(
        ref.read(provider),
        const SignUpState(
          validationResult: SignUpValidationResult(
            isServerValidateError: true,
            serverValidateErrorTexts: serverObjectReturnedOnError,
            isPasswordInvalidError: true,
          ),
        ),
      );
    },
  );

  test(
    'Check `handleVerificationResult` method when confirm password is not valid',
    () {
      ref
          .read(provider.notifier)
          .handleServerValidation(createDioException(data: {
            'passwordConfirm': serverObjectReturnedOnError,
          }));

      expect(
        ref.read(provider),
        const SignUpState(
          validationResult: SignUpValidationResult(
            isServerValidateError: true,
            serverValidateErrorTexts: serverObjectReturnedOnError,
            isPasswordMismatchError: true,
          ),
        ),
      );
    },
  );

  test(
    'Check `handleVerificationResult` method when all fields is not valid',
    () {
      ref
          .read(provider.notifier)
          .handleServerValidation(createDioException(data: {
            'name': serverObjectReturnedOnError,
            'email': serverObjectReturnedOnError,
            'password': serverObjectReturnedOnError,
            'passwordConfirm': serverObjectReturnedOnError,
          }));

      final serverValidateErrorTexts = <String>[
        serverObjectReturnedOnError.first,
        serverObjectReturnedOnError.first,
        serverObjectReturnedOnError.first,
        serverObjectReturnedOnError.first,
      ];

      expect(
        ref.read(provider),
        SignUpState(
          validationResult: SignUpValidationResult(
            isServerValidateError: true,
            serverValidateErrorTexts: serverValidateErrorTexts,
            isNameInvalidError: true,
            isEmailInvalidError: true,
            isPasswordInvalidError: true,
            isPasswordMismatchError: true,
          ),
        ),
      );
    },
  );
}
