import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_weather_cubit/cubits/temp_settings/temp_settings_cubit.dart';

class MockTempSettingsCubit extends MockCubit<TempSettingsState>
    implements TempSettingsCubit {}

void main() {
  late TempSettingsCubit cubit;

  setUp(() => cubit = TempSettingsCubit());
  tearDown(() => cubit.close());

  group(
    "State",
    () {
      // Initial State
      test(
        """
Initial state should be:
  - tempUnit = [TempUnit.celsius]
""",
        () {
          expect(cubit.state, TempSettingsState.initial());
        },
      );

      // Copy With
      test(
        "On copyWith method, state should change",
        () {
          expect(
            cubit.state.copyWith(tempUnit: TempUnit.fahrenheit),
            TempSettingsState(tempUnit: TempUnit.fahrenheit),
          );
        },
      );
    },
  );

  group(
    "Cubit",
    () {
      // Celsius to Fahrenheit
      blocTest<TempSettingsCubit, TempSettingsState>(
        'When [TempUnit] is [celsius], toggle to [fahrenheit]',
        build: () => cubit,
        act: (cubit) => cubit.toggleTempUnit(),
        expect: () => <TempSettingsState>[
          TempSettingsState.initial().copyWith(tempUnit: TempUnit.fahrenheit),
        ],
      );

      // Fahrenheit to Celsius
      blocTest<TempSettingsCubit, TempSettingsState>(
        'When [TempUnit] is [fahrenheit], toggle to [celsius]',
        build: () => cubit,
        seed: () => TempSettingsState(tempUnit: TempUnit.fahrenheit),
        act: (cubit) => cubit.toggleTempUnit(),
        expect: () => <TempSettingsState>[
          TempSettingsState.initial().copyWith(tempUnit: TempUnit.celsius),
        ],
      );
    },
  );
}
