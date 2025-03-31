import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/gradient_card.dart';

class WeatherSuggestionCard extends StatelessWidget {
  const WeatherSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟当前天气数据
    final weatherData = {
      'temperature': 28,
      'humidity': 65,
      'uvIndex': 7,
      'condition': 'sunny', // sunny, cloudy, rainy
    };

    return GradientCard(
      gradientColors: const [Color(0xFFF8BBD0), Color(0xFFFFECB3)],
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 天气条件部分
          Row(
            children: [
              // 天气图标
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: _getWeatherIcon(weatherData['condition'] as String),
              ),
              const SizedBox(width: 12),

              // 天气文字信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weatherData['temperature']}°C · ${_getConditionText(weatherData['condition'] as String)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '湿度 ${weatherData['humidity']}% · 紫外线 ${_getUVIndexText(weatherData['uvIndex'] as int)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // 护肤建议部分
          const Text(
            '今日护肤建议',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // 建议列表
          ...(_getSkincareSuggestions(
            weatherData,
          ).map((suggestion) => _buildSuggestionItem(suggestion))),
        ],
      ),
    );
  }

  // 获取天气图标
  Widget _getWeatherIcon(String condition) {
    IconData iconData;

    switch (condition) {
      case 'sunny':
        iconData = Icons.wb_sunny_rounded;
        break;
      case 'cloudy':
        iconData = Icons.cloud_rounded;
        break;
      case 'rainy':
        iconData = Icons.grain_rounded;
        break;
      default:
        iconData = Icons.wb_sunny_rounded;
    }

    return Icon(iconData, color: Colors.white, size: 28);
  }

  // 获取天气文字描述
  String _getConditionText(String condition) {
    switch (condition) {
      case 'sunny':
        return '晴天';
      case 'cloudy':
        return '多云';
      case 'rainy':
        return '雨天';
      default:
        return '晴天';
    }
  }

  // 获取紫外线指数文字描述
  String _getUVIndexText(int uvIndex) {
    if (uvIndex >= 8) {
      return '极强';
    } else if (uvIndex >= 6) {
      return '强';
    } else if (uvIndex >= 3) {
      return '中等';
    } else {
      return '弱';
    }
  }

  // 根据天气获取护肤建议
  List<Map<String, dynamic>> _getSkincareSuggestions(
    Map<String, dynamic> weatherData,
  ) {
    final suggestions = <Map<String, dynamic>>[];

    // 根据温度和湿度提供保湿建议
    if ((weatherData['temperature'] as int) > 25 &&
        (weatherData['humidity'] as int) < 50) {
      suggestions.add({
        'icon': Icons.water_drop_outlined,
        'text': '高温低湿环境下，建议使用含透明质酸的保湿喷雾，随时补水',
      });
    }

    // 根据紫外线指数提供防晒建议
    if ((weatherData['uvIndex'] as int) >= 3) {
      suggestions.add({
        'icon': Icons.wb_sunny_outlined,
        'text':
            '紫外线${_getUVIndexText(weatherData['uvIndex'] as int)}，建议使用SPF50+防晒，外出2小时后补涂',
      });
    }

    // 根据天气状况提供额外建议
    if (weatherData['condition'] as String == 'sunny' &&
        (weatherData['temperature'] as int) > 30) {
      suggestions.add({
        'icon': Icons.ac_unit_outlined,
        'text': '高温天气，可以使用冰箱冷藏过的面膜舒缓肌肤',
      });
    } else if (weatherData['condition'] as String == 'rainy') {
      suggestions.add({
        'icon': Icons.spa_outlined,
        'text': '雨天湿度大，选择清爽质地的护肤品，避免闷痘',
      });
    }

    return suggestions;
  }

  // 构建建议项目
  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(suggestion['icon'] as IconData, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion['text'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
