import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/app.dart';
import 'package:myalien/auth/cubit/auth_cubit.dart';
import 'package:myalien/bootstrap.dart';
import 'package:myalien/discover/cubit/discover_cubit.dart';
import 'package:myalien/discover/repository/discover_repository.dart';
import 'package:myalien/firebase_options.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';
import 'package:myalien/profile/cubit/profile_cubit.dart';
import 'package:myalien/profile/repository/profile_repository.dart';

Future<void> bootstrapMyAlienApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await bootstrap(
    () => MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeProfileRepository>(
          create: (context) => HomeProfileRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(),
        ),
        RepositoryProvider<DiscoverRepository>(
          create: (context) => DiscoverRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit()),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              repo: context.read<ProfileRepository>(),
            ),
          ),
          BlocProvider<DiscoverCubit>(
            create: (context) => DiscoverCubit(
              repo: context.read<DiscoverRepository>(),
            ),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}
