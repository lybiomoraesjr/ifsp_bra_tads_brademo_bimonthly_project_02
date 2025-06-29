import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  final SecureStorageService _storage = SecureStorageService();

  ApiService({required this.baseUrl}) {
    print('ApiService: Inicializando com URL: $baseUrl');
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('Dio: $obj'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = await _storage.getUser();
            if (user != null && user['token'] != null) {
              options.headers['Authorization'] = 'Bearer ${user['token']}';
              print('ApiService: Token adicionado ao header: ${user['token']}');
            } else {
              print('ApiService: Nenhum token encontrado');
            }
          } catch (e) {
            print('ApiService: Erro ao obter token: $e');
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> testConnection() async {
    try {
      print('ApiService: Testando conexão com $baseUrl');
      final response = await _dio.get(
        '/api/health',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      print('ApiService: Conexão testada com sucesso: ${response.statusCode}');
      return true;
    } catch (e) {
      print('ApiService: Erro ao testar conexão: $e');
      return false;
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Erro de timeout na conexão');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Erro desconhecido';

        switch (statusCode) {
          case 400:
            return Exception('Dados inválidos: $message');
          case 401:
            return Exception('Não autorizado: $message');
          case 404:
            return Exception('Recurso não encontrado: $message');
          case 409:
            return Exception('Conflito: $message');
          case 500:
            return Exception('Erro interno do servidor: $message');
          default:
            return Exception('Erro na resposta do servidor: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      case DioExceptionType.connectionError:
        return Exception('Erro de conexão: Verifique sua internet');
      case DioExceptionType.unknown:
        return Exception(
          'Erro desconhecido: ${error.message ?? 'Sem detalhes'}',
        );
      default:
        final errorMessage = error.message ?? 'Erro de conexão';
        return Exception('Erro na conexão: $errorMessage');
    }
  }
}
