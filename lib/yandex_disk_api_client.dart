import 'dart:io';
import 'package:dio/dio.dart';
import 'package:russkiy_bred/core/errors/exceptions.dart';
import 'package:russkiy_bred/data/models/yandex_disk_resource_model.dart';
import 'package:russkiy_bred/data/models/yandex_disk_link_model.dart';

class YandexDiskApiClient {
  final Dio _dio;
  final String _baseUrl = 'https://cloud-api.yandex.net/v1/disk';
  
  YandexDiskApiClient({Dio? dio}) : _dio = dio ?? Dio();
  
  // Получение списка ресурсов (файлов) из указанной папки на Яндекс.Диске
  Future<List<YandexDiskResourceModel>> getResources(String path) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/resources',
        queryParameters: {
          'path': path,
          'limit': 100,
          'sort': 'created',
          'fields': 'items.name,items.path,items.created,items.type,items.media_type,items.preview'
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['_embedded'] != null && data['_embedded']['items'] != null) {
          final items = data['_embedded']['items'] as List;
          return items
              .where((item) => item['media_type'] == 'video')
              .map((item) => YandexDiskResourceModel.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw ServerException(
          message: 'Ошибка получения списка видео: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Ошибка при обращении к Яндекс.Диску: ${e.toString()}',
      );
    }
  }
  
  // Получение ссылки для скачивания файла
  Future<String> getDownloadLink(String path) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/resources/download',
        queryParameters: {'path': path},
      );
      
      if (response.statusCode == 200) {
        final linkModel = YandexDiskLinkModel.fromJson(response.data);
        
        // Получение реальной ссылки для скачивания
        final downloadResponse = await _dio.get(
          linkModel.href,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => status != null && status < 400,
          ),
        );
        
        if (downloadResponse.statusCode == 302) {
          return downloadResponse.headers.value('location') ?? '';
        }
        
        return linkModel.href;
      } else {
        throw ServerException(
          message: 'Ошибка получения ссылки для скачивания: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Ошибка при обращении к Яндекс.Диску: ${e.toString()}',
      );
    }
  }
  
  // Получение ссылки для загрузки файла
  Future<String> getUploadLink(String path, bool overwrite) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/resources/upload',
        queryParameters: {
          'path': path,
          'overwrite': overwrite,
        },
      );
      
      if (response.statusCode == 200) {
        final linkModel = YandexDiskLinkModel.fromJson(response.data);
        return linkModel.href;
      } else {
        throw ServerException(
          message: 'Ошибка получения ссылки для загрузки: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Ошибка при обращении к Яндекс.Диску: ${e.toString()}',
      );
    }
  }
  
  // Загрузка файла на Яндекс.Диск
  Future<bool> uploadFile(String uploadUrl, File file, Function(int, int)? onProgress) async {
    try {
      final fileLength = await file.length();
      
      final response = await _dio.put(
        uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Length': fileLength,
          },
        ),
        onSendProgress: onProgress,
      );
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw ServerException(
        message: 'Ошибка при загрузке файла: ${e.toString()}',
      );
    }
  }
}
