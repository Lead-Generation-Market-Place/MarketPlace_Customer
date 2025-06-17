import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalPlansController extends GetxController {
  RxBool isNavigatedFromCreatePlan = false.obs;
  RxBool isLoading = false.obs;
  RxList startedPlans = [].obs;
  final storageInstance = GetStorage();

  @override
  void dispose() async {
    print('Dispose local plans');
    // TODO: implement dispose
    await saveCachePlan();
    super.dispose();
  }

  @override
  void onInit() {
    print('Initialized local plans');
    // TODO: implement onInit
    ever(startedPlans, (_) => saveCachePlan());
    getCachePlan();
    super.onInit();
  }

  Future<List> saveCachePlan() async {
    try {
      isLoading = true.obs;
      await storageInstance.write('startedPlans', jsonEncode(startedPlans));
      print('These plans has been saved: $startedPlans');
    } catch (e) {
      throw Exception('Exception on Local storage to save plans');
    } finally {
      isLoading = false.obs;
    }
    return startedPlans;
  }

  Future<List> getCachePlan() async {
    try {
      isLoading = true.obs;
      if (storageInstance.read('startedPlans') != null) {
        startedPlans = storageInstance.read(jsonDecode('startedPlans'));
        print('cached data retrived $startedPlans');
      }
    } catch (e) {
      throw Exception('Exception on Local storage to save plans');
    } finally {
      isLoading = false.obs;
    }
    return startedPlans;
  }
}
