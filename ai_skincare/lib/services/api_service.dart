import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skin_analysis_model.dart';
import '../models/product_model.dart';
import '../models/ingredient_model.dart';
import '../models/conflict_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.ai-skincare.com/v1';
  static const String contentType = 'application/json';

  // 缓存获取的token
  static String? _authToken;

  // 获取认证Token
  static Future<String?> getToken() async {
    if (_authToken != null) return _authToken;

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // 设置认证Token
  static Future<void> setToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 清除认证Token
  static Future<void> clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 创建带认证的请求头
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': contentType,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 处理API响应
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody['data'];
    } else {
      final errorMessage =
          responseBody['error']['message'] ?? 'Unknown error occurred';
      throw ApiException(
        statusCode: statusCode,
        message: errorMessage,
        code: responseBody['error']['code'] ?? 'UNKNOWN_ERROR',
      );
    }
  }

  // GET请求
  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  // POST请求 (JSON数据)
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  // POST请求 (表单数据和文件)
  static Future<dynamic> postMultipart(
    String endpoint, {
    required File file,
    String fileField = 'image',
    Map<String, String>? fields,
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final request = http.MultipartRequest('POST', uri);

      // 添加文件
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        fileField,
        fileStream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 添加其他字段
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // 添加头信息
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  // PUT请求
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  // DELETE请求
  static Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      _handleException(e);
    }
  }

  // 异常处理
  static void _handleException(dynamic e) {
    if (e is ApiException) {
      throw e;
    } else if (e is SocketException) {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection',
        code: 'NETWORK_ERROR',
      );
    } else {
      throw ApiException(
        statusCode: 500,
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  // 用户注册
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await post(
      '/auth/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );

    if (response['token'] != null) {
      await setToken(response['token']);
    }

    return response;
  }

  // 用户登录
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response['token'] != null) {
      await setToken(response['token']);
    }

    return response;
  }

  // 退出登录
  static Future<void> logout() async {
    await clearToken();
  }

  // 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    return await get('/users/me');
  }

  // 更新用户信息
  static Future<Map<String, dynamic>> updateUserInfo({
    String? username,
    String? avatarUrl,
    String? skinType,
    List<String>? concerns,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (skinType != null) body['skinType'] = skinType;
    if (concerns != null) body['concerns'] = concerns;

    return await put('/users/me', body: body);
  }

  // 上传图片进行肌肤分析
  static Future<SkinAnalysisModel> uploadSkinImage({
    required File image,
    Map<String, dynamic>? quizData,
  }) async {
    final Map<String, String> fields = {};
    if (quizData != null) {
      fields['quizData'] = json.encode(quizData);
    }

    final response = await postMultipart(
      '/skin-analysis/detect',
      file: image,
      fields: fields,
    );

    return SkinAnalysisModel.fromJson(response);
  }

  // 获取肌肤分析历史
  static Future<Map<String, dynamic>> getSkinAnalysisHistory({
    int page = 1,
    int limit = 10,
  }) async {
    return await get(
      '/skin-analysis/history',
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
  }

  // 获取肌肤分析详情
  static Future<SkinAnalysisModel> getSkinAnalysisDetail(
    String analysisId,
  ) async {
    final response = await get('/skin-analysis/$analysisId');
    return SkinAnalysisModel.fromJson(response);
  }

  // 上传图片进行产品分析
  static Future<Map<String, dynamic>> scanProduct(File image) async {
    return await postMultipart('/product-analysis/scan', file: image);
  }

  // 搜索产品
  static Future<Map<String, dynamic>> searchProducts({
    required String query,
    String? category,
    String? brand,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;

    return await get('/products/search', queryParams: queryParams);
  }

  // 获取产品详情
  static Future<ProductModel> getProductDetail(String productId) async {
    final response = await get('/products/$productId');
    return ProductModel.fromJson(response);
  }

  // 获取成分详情
  static Future<IngredientModel> getIngredientDetail(
    String ingredientId,
  ) async {
    final response = await get('/ingredients/$ingredientId');
    return IngredientModel.fromJson(response);
  }

  // 搜索成分
  static Future<Map<String, dynamic>> searchIngredients({
    required String query,
    String? category,
    String? function,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (function != null) queryParams['function'] = function;

    return await get('/ingredients/search', queryParams: queryParams);
  }

  // 检测成分冲突
  static Future<ConflictCheckResult> checkIngredientConflicts(
    List<String> ingredientIds,
  ) async {
    final response = await post(
      '/conflict-detection/check',
      body: {'ingredientIds': ingredientIds},
    );

    return ConflictCheckResult.fromJson(response);
  }

  // 检测产品冲突
  static Future<ProductConflictResult> checkProductConflicts(
    List<String> productIds,
  ) async {
    final response = await post(
      '/conflict-detection/products',
      body: {'productIds': productIds},
    );

    return ProductConflictResult.fromJson(response);
  }

  // 获取天气和护肤建议
  static Future<Map<String, dynamic>> getWeatherAdvice({
    double? latitude,
    double? longitude,
  }) async {
    final queryParams = <String, dynamic>{};

    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();

    return await get('/weather-advice', queryParams: queryParams);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String code;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'ApiException: [$statusCode] $code - $message';
}
