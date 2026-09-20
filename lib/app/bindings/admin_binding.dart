import 'package:get/get.dart';
import '../../data/repositories/match_repository.dart';
import '../../modules/admin/controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(
      () => AdminController(matchRepository: Get.find<MatchRepository>()),
    );
  }
}
