import 'package:get/get.dart';
import '../../data/api/dio_client.dart';
import '../../data/api/football_api_service.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/services/firestore_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Network & API
    Get.put<DioClient>(DioClient(), permanent: true);
    Get.put<FootballApiService>(
      FootballApiService(dioClient: Get.find<DioClient>()),
      permanent: true,
    );

    // Firestore Database Service
    Get.put<FirestoreService>(FirestoreService(), permanent: true);

    // Unified Match Repository
    Get.put<MatchRepository>(
      MatchRepository(
        firestoreService: Get.find<FirestoreService>(),
        footballApiService: Get.find<FootballApiService>(),
      ),
      permanent: true,
    );
  }
}
