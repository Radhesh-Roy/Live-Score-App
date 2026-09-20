import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';

class MatchDetailsController extends GetxController {
  final MatchRepository _matchRepository;

  MatchDetailsController({MatchRepository? matchRepository})
      : _matchRepository = matchRepository ?? Get.find<MatchRepository>();

  final Rx<MatchModel?> match = Rx<MatchModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<MatchModel?>? _streamSubscription;
  late String matchId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is MatchModel) {
      match.value = args;
      matchId = args.id;
    } else if (args is String) {
      matchId = args;
    } else {
      matchId = '';
    }

    if (matchId.isNotEmpty) {
      _listenToMatchDetails();
    }
  }

  void _listenToMatchDetails() {
    if (match.value == null) {
      isLoading.value = true;
    }

    _streamSubscription?.cancel();
    _streamSubscription = _matchRepository.getMatchStream(matchId).listen(
      (updatedMatch) {
        if (updatedMatch != null) {
          match.value = updatedMatch;
        }
        isLoading.value = false;
      },
      onError: (err) {
        errorMessage.value = err.toString();
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    super.onClose();
  }
}
