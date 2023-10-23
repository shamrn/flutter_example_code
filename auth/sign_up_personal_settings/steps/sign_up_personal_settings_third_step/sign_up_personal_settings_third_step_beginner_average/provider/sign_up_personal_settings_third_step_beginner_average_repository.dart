import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/sign_up_personal_settings_third_step_beginner_average/models/sign_up_personal_settings_third_step_beginner_average_response.dart';
import 'package:retrofit/http.dart';

part 'sign_up_personal_settings_third_step_beginner_average_repository.g.dart';

@RestApi()
@lazySingleton
abstract class SignUpPersonalSettingsThirdStepBeginnerAverageRepository {
  @factoryMethod
  factory SignUpPersonalSettingsThirdStepBeginnerAverageRepository(Dio dio) =>
      _SignUpPersonalSettingsThirdStepBeginnerAverageRepository(dio);

  @GET('/api/mobile/exercises/categories/')
  Future<List<SignUpPersonalSettingsThirdStepBeginnerAverageResponse>>
      fetchExercise({@Query('is_pro') bool isPro = false});
}
