import '../models/prompt_generate_request.dart';
import '../models/prompt_generate_response.dart';
import 'api_client.dart';

class PromptService {
  PromptService(this._apiClient);
  final ApiClient _apiClient;

  Future<PromptGenerateResponse> generatePrompt(PromptGenerateRequest request) async {
    final response = await _apiClient.dio.post('/prompts/generate', data: request.toJson());
    return PromptGenerateResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
