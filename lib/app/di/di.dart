import 'package:get_it/get_it.dart';
import 'package:shared/shared.dart';

final getIt = GetIt.instance;

void setUpDi({required AppFlavor appFlavor}) {
  GetIt.instance.registerSingleton(appFlavor);
}
