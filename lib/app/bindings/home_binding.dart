import 'package:get/get.dart';
import '../../data/repositories/match_repository.dart';
import '../../modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(matchRepository: Get.find<MatchRepository>()),
    );
  }
}
