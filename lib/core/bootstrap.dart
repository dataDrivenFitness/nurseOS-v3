import 'package:go_router/go_router.dart';
import 'router/app_router.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: appRoutes,
  );
}
