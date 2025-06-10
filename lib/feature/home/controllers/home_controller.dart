import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:us_connector/core/components/question_component.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;


  var isLoading = false.obs;
  RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  @override
  void onInit() async{
    super.onInit();
  await  fetchServices();
  }

  Future<void> fetchServices() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final response = await supabase
          .from('services')
          .select('id, name, description, service_image_url, categories!inner(*)')
          .order('id');

      if (response != null) {
        services.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching services: $e');
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }


Future<void> fetchQuestions(int serviceId) async {
  if (isLoading.value) return;
  
  isLoading.value = true;
  try {
    final response = await supabase
        .from('questions')
        .select('''
          *,
          question_answers!inner(
            answers!inner(*)
          )
        ''')
        .eq('service_id', serviceId)
        .order('id');

    if (response != null) {
      questions.value = List<Map<String, dynamic>>.from(response);
      final parsedQuestions = parseQuestions(questions);
      Get.to(() => QuestionFlowScreen(questions: parsedQuestions));
     
    }
  } catch (e) {
    print('Error fetching questions: $e');
    Get.snackbar(
      'Error',
      'Failed to load questions. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}

  @override
  void onClose() {
    services.clear();
    super.onClose();
  }
}

List<Question> parseQuestions(List<Map<String, dynamic>> rawQuestions) {
  return rawQuestions.map((q) {
    final String typeStr = (q['type'] ?? '').toString().toLowerCase();
    final QuestionType type =
        typeStr == 'checkbox' ? QuestionType.multipleChoice : QuestionType.singleChoice;

    final options = (q['question_answers'] as List)
        .map((qa) {
          final ans = qa['answers'];
          return QuestionOption(
            id: ans['id'].toString(),
            label: ans['text'] ?? '',
            value: ans['id'],
          );
        })
        .toList();

    return Question(
      id: q['id'].toString(),
      question: q['text'] ?? '',
      type: type,
      options: options,
      isRequired: true,
    );
  }).toList();
}
