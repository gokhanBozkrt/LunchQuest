import 'package:get_it/get_it.dart';
import '../features/home/presentation/viewmodels/home_viewmodel.dart';

final sl = GetIt.instance;

void configureDependencies() {
  sl.registerLazySingleton<HomeViewModel>(HomeViewModel.new);
}
