import 'package:get_it/get_it.dart';
import '../core/services/auth_service.dart';
import '../features/home/data/repositories/event_repository.dart';
import '../features/home/data/repositories/restaurant_repository.dart';
import '../features/home/data/repositories/notification_repository.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../features/profile/presentation/viewmodels/profile_viewmodel.dart';

final sl = GetIt.instance;

void configureDependencies() {
  // ── Services (Singleton) ────────────────────────────────────────────────
  sl.registerLazySingleton<AuthService>(() => AuthService.instance);

  // ── Repositories (Singleton) ────────────────────────────────────────────
  sl.registerLazySingleton<EventRepository>(() => EventRepository.instance);
  sl.registerLazySingleton<RestaurantRepository>(
      () => RestaurantRepository.instance);
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository.instance);
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepository.instance);

  // ── ViewModels ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeViewModel>(() => HomeViewModel(
        eventRepo: sl<EventRepository>(),
        restaurantRepo: sl<RestaurantRepository>(),
        notificationRepo: sl<NotificationRepository>(),
        profileRepo: sl<ProfileRepository>(),
        auth: sl<AuthService>(),
      ));
  sl.registerFactory<ProfileViewModel>(ProfileViewModel.new);
}
