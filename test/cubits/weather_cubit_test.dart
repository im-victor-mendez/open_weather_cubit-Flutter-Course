import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_weather_cubit/cubits/weather/weather_cubit.dart';
import 'package:open_weather_cubit/models/custom_error.dart';
import 'package:open_weather_cubit/models/weather.dart';
import 'package:open_weather_cubit/repositories/weather_repository.dart';

import '../fixtures/fixture.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late WeatherCubit cubit;
  late MockWeatherRepository mock;

  setUp(() {
    mock = MockWeatherRepository();
    cubit = WeatherCubit(weatherRepository: mock);
  });

  tearDown(() => cubit.close());

  group(
    "State",
    () {
      // Initial State
      test(
        """
Initial State should be:
  - status: [WeatherStatus.initial]
  - weather: [Weather.initial()]
  - error: [CustomError()]
""",
        () {
          expect(cubit.state, WeatherState.initial());
        },
      );

      // Copy With
      test(
        "On copyWith method, state should maintain properties that are not specified in method",
        () {
          expect(
            cubit.state.copyWith(status: WeatherStatus.loaded),
            WeatherState.initial().copyWith(status: WeatherStatus.loaded),
          );
        },
      );
    },
  );

  group(
    "Cubit",
    () {
      // Set any [Map<String, dynamic>] value in weather state
      blocTest<WeatherCubit, WeatherState>(
        "On fetchWeather, should return a [Map<String,dynamic>] value",
        build: () {
          when(() => mock.fetchWeather('any city')).thenAnswer(
            (invocation) async => Weather.initial().copyWith(name: 'any city'),
          );

          return cubit;
        },
        act: (bloc) => bloc.fetchWeather('any city'),
        expect: () => <WeatherState>[
          WeatherState.initial().copyWith(status: WeatherStatus.loading),
          WeatherState.initial().copyWith(
            status: WeatherStatus.loaded,
            weather: Weather.initial().copyWith(name: 'any city'),
          ),
        ],
      );

      // Set Zocca weather value in weather state
      final zoccaWeather = Weather.fromJson(
          jsonDecode(fixture('zocca_weather.json')) as Map<String, dynamic>);

      blocTest<WeatherCubit, WeatherState>(
        """
On fetchWeather with ['Zocca'] parameter, should return Zocca city data, passing through:
  - First status: [WeatherStatus.loading]
    - weather: [Weather.initial()]
  - Final status: [WeatherStatus.loaded]
    - weather: [zoccaWeather]
""",
        build: () {
          when(() => mock.fetchWeather('Zocca'))
              .thenAnswer((invocation) async => zoccaWeather);

          return cubit;
        },
        act: (cubit) => cubit.fetchWeather('Zocca'),
        expect: () => <WeatherState>[
          WeatherState.initial().copyWith(status: WeatherStatus.loading),
          WeatherState.initial().copyWith(
            status: WeatherStatus.loaded,
            weather: zoccaWeather,
          ),
        ],
      );

      // Set error status when location are not found
      blocTest<WeatherCubit, WeatherState>(
        '''
With `..` as cityName on fetchWeather, final state should be:
  - status: [WeatherStatus.error]
  - error: [CustomError(errMsg: 'City is empty')]
''',
        build: () {
          when(() => mock.fetchWeather('..')).thenThrow(CustomError(
            errMsg: 'Weather Exception: Cannot get the location of ..',
          ));

          return cubit;
        },
        act: (cubit) => cubit.fetchWeather('..'),
        expect: () => <WeatherState>[
          WeatherState.initial().copyWith(status: WeatherStatus.loading),
          WeatherState(
            status: WeatherStatus.error,
            weather: Weather.initial(),
            error: CustomError(
              errMsg: 'Weather Exception: Cannot get the location of ..',
            ),
          ),
        ],
      );
    },
  );
}
