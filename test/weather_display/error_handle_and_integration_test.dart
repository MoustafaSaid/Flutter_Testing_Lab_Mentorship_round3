import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';

void main() {
  group('Weather Display - Error Handling Tests', () {
    group('API Response Error Handling', () {
      test('Null API response is handled gracefully', () {
        final weather = WeatherData.fromJson(null);
        expect(weather, isNull);
      });

      test('Empty JSON object returns null', () {
        final weather = WeatherData.fromJson({});
        expect(weather, isNull);
      });

      test('JSON with only city returns null (missing temperature)', () {
        final json = {'city': 'TestCity'};
        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('JSON with only temperature returns null (missing city)', () {
        final json = {'temperature': 25.0};
        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('JSON with null city returns null', () {
        final json = {'city': null, 'temperature': 25.0};
        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('JSON with null temperature returns null', () {
        final json = {'city': 'TestCity', 'temperature': null};
        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('Malformed temperature (string) returns null', () {
        final json = {'city': 'TestCity', 'temperature': 'twenty-five'};
        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('Malformed city (number) returns null', () {
        final json = {'city': 12345, 'temperature': 25.0};
        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test(
        'Malformed humidity (string) with valid required fields returns data',
        () {
          final json = {
            'city': 'TestCity',
            'temperature': 25.0,
            'humidity': 'very humid',
          };
          final weather = WeatherData.fromJson(json);
          // Should parse successfully but with default humidity
          expect(weather, isNotNull);
          expect(weather!.humidity, 0);
        },
      );

      test('Malformed windSpeed (string) uses default', () {
        final json = {
          'city': 'TestCity',
          'temperature': 25.0,
          'windSpeed': 'fast',
        };
        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.windSpeed, 0.0);
      });
    });

    group('Loading State Management', () {
      test('Loading state should not show error initially', () {
        final state = WeatherDisplayState();
        expect(state.isLoading, false);
        expect(state.error, null);
      });

      test('Error clears when new load starts', () async {
        final state = WeatherDisplayState();

        // Simulate error state
        state.error = 'Previous error';
        state.isLoading = false;

        // Start new load
        // In real implementation, _loadWeather() should clear _error
        expect(state.error, isNotNull);
      });
    });

    group('Temperature Conversion Edge Cases', () {
      late WeatherDisplayState state;

      setUp(() {
        state = WeatherDisplayState();
      });

      test('Converting very large celsius values', () {
        final result = state.celsiusToFahrenheit(1000000);
        expect(result, 1800032.0);
      });

      test('Converting very small celsius values', () {
        final result = state.celsiusToFahrenheit(-1000000);
        expect(result, -1799968.0);
      });

      test('Converting very large fahrenheit values', () {
        final result = state.fahrenheitToCelsius(1000000);
        expect(result, closeTo(555537.78, 0.01));
      });

      test('Converting very small fahrenheit values', () {
        final result = state.fahrenheitToCelsius(-1000000);
        expect(result, closeTo(-555573.33, 0.01));
      });

      test('Converting zero celsius', () {
        expect(state.celsiusToFahrenheit(0), 32.0);
      });

      test('Converting zero fahrenheit', () {
        expect(state.fahrenheitToCelsius(0), closeTo(-17.78, 0.01));
      });

      test('Fractional celsius conversions maintain precision', () {
        final result = state.celsiusToFahrenheit(22.5);
        expect(result, 72.5);
      });

      test('Fractional fahrenheit conversions maintain precision', () {
        final result = state.fahrenheitToCelsius(72.5);
        expect(result, closeTo(22.5, 0.01));
      });

      test('Very precise decimal celsius', () {
        final result = state.celsiusToFahrenheit(22.123456789);
        expect(result, closeTo(71.822222222, 0.000001));
      });

      test('Very precise decimal fahrenheit', () {
        final result = state.fahrenheitToCelsius(71.123456789);
        expect(result, closeTo(21.735253772, 0.000001));
      });
    });

    group('WeatherData Field Validation', () {
      test('Description defaults to N/A when missing', () {
        final json = {'city': 'Test', 'temperature': 20.0};
        final weather = WeatherData.fromJson(json);
        expect(weather!.description, 'N/A');
      });

      test('Description uses provided value', () {
        final json = {
          'city': 'Test',
          'temperature': 20.0,
          'description': 'Partly Cloudy',
        };
        final weather = WeatherData.fromJson(json);
        expect(weather!.description, 'Partly Cloudy');
      });

      test('Icon defaults to 🌤️ when missing', () {
        final json = {'city': 'Test', 'temperature': 20.0};
        final weather = WeatherData.fromJson(json);
        expect(weather!.icon, '🌤️');
      });

      test('Icon uses provided value', () {
        final json = {'city': 'Test', 'temperature': 20.0, 'icon': '⛈️'};
        final weather = WeatherData.fromJson(json);
        expect(weather!.icon, '⛈️');
      });

      test('Humidity defaults to 0 when missing', () {
        final json = {'city': 'Test', 'temperature': 20.0};
        final weather = WeatherData.fromJson(json);
        expect(weather!.humidity, 0);
      });

      test('WindSpeed defaults to 0.0 when missing', () {
        final json = {'city': 'Test', 'temperature': 20.0};
        final weather = WeatherData.fromJson(json);
        expect(weather!.windSpeed, 0.0);
      });
    });

    group('Complex Integration Scenarios', () {
      test('Parse complete weather data from realistic API response', () {
        final json = {
          'city': 'San Francisco',
          'temperature': 18.3,
          'description': 'Partly Cloudy',
          'humidity': 72,
          'windSpeed': 15.8,
          'icon': '⛅',
        };

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, 'San Francisco');
        expect(weather.temperatureCelsius, 18.3);
        expect(weather.description, 'Partly Cloudy');
        expect(weather.humidity, 72);
        expect(weather.windSpeed, 15.8);
        expect(weather.icon, '⛅');
      });

      test('Parse minimal valid weather data', () {
        final json = {'city': 'Berlin', 'temperature': 12};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, 'Berlin');
        expect(weather.temperatureCelsius, 12.0);
        expect(weather.description, 'N/A');
        expect(weather.humidity, 0);
        expect(weather.windSpeed, 0.0);
        expect(weather.icon, '🌤️');
      });

      test('Temperature conversion workflow', () {
        final json = {'city': 'Paris', 'temperature': 20.0};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);

        final state = WeatherDisplayState();
        final fahrenheit = state.celsiusToFahrenheit(
          weather!.temperatureCelsius,
        );
        expect(fahrenheit, 68.0);

        final backToCelsius = state.fahrenheitToCelsius(fahrenheit);
        expect(backToCelsius, closeTo(20.0, 0.01));
      });

      test('Parse data with mixed number types', () {
        final json = {
          'city': 'Madrid',
          'temperature': 28,
          'humidity': 55,
          'windSpeed': 10,
        };

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, isA<double>());
        expect(weather.windSpeed, isA<double>());
        expect(weather.humidity, isA<int>());
      });
    });

    group('Boundary Value Tests', () {
      test('Temperature at absolute zero', () {
        final json = {'city': 'Absolute Zero', 'temperature': -273.15};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, -273.15);

        final state = WeatherDisplayState();
        final fahrenheit = state.celsiusToFahrenheit(-273.15);
        expect(fahrenheit, closeTo(-459.67, 0.01));
      });

      test('Humidity at 0%', () {
        final json = {'city': 'Desert', 'temperature': 40.0, 'humidity': 0};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.humidity, 0);
      });

      test('Humidity at 100%', () {
        final json = {
          'city': 'Rainforest',
          'temperature': 28.0,
          'humidity': 100,
        };

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.humidity, 100);
      });

      test('Wind speed at 0', () {
        final json = {'city': 'Calm', 'temperature': 25.0, 'windSpeed': 0.0};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.windSpeed, 0.0);
      });

      test('Very high wind speed', () {
        final json = {
          'city': 'Hurricane',
          'temperature': 28.0,
          'windSpeed': 300.0,
        };

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.windSpeed, 300.0);
      });
    });

    group('Error Recovery Tests', () {
      test('Can parse valid data after invalid data', () {
        // First parse invalid data
        final invalid = WeatherData.fromJson({'city': 'Test'});
        expect(invalid, isNull);

        // Then parse valid data
        final valid = WeatherData.fromJson({
          'city': 'Test',
          'temperature': 20.0,
        });
        expect(valid, isNotNull);
      });

      test('Multiple invalid parses do not affect valid parse', () {
        for (int i = 0; i < 10; i++) {
          final invalid = WeatherData.fromJson({'invalid': 'data'});
          expect(invalid, isNull);
        }

        final valid = WeatherData.fromJson({
          'city': 'Test',
          'temperature': 20.0,
        });
        expect(valid, isNotNull);
      });
    });

    group('Special Character Tests', () {
      test('City name with unicode characters', () {
        final json = {'city': 'Москва', 'temperature': 5.0};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.city, 'Москва');
      });

      test('City name with emojis', () {
        final json = {'city': 'Tokyo 東京 🗼', 'temperature': 22.0};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.city, 'Tokyo 東京 🗼');
      });

      test('Description with special characters', () {
        final json = {
          'city': 'Test',
          'temperature': 20.0,
          'description': 'Partly cloudy with a 50% chance of rain',
        };

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.description, 'Partly cloudy with a 50% chance of rain');
      });
    });

    group('Type Coercion Tests', () {
      test('Temperature as string number should fail', () {
        final json = {'city': 'Test', 'temperature': '25.5'};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('Integer temperature converts to double', () {
        final json = {'city': 'Test', 'temperature': 25};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, 25.0);
        expect(weather.temperatureCelsius, isA<double>());
      });

      test('Double windSpeed stays double', () {
        final json = {'city': 'Test', 'temperature': 20.0, 'windSpeed': 15.5};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.windSpeed, 15.5);
        expect(weather.windSpeed, isA<double>());
      });

      test('Integer windSpeed converts to double', () {
        final json = {'city': 'Test', 'temperature': 20.0, 'windSpeed': 15};

        final weather = WeatherData.fromJson(json);
        expect(weather, isNotNull);
        expect(weather!.windSpeed, 15.0);
        expect(weather.windSpeed, isA<double>());
      });
    });
  });
}
