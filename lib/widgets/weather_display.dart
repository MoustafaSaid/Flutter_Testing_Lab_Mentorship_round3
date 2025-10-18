import 'package:flutter/material.dart';

class WeatherDisplay extends StatefulWidget {
  const WeatherDisplay({super.key});

  @override
  State<WeatherDisplay> createState() => WeatherDisplayState();
}

class WeatherDisplayState extends State<WeatherDisplay> {
  WeatherData? weatherData;
  bool isLoading = false;
  String? error;
  bool useFahrenheit = false;
  String selectedCity = 'New York';

  final List<String> cities = ['New York', 'London', 'Tokyo', 'Invalid City'];

  // Fixed: Added +32 to the formula
  double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // Fixed: Corrected operator precedence
  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  // Simulate API call that sometimes returns null or malformed data
  Future<Map<String, dynamic>?> fetchWeatherData(String city) async {
    await Future.delayed(const Duration(seconds: 2));

    if (city == 'Invalid City') {
      return null;
    }

    // Simulate incomplete data
    if (DateTime.now().millisecond % 4 == 0) {
      return {'city': city, 'temperature': 22.5};
    }

    return {
      'city': city,
      'temperature': city == 'London' ? 15.0 : (city == 'Tokyo' ? 25.0 : 22.5),
      'description': city == 'London'
          ? 'Rainy'
          : (city == 'Tokyo' ? 'Cloudy' : 'Sunny'),
      'humidity': city == 'London' ? 85 : (city == 'Tokyo' ? 70 : 65),
      'windSpeed': city == 'London' ? 8.5 : (city == 'Tokyo' ? 5.2 : 12.3),
      'icon': city == 'London' ? '🌧️' : (city == 'Tokyo' ? '☁️' : '☀️'),
    };
  }

  Future<void> loadWeather() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
      weatherData = null;
    });

    try {
      final data = await fetchWeatherData(selectedCity);

      if (!mounted) return;

      if (data == null) {
        setState(() {
          error = 'Failed to load weather data for $selectedCity';
          isLoading = false;
        });
        return;
      }

      // Try to parse the data
      weatherData = WeatherData.fromJson(data);

      if (weatherData == null) {
        setState(() {
          error = 'Invalid weather data received';
          isLoading = false;
        });
        return;
      }

      setState(() {
        weatherData = weatherData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Error loading weather: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // City selection
          Row(
            children: [
              const Text('City: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  items: cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCity = value;
                      });
                      loadWeather();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : loadWeather,
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Temperature unit toggle
          Row(
            children: [
              const Text('Temperature Unit:'),
              const SizedBox(width: 10),
              Switch(
                value: useFahrenheit,
                onChanged: (value) {
                  setState(() {
                    useFahrenheit = value;
                  });
                },
              ),
              Text(useFahrenheit ? 'Fahrenheit' : 'Celsius'),
            ],
          ),
          const SizedBox(height: 16),

          // Loading state
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          // Error state
          else if (error != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: loadWeather,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          // Success state
          else if (weatherData != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          weatherData!.icon,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weatherData!.city,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                weatherData!.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        useFahrenheit
                            ? '${celsiusToFahrenheit(weatherData!.temperatureCelsius).toStringAsFixed(1)}°F'
                            : '${weatherData!.temperatureCelsius.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildWeatherDetail(
                          'Humidity',
                          '${weatherData!.humidity}%',
                          Icons.water_drop,
                        ),
                        buildWeatherDetail(
                          'Wind Speed',
                          '${weatherData!.windSpeed} km/h',
                          Icons.air,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          // Empty state (shouldn't normally happen)
          else
            const Center(child: Text('No weather data available')),
        ],
      ),
    );
  }

  Widget buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class WeatherData {
  final String city;
  final double temperatureCelsius;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherData({
    required this.city,
    required this.temperatureCelsius,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  // Fixed: Proper null safety and error handling
  static WeatherData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    try {
      // Check required fields
      if (!json.containsKey('city') || !json.containsKey('temperature')) {
        return null;
      }

      // Helper function to safely parse int
      int parseIntOrDefault(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is num) return value.toInt();
        return defaultValue; // For strings or other invalid types
      }

      // Helper function to safely parse double
      double parseDoubleOrDefault(dynamic value, double defaultValue) {
        if (value == null) return defaultValue;
        if (value is double) return value;
        if (value is num) return value.toDouble();
        return defaultValue; // For strings or other invalid types
      }

      return WeatherData(
        city: json['city'] as String,
        temperatureCelsius: (json['temperature'] as num).toDouble(),
        description: json['description'] as String? ?? 'N/A',
        humidity: parseIntOrDefault(json['humidity'], 0),
        windSpeed: parseDoubleOrDefault(json['windSpeed'], 0.0),
        icon: json['icon'] as String? ?? '🌤️',
      );
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }
}
