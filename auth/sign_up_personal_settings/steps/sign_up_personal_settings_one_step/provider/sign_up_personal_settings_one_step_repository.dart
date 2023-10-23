import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_one_step/models/sign_up_personal_settings_one_step_request.dart';
import 'package:retrofit/http.dart';

part 'sign_up_personal_settings_one_step_repository.g.dart';

@RestApi()
@injectable
abstract class SignUpPersonalSettingsOneStepRepository {
  @factoryMethod
  factory SignUpPersonalSettingsOneStepRepository(Dio dio) =>
      _SignUpPersonalSettingsOneStepRepository(dio);

  @PATCH('/api/mobile/users/profile/update/')
  Future<void> update(
    @Body()
    SignUpPersonalSettingsOneStepRequest signUpPersonalSettingsOneStepRequest,
  );
}
