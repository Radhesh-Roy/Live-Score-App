import 'package:get/get.dart';
import '../../data/repositories/match_repository.dart';
import '../../modules/match_details/controllers/match_details_controller.dart';

class MatchDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchDetailsController>(
      () => MatchDetailsController(matchRepository: Get.find<MatchRepository>()),
    );
  }
}
