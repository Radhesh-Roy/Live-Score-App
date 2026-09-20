import 'package:get/get.dart';
import '../bindings/admin_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/match_details_binding.dart';
import '../../modules/admin/views/admin_view.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/match_details/views/match_details_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.matchDetails,
      page: () => const MatchDetailsView(),
      binding: MatchDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminView(),
      binding: AdminBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
