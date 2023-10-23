import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_pro/models/sign_up_personal_settings_third_step_pro_response.dart';
import 'package:retrofit/http.dart';

part 'sign_up_personal_settings_third_step_pro_repository.g.dart';

@RestApi()
@lazySingleton
abstract class SignUpPersonalSettingsThirdStepProRepository {
  @factoryMethod
  factory SignUpPersonalSettingsThirdStepProRepository(Dio dio) =>
      _SignUpPersonalSettingsThirdStepProRepository(dio);

  @GET('/api/mobile/exercises/categories/')
  Future<List<SignUpPersonalSettingsThirdStepProResponse>> fetchExercisePro({
    @Query('is_pro') bool isPro = true,
  });
}
