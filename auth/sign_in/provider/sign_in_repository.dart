import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_in/models/sign_in_request.dart';
import 'package:prime_ballet/common/models/token_response.dart';
import 'package:retrofit/http.dart';

part 'sign_in_repository.g.dart';

@RestApi()
@lazySingleton
abstract class SignInRepository {
  @factoryMethod
  factory SignInRepository(Dio dio) => _SignInRepository(dio);

  @POST('/api/mobile/auth/token/')
  Future<TokenResponse> signIn(@Body() SignInRequest signInRequest);
}
