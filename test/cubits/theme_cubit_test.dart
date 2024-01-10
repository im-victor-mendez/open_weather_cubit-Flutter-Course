import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_weather_cubit/cubits/theme/theme_cubit.dart';
import 'package:open_weather_cubit/cubits/weather/weather_cubit.dart';
import 'package:open_weather_cubit/models/weather.dart';

import 'weather_cubit_test.dart';

void main() {
  late ThemeCubit cubit;

  late WeatherCubit weatherCubit;
  late MockWeatherRepository weatherMock;

  setUp(() {
    weatherMock = MockWeatherRepository();
    weatherCubit = WeatherCubit(weatherRepository: weatherMock);

    cubit = ThemeCubit(weatherCubit: weatherCubit);
  });

  tearDown(() {
    cubit.close();

    weatherCubit.close();
  });

  group(
    "State",
    () {
      // Initial State
      test(
        """
Initial State should be:
  - appTheme = [AppTheme.light]
""",
        () {
          expect(cubit.state, ThemeState.initial());
        },
      );

      // Copy With
      test(
        "On copyWith method, state should maintain properties that are not specified in method",
        () {
          expect(
            cubit.state.copyWith(appTheme: AppTheme.dark),
            ThemeState(appTheme: AppTheme.dark),
          );
        },
      );
    },
  );

  group(
    "Cubit",
    () {
      // Set [AppTheme.dark] when [WeatherState.temp] is [19]
      blocTest<ThemeCubit, ThemeState>(
        'Final state should be [AppTheme.dark] when [WeatherState.temp] is [19]',
        build: () => cubit,
        act: (bloc) => weatherCubit.emit(weatherCubit.state
            .copyWith(weather: Weather.initial().copyWith(temp: 19))),
        expect: () => <ThemeState>[
          ThemeState(appTheme: AppTheme.dark),
        ],
      );

      // Set [AppTheme.dark] when [WeatherState.temp] is [20]
      blocTest<ThemeCubit, ThemeState>(
        'Final state should be [AppTheme.dark] when [WeatherState.temp] is [20]',
        build: () => cubit,
        act: (bloc) => weatherCubit.emit(weatherCubit.state
            .copyWith(weather: Weather.initial().copyWith(temp: 20))),
        expect: () => <ThemeState>[
          ThemeState(appTheme: AppTheme.dark),
        ],
      );

      // Set [AppTheme.light] when [WeatherState.temp] is [21]
      blocTest<ThemeCubit, ThemeState>(
        'emits [MyState] when MyEvent is added.',
        build: () => cubit,
        act: (bloc) => weatherCubit.emit(weatherCubit.state
            .copyWith(weather: Weather.initial().copyWith(temp: 21))),
        expect: () => <ThemeState>[
          ThemeState(appTheme: AppTheme.light),
        ],
      );
    },
  );
}
