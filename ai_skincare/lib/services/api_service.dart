import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../services/storage_service.dart';
import '../models/skin_analysis_model.dart';
import '../models/product_model.dart';
import '../models/ingredient_model.dart';
import '../models/conflict_model.dart';

class ApiService {
  // 修改为后端真实的URL，确保和后端匹配
  static const String baseUrl = 'http://localhost:5000/api';
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
      // 检查响应格式是否包含success和data字段
      if (responseBody is Map &&
          responseBody.containsKey('success') &&
          responseBody['success'] == true) {
        return responseBody['data'];
      }
      return responseBody; // 兼容旧格式的API响应
    } else {
      // 错误处理按照后端API文档规范
      String message = '未知错误';
      String code = 'UNKNOWN_ERROR';

      if (responseBody is Map && responseBody.containsKey('error')) {
        if (responseBody['error'] is Map) {
          message = responseBody['error']['message'] ?? '未知错误';
          code = responseBody['error']['code'] ?? 'UNKNOWN_ERROR';
        } else {
          message = responseBody['error'].toString();
        }
      } else if (responseBody is Map && responseBody.containsKey('message')) {
        message = responseBody['message'];
      }

      throw ApiException(
        statusCode: statusCode,
        message: message,
        code: code,
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
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      _handleException(e);
    }
  }

  // Web平台专用的表单和图片提交
  static Future<dynamic> postMultipartWeb(
    String endpoint, {
    required Uint8List fileBytes,
    required String fileName,
    String fileField = 'image',
    Map<String, String>? fields,
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final request = http.MultipartRequest('POST', uri);

      // 添加文件
      final multipartFile = http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName,
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
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
        message: '网络连接失败',
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

  // 用户登录
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      // 保存登录信息
      if (response != null &&
          response['user'] != null &&
          response['token'] != null) {
        await setToken(response['token']);
        // 保存用户信息
        await StorageService.saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      rethrow; // 重新抛出异常以便上层处理
    }
  }

  // 用户注册
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final response = await post(
        '/auth/register',
        body: {
          'username': username,
          'email': email,
          'password': password,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
        },
      );

      // 保存登录信息
      if (response != null &&
          response['user'] != null &&
          response['token'] != null) {
        await setToken(response['token']);
        // 保存用户信息
        await StorageService.saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      rethrow; // 重新抛出异常以便上层处理
    }
  }

  // 获取当前用户信息
  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/auth/me');
  }

  // 退出登录
  static Future<void> logout() async {
    await clearToken();
    await StorageService.clearAll();
  }

  // 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    return await get('/auth/profile');
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
    if (skinType != null) body['skin_type'] = skinType;
    if (concerns != null) body['skin_concerns'] = concerns;

    return await put('/auth/profile', body: body);
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

  // 获取肌肤分析历史（分页）
  static Future<Map<String, dynamic>> getSkinAnalysisHistoryPaged({
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
    return await postMultipart('/products/scan', file: image);
  }

  // 上传图片进行产品分析(Web版本)
  static Future<Map<String, dynamic>> scanProductWeb(
      Uint8List imageBytes) async {
    return await postMultipartWeb(
      '/products/scan',
      fileBytes: imageBytes,
      fileName: 'product_image.jpg',
    );
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
  static Future<IngredientConflictResult> checkIngredientConflicts(
    List<String> ingredientIds,
  ) async {
    final response = await post(
      '/conflict/ingredient',
      body: {'ingredients': ingredientIds},
    );

    return IngredientConflictResult.fromJson(response);
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

  // 获取用户的产品列表
  static Future<List<ProductModel>> getUserProducts({
    int page = 1,
    int limit = 50,
    String? category,
    String? sortBy,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    try {
      final response = await get('/user/products', queryParams: queryParams);

      final products = <ProductModel>[];

      // 处理新的响应结构
      if (response != null) {
        if (response is Map && response.containsKey('products')) {
          // 旧结构：直接包含products数组
          for (var item in response['products']) {
            products.add(ProductModel.fromJson(item));
          }
        } else if (response is Map && response.containsKey('data')) {
          // 新结构：data.products
          if (response['data'] is Map &&
              response['data'].containsKey('products')) {
            for (var item in response['data']['products']) {
              products.add(ProductModel.fromJson(item));
            }
          }
        }
      }

      return products;
    } catch (e) {
      print('Error fetching user products: $e');
      // 如果是404或其他常见错误，返回空列表而不是抛出异常
      if (e is ApiException && (e.statusCode == 404 || e.statusCode == 405)) {
        print(
            'No products found or endpoint not available yet, returning empty list');
        return [];
      }
      rethrow;
    }
  }

  // 保存产品分析结果到用户账户
  static Future<ProductModel> saveProductAnalysis({
    required ProductModel product,
    required Map<String, dynamic> analysisResult,
    Uint8List? imageBytes,
    String? imageFile,
  }) async {
    try {
      // 构建产品数据
      Map<String, dynamic> productData = {
        'name': product.name,
        'brand_name': product.brandName,
        'category': product.category,
        'description': product.description,
        'image_url': product.imageUrl,
        'ingredients': product.ingredients.map((i) => i.name).toList(),
        'analysis_result': analysisResult,
      };

      // 调试日志
      print('发送产品数据: ${json.encode(productData)}');

      final response = await post(
        '/user/products',
        body: productData,
      );

      print('接收产品响应: $response');

      // 根据响应格式解析返回的产品
      final savedProduct = response is Map && response.containsKey('data')
          ? ProductModel.fromJson(response['data'])
          : ProductModel.fromJson(response);

      // 如果有图片，则上传图片
      if (savedProduct.id.isNotEmpty) {
        try {
          if (imageBytes != null) {
            await postMultipartWeb(
              '/user/products/${savedProduct.id}/image',
              fileBytes: imageBytes,
              fileName: 'product_image.jpg',
            );
          } else if (imageFile != null) {
            await postMultipart(
              '/user/products/${savedProduct.id}/image',
              file: File(imageFile),
            );
          }
        } catch (e) {
          print('Error uploading product image: $e');
          // 不失败整个保存过程，只记录图片上传失败
        }
      }

      return savedProduct;
    } catch (e) {
      print('保存产品分析结果失败: $e');
      rethrow;
    }
  }

  // 模拟API调用，用于当后端未准备好时进行测试
  // 在实际生产环境中应删除此方法
  static Future<List<ProductModel>> getProductsMock() async {
    // 延迟以模拟网络请求
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      ProductModel(
        id: '1',
        name: 'COSRX 低pH洁面啫喱',
        brandName: 'COSRX',
        imageUrl:
            'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=100',
        description: '温和无泡洁面乳，氨基酸系',
        category: 'cleanser',
        ingredients: [
          IngredientModel(id: '1', name: '水', safetyLevel: 100),
          IngredientModel(id: '2', name: '甘油', safetyLevel: 95),
          IngredientModel(id: '3', name: '泛醇', safetyLevel: 90),
        ],
        rating: 4.8,
        reviewCount: 1200,
      ),
      ProductModel(
        id: '2',
        name: 'The Ordinary 维生素C精华',
        brandName: 'The Ordinary',
        imageUrl:
            'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=100',
        description: '高浓度抗氧化精华，美白提亮',
        category: 'serum',
        ingredients: [
          IngredientModel(id: '4', name: '维生素C', safetyLevel: 85),
          IngredientModel(id: '5', name: '透明质酸', safetyLevel: 92),
        ],
        rating: 4.5,
        reviewCount: 980,
      ),
      ProductModel(
        id: '3',
        name: '理肤泉特安舒缓保湿霜',
        brandName: '理肤泉',
        imageUrl:
            'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=100',
        description: '舒缓敏感肌肤，深度保湿',
        category: 'moisturizer',
        ingredients: [
          IngredientModel(id: '1', name: '水', safetyLevel: 100),
          IngredientModel(id: '2', name: '甘油', safetyLevel: 95),
          IngredientModel(id: '6', name: '矿物油', safetyLevel: 75),
        ],
        rating: 4.9,
        reviewCount: 1500,
      ),
    ];
  }

  // 获取完整的图片URL
  static String getFullImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      return '';
    }

    // 如果已经是完整URL，直接返回
    if (imagePath.startsWith('http:') || imagePath.startsWith('https:')) {
      return imagePath;
    }

    // 添加基础URL前缀
    String fullUrl =
        imagePath.startsWith('/') ? baseUrl + imagePath : '$baseUrl/$imagePath';

    return fullUrl;
  }

  // 分析产品成分冲突
  Future<Map<String, dynamic>> analyzeConflicts(ProductModel product) async {
    try {
      // 将产品数据转换为请求数据格式
      final Map<String, dynamic> requestData = {
        'product': product.toJson(),
      };

      // 调用分析冲突的API
      final response =
          await ApiService.post('/conflict/ingredients', body: requestData);

      // 如果直接返回分析结果文本
      if (response is String) {
        return {'analysisResult': response};
      }

      // 如果返回是Map格式，包含analysis字段
      if (response is Map && response.containsKey('analysis')) {
        return {'analysisResult': response['analysis']};
      }

      // 如果是通常的API返回格式
      return {'analysisResult': response.toString()};
    } catch (e) {
      print('冲突分析失败: $e');
      rethrow;
    }
  }

  // 保存肌肤分析结果
  static Future<Map<String, dynamic>> saveSkinAnalysisResult(
      Map<String, dynamic> data) async {
    try {
      final response = await post('/api/skin-analysis', body: data);
      return response;
    } catch (e) {
      print('保存肌肤分析结果失败: $e');
      return {'error': e.toString()};
    }
  }

  // Web平台专用: 保存肌肤分析结果，解决CORS问题
  static Future<Map<String, dynamic>> saveSkinAnalysisResultWeb(
      Map<String, dynamic> data) async {
    try {
      print('Web平台尝试保存肌肤分析结果...');

      // 获取token
      final token = await getToken();
      if (token == null) {
        print('Web平台: 用户未登录，无法保存分析结果');
        return {'error': '用户未登录', 'statusCode': 401};
      }

      // 构建请求头，包含CORS所需的头部
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // 构建请求体
      final requestBody = json.encode({
        'analysis_result': data,
        'analysis_time': DateTime.now().toIso8601String(),
        'platform': 'web',
      });

      // 修改API URL，确保与后端端点匹配
      final url = Uri.parse('${baseUrl}/skin-analysis/save_web');
      print('Web平台API请求URL: $url');

      // 发送请求
      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      );

      // 打印响应信息
      print('Web平台保存肌肤分析结果状态码: ${response.statusCode}');
      print('Web平台API响应内容: ${response.body}');

      // 检查响应
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Web平台肌肤分析结果保存成功: ${response.body}');
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('解析Web平台保存响应失败: $e');
          return {
            'success': true,
            'message': '保存成功',
            'raw': response.body,
          };
        }
      } else if (response.statusCode == 401) {
        return {'error': '未授权，请重新登录', 'statusCode': 401};
      } else {
        print('Web平台保存失败，响应: ${response.body}');
        return {
          'error': '服务器错误: ${response.statusCode}',
          'statusCode': response.statusCode,
          'raw': response.body,
        };
      }
    } catch (e) {
      print('Web平台保存肌肤分析结果失败: $e');
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 获取历史肌肤分析结果
  Future<List<Map<String, dynamic>>> getSkinAnalysisHistory() async {
    try {
      final response = await get('/api/skin-analysis/history');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('获取肌肤分析历史记录失败: $e');
      return [];
    }
  }

  // 分析产品图像
  Future<Map<String, dynamic>> analyzeProductImage(Uint8List imageBytes) async {
    try {
      // 打印请求信息
      print('正在发送产品图像分析请求...');

      // 获取token
      final token = await getToken();
      if (token == null) {
        return {'error': '用户未登录', 'statusCode': 401};
      }

      // 创建multipart请求
      final uri = Uri.parse('$baseUrl/api/products/analyze');
      final request = http.MultipartRequest('POST', uri);

      // 添加认证头
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // 添加图像文件
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'product_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 打印响应信息
      print('产品分析API响应状态码: ${response.statusCode}');
      print('产品分析API响应内容: ${response.body}');

      // 检查响应
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 尝试解析JSON
        try {
          final jsonResponse = jsonDecode(response.body);
          return {
            'data': jsonResponse,
            'statusCode': response.statusCode,
          };
        } catch (e) {
          print('解析JSON失败: $e');
          return {
            'error': '无法解析服务器响应',
            'statusCode': response.statusCode,
            'rawResponse': response.body,
          };
        }
      } else if (response.statusCode == 401) {
        return {'error': '未授权，请重新登录', 'statusCode': 401};
      } else {
        return {
          'error': '服务器错误: ${response.statusCode}',
          'statusCode': response.statusCode,
          'rawResponse': response.body,
        };
      }
    } catch (e) {
      print('产品分析请求失败: $e');
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 保存产品
  Future<Map<String, dynamic>> saveProduct(
      Map<String, dynamic> productData) async {
    try {
      // 打印请求信息
      print('保存产品数据: ${json.encode(productData)}');

      // 获取token
      final token = await getToken();
      if (token == null) {
        return {'error': '用户未登录'};
      }

      // 发送请求
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );

      // 打印响应信息
      print('保存产品API响应状态码: ${response.statusCode}');

      // 检查响应
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 尝试解析响应
        try {
          final jsonResponse = jsonDecode(response.body);
          print('保存产品API响应内容: $jsonResponse');
          return jsonResponse;
        } catch (e) {
          print('解析保存产品响应失败: $e');
          print('原始响应内容: ${response.body}');
          return {'error': '无法解析服务器响应'};
        }
      } else if (response.statusCode == 401) {
        return {'error': '未授权，请重新登录'};
      } else {
        print('保存产品失败，状态码: ${response.statusCode}，响应: ${response.body}');
        return {'error': '服务器错误: ${response.statusCode}'};
      }
    } catch (e) {
      print('保存产品请求失败: $e');
      return {'error': e.toString()};
    }
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
