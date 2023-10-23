import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_personal_settings/steps/sign_up_personal_settings_third_step/common/models/sign_up_personal_settings_third_step_create_playlist_request.dart';
import 'package:retrofit/http.dart';

part 'sign_up_personal_settings_third_step_create_playlist_repository.g.dart';

@RestApi()
@lazySingleton
abstract class SignUpPersonalSettingsThirdStepCreatePlaylistRepository {
  @factoryMethod
  factory SignUpPersonalSettingsThirdStepCreatePlaylistRepository(Dio dio) =>
      _SignUpPersonalSettingsThirdStepCreatePlaylistRepository(dio);

  @POST('/api/mobile/playlists/create/')
  Future<void> createPlaylist(
    @Body()
    SignUpPersonalSettingsThirdStepCreatePlaylistRequest
        signUpPersonalSettingsThirdStepCreatePlaylistRequest,
  );
}
