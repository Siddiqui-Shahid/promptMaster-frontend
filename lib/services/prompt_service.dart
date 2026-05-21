import '../models/prompt_detail.dart';
import '../models/prompt_generate_request.dart';
import '../models/prompt_generate_response.dart';
import '../models/prompt_summary.dart';
import 'api_client.dart';

class PromptService {
  PromptService(this._apiClient);
  final ApiClient _apiClient;

  Future<PromptGenerateResponse> generatePrompt(PromptGenerateRequest request) async {
    final response = await _apiClient.dio.post('/prompts/generate', data: request.toJson());
    return PromptGenerateResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PromptSummary>> fetchPromptHistory() async {
    final response = await _apiClient.dio.get('/prompts');
    final data = (response.data as List).cast<Map<String, dynamic>>();
    return data.map(PromptSummary.fromJson).toList();
  }

  Future<PromptDetail> fetchPromptById(int promptId) async {
    final response = await _apiClient.dio.get('/prompts/$promptId');
    return PromptDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
