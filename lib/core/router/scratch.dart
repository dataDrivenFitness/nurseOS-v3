import 'package:go_router/go_router.dart';

void main() {
  final stream = Stream<int>.empty();
  final refresh = GoRouterRefreshStream(stream);
  print(refresh);
}
