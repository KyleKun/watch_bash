import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/cubit.dart';
import 'widgets/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<GameCubit>(create: (context) => GameCubit()),
          BlocProvider<PlayerCubit>(create: (context) => PlayerCubit()),
          BlocProvider<BallCubit>(create: (context) => BallCubit()),
          BlocProvider<ScoreCubit>(create: (context) => ScoreCubit()),
          BlocProvider<StatsCubit>(create: (context) => StatsCubit()),
        ],
        child: const Scaffold(
          body: GameBody(),
        ),
      ),
    );
  }
}
