import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_two_step/models/sign_up_personal_settings_two_step_request.dart';
import 'package:prime_ballet/common/models/profile_response.dart';
import 'package:retrofit/http.dart';

part 'sign_up_personal_settings_two_step_repository.g.dart';

@RestApi()
@injectable
abstract class SignUpPersonalSettingsTwoStepRepository {
  @factoryMethod
  factory SignUpPersonalSettingsTwoStepRepository(Dio dio) =>
      _SignUpPersonalSettingsTwoStepRepository(dio);

  @PATCH('/api/mobile/users/profile/update/')
  Future<ProfileResponse> update(
    @Body()
    SignUpPersonalSettingsTwoStepRequest signUpPersonalSettingsTwoStepRequest,
  );
}
