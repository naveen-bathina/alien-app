import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/app/app.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/auth/cubit/auth_cubit.dart';
import 'package:myalien/auth/cubit/auth_state.dart';
import 'package:myalien/auth/view/login_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('App', () {
    testWidgets('renders LoginScreen', (tester) async {
      final authCubit = MockAuthCubit();
      when(() => authCubit.state).thenReturn(AuthInitial());
      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: const App(),
        ),
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(BrandLogo), findsOneWidget);
    });
  });
}
