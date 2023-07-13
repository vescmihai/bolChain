import 'package:bolchain/ui_helper/home_ui_helper.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDi() {
  getIt.registerLazySingleton<HomePageUiHelper>(() => HomePageUiHelper());

}
