import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/auth_sign_up_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_send_request.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_send_response.dart';
import 'package:prime_ballet/auth/sign_up_verification/models/otp_verify_request.dart';
import 'package:prime_ballet/common/models/token_response.dart';
import 'package:retrofit/http.dart';

part 'sign_up_verification_repository.g.dart';

@RestApi()
@injectable
abstract class SignUpVerificationRepository {
  @factoryMethod
  factory SignUpVerificationRepository(Dio dio) =>
      _SignUpVerificationRepository(dio);

  @POST('/api/mobile/otp/send/')
  Future<OtpSendResponse> send(@Body() OtpSendRequest otpSendRequest);

  @POST('/api/mobile/otp/verify/')
  Future<void> verify(@Body() OtpVerifyRequest otpVerifyRequest);

  @POST('/api/mobile/auth/sign_up/')
  Future<TokenResponse> signUp(@Body() AuthSignUpRequest authSignUpRequest);
}
