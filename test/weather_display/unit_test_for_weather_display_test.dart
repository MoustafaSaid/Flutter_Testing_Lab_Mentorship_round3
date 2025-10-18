import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';

void main() {
  group('Temperature Conversion Tests', () {
    late WeatherDisplayState weatherState;

    setUp(() {
      weatherState = WeatherDisplayState();
    });

    group('Celsius to Fahrenheit', () {
      test('Freezing point: 0°C = 32°F', () {
        expect(weatherState.celsiusToFahrenheit(0), 32.0);
      });

      test('Boiling point: 100°C = 212°F', () {
        expect(weatherState.celsiusToFahrenheit(100), 212.0);
      });

      test('Room temperature: 20°C = 68°F', () {
        expect(weatherState.celsiusToFahrenheit(20), 68.0);
      });

      test('Hot day: 30°C = 86°F', () {
        expect(weatherState.celsiusToFahrenheit(30), 86.0);
      });

      test('Cold day: -10°C = 14°F', () {
        expect(weatherState.celsiusToFahrenheit(-10), 14.0);
      });

      test('Negative temperature: -40°C = -40°F', () {
        expect(weatherState.celsiusToFahrenheit(-40), -40.0);
      });

      test('Fractional temperature: 22.5°C = 72.5°F', () {
        expect(weatherState.celsiusToFahrenheit(22.5), 72.5);
      });

      test('Body temperature: 37°C ≈ 98.6°F', () {
        expect(weatherState.celsiusToFahrenheit(37), closeTo(98.6, 0.1));
      });
    });

    group('Fahrenheit to Celsius', () {
      test('Freezing point: 32°F = 0°C', () {
        expect(weatherState.fahrenheitToCelsius(32), 0.0);
      });

      test('Boiling point: 212°F = 100°C', () {
        expect(weatherState.fahrenheitToCelsius(212), 100.0);
      });

      test('Room temperature: 68°F = 20°C', () {
        expect(weatherState.fahrenheitToCelsius(68), 20.0);
      });

      test('Hot day: 86°F = 30°C', () {
        expect(weatherState.fahrenheitToCelsius(86), 30.0);
      });

      test('Cold day: 14°F = -10°C', () {
        expect(weatherState.fahrenheitToCelsius(14), -10.0);
      });

      test('Negative temperature: -40°F = -40°C', () {
        expect(weatherState.fahrenheitToCelsius(-40), -40.0);
      });

      test('Body temperature: 98.6°F ≈ 37°C', () {
        expect(weatherState.fahrenheitToCelsius(98.6), closeTo(37, 0.1));
      });

      test('Fractional temperature: 50°F = 10°C', () {
        expect(weatherState.fahrenheitToCelsius(50), 10.0);
      });
    });

    group('Round-trip Conversions', () {
      test('C -> F -> C preserves value', () {
        const original = 25.0;
        final fahrenheit = weatherState.celsiusToFahrenheit(original);
        final backToCelsius = weatherState.fahrenheitToCelsius(fahrenheit);
        expect(backToCelsius, closeTo(original, 0.0001));
      });

      test('F -> C -> F preserves value', () {
        const original = 77.0;
        final celsius = weatherState.fahrenheitToCelsius(original);
        final backToFahrenheit = weatherState.celsiusToFahrenheit(celsius);
        expect(backToFahrenheit, closeTo(original, 0.0001));
      });

      test('Multiple conversions maintain precision', () {
        double temp = 20.0;
        for (int i = 0; i < 10; i++) {
          temp = weatherState.celsiusToFahrenheit(temp);
          temp = weatherState.fahrenheitToCelsius(temp);
        }
        expect(temp, closeTo(20.0, 0.001));
      });
    });
  });

  group('WeatherData fromJson Tests', () {
    group('Valid Data', () {
      test('Complete valid data parses correctly', () {
        final json = {
          'city': 'New York',
          'temperature': 22.5,
          'description': 'Sunny',
          'humidity': 65,
          'windSpeed': 12.3,
          'icon': '☀️',
        };

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, 'New York');
        expect(weather.temperatureCelsius, 22.5);
        expect(weather.description, 'Sunny');
        expect(weather.humidity, 65);
        expect(weather.windSpeed, 12.3);
        expect(weather.icon, '☀️');
      });

      test('Temperature as int converts to double', () {
        final json = {'city': 'London', 'temperature': 15};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, 15.0);
        expect(weather.temperatureCelsius, isA<double>());
      });

      test('WindSpeed as int converts to double', () {
        final json = {'city': 'Tokyo', 'temperature': 25.0, 'windSpeed': 5};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.windSpeed, 5.0);
        expect(weather.windSpeed, isA<double>());
      });
    });

    group('Incomplete Data', () {
      test('Missing optional fields use defaults', () {
        final json = {'city': 'Paris', 'temperature': 18.0};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, 'Paris');
        expect(weather.temperatureCelsius, 18.0);
        expect(weather.description, 'N/A');
        expect(weather.humidity, 0);
        expect(weather.windSpeed, 0.0);
        expect(weather.icon, '🌤️');
      });

      test('Missing city returns null', () {
        final json = {'temperature': 20.0, 'description': 'Sunny'};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNull);
      });

      test('Missing temperature returns null', () {
        final json = {'city': 'Berlin', 'description': 'Cloudy'};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNull);
      });
    });

    group('Null and Invalid Data', () {
      test('Null json returns null', () {
        final weather = WeatherData.fromJson(null);
        expect(weather, isNull);
      });

      test('Empty json returns null', () {
        final weather = WeatherData.fromJson({});
        expect(weather, isNull);
      });

      test('Invalid temperature type returns null', () {
        final json = {
          'city': 'Rome',
          'temperature': 'hot', // String instead of number
        };

        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('Invalid city type returns null', () {
        final json = {
          'city': 123, // Number instead of string
          'temperature': 20.0,
        };

        final weather = WeatherData.fromJson(json);
        expect(weather, isNull);
      });

      test('Negative temperature is valid', () {
        final json = {'city': 'Moscow', 'temperature': -15.5};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, -15.5);
      });

      test('Zero temperature is valid', () {
        final json = {'city': 'Iceland', 'temperature': 0.0};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, 0.0);
      });

      test('Very high temperature is valid', () {
        final json = {'city': 'Death Valley', 'temperature': 56.7};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, 56.7);
      });

      test('Very low temperature is valid', () {
        final json = {'city': 'Antarctica', 'temperature': -89.2};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.temperatureCelsius, -89.2);
      });
    });

    group('Edge Cases', () {
      test('Humidity over 100 is accepted', () {
        final json = {'city': 'City', 'temperature': 20.0, 'humidity': 150};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.humidity, 150);
      });

      test('Negative humidity is accepted', () {
        final json = {'city': 'City', 'temperature': 20.0, 'humidity': -10};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.humidity, -10);
      });

      test('Negative wind speed is accepted', () {
        final json = {'city': 'City', 'temperature': 20.0, 'windSpeed': -5.0};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.windSpeed, -5.0);
      });

      test('Empty string city is valid', () {
        final json = {'city': '', 'temperature': 20.0};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, '');
      });

      test('Empty string description uses default', () {
        final json = {'city': 'City', 'temperature': 20.0, 'description': ''};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.description, '');
      });

      test('Very long city name is valid', () {
        final longName = 'A' * 1000;
        final json = {'city': longName, 'temperature': 20.0};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, longName);
      });

      test('Special characters in city name', () {
        final json = {'city': 'São Paulo 東京 Москва', 'temperature': 20.0};

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.city, 'São Paulo 東京 Москва');
      });

      test('Emoji in description', () {
        final json = {
          'city': 'City',
          'temperature': 20.0,
          'description': 'Sunny ☀️ with clouds ☁️',
        };

        final weather = WeatherData.fromJson(json);

        expect(weather, isNotNull);
        expect(weather!.description, 'Sunny ☀️ with clouds ☁️');
      });
    });

    group('Multiple Parsings', () {
      test('Parsing same data multiple times produces same result', () {
        final json = {
          'city': 'Test',
          'temperature': 25.0,
          'description': 'Clear',
          'humidity': 50,
          'windSpeed': 10.0,
          'icon': '☀️',
        };

        final weather1 = WeatherData.fromJson(json);
        final weather2 = WeatherData.fromJson(json);

        expect(weather1, isNotNull);
        expect(weather2, isNotNull);
        expect(weather1!.city, weather2!.city);
        expect(weather1.temperatureCelsius, weather2.temperatureCelsius);
        expect(weather1.description, weather2.description);
      });

      test('Modifying json after parsing does not affect object', () {
        final json = {'city': 'Test', 'temperature': 25.0};

        final weather = WeatherData.fromJson(json);

        json['city'] = 'Modified';
        json['temperature'] = 50.0;

        expect(weather, isNotNull);
        expect(weather!.city, 'Test');
        expect(weather.temperatureCelsius, 25.0);
      });
    });
  });
}
