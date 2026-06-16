import '../core/api_log.dart';
import '../models/prompt_generate_request.dart';
import '../models/prompt_generate_response.dart';
import 'api_client.dart';

class PromptService {
  PromptService(this._apiClient);
  final ApiClient _apiClient;

  Future<PromptGenerateResponse> generatePrompt(PromptGenerateRequest request) async {
    final body = request.toJson();
    apiLog(
      'POST /prompts/generate business_type=${body['business_type']} '
      'notes_len=${(body['additional_notes'] as String?)?.length ?? 0}',
    );
    final response = await _apiClient.dio.post('/prompts/generate', data: body);
    apiLog('response keys=${(response.data as Map).keys.toList()}');
    return PromptGenerateResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
