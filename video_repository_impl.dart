import 'dart:io';
import 'package:russkiy_bred/data/datasources/local/video_local_datasource.dart';
import 'package:russkiy_bred/data/datasources/remote/yandex_disk_api_client.dart';
import 'package:russkiy_bred/data/models/video_model.dart';
import 'package:russkiy_bred/domain/entities/video.dart';
import 'package:russkiy_bred/domain/repositories/video_repository.dart';
import 'package:russkiy_bred/core/errors/exceptions.dart';
import 'package:russkiy_bred/core/errors/failures.dart';
import 'package:russkiy_bred/core/network/network_info.dart';
import 'package:uuid/uuid.dart';

class VideoRepositoryImpl implements VideoRepository {
  final YandexDiskApiClient remoteDataSource;
  final VideoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<List<Video>> getVideos(VideoCategory? category) async {
    if (await networkInfo.isConnected) {
      try {
        // Получаем видео из Яндекс.Диска
        final remotePath = category == null 
            ? '/videos' 
            : '/videos/${category == VideoCategory.zhizn ? 'zhizn' : 'nezhizn'}';
        
        final remoteResources = await remoteDataSource.getResources(remotePath);
        
        // Преобразуем ресурсы в модели видео
        final remoteVideos = await Future.wait(
          remoteResources.map((resource) async {
            // Получаем ссылку для скачивания
            final downloadUrl = await remoteDataSource.getDownloadLink(resource.path);
            
            // Определяем категорию на основе пути
            final videoCategory = resource.path.contains('zhizn') 
                ? VideoCategory.zhizn 
                : VideoCategory.nezhizn;
            
            return VideoModel(
              id: resource.path,
              title: resource.name,
              description: null,
              thumbnailUrl: resource.preview,
              videoUrl: downloadUrl,
              category: videoCategory,
              uploadDate: resource.created,
              isLiked: false,
            );
          }),
        );
        
        // Сохраняем полученные видео в локальную базу данных
        await localDataSource.cacheVideos(remoteVideos);
        
        // Получаем информацию о лайках из локальной базы данных
        final likes = await localDataSource.getLikes();
        
        // Объединяем информацию о видео и лайках
        final videos = remoteVideos.map((video) {
          final isLiked = likes.any((like) => like.videoId == video.id);
          return video.copyWith(isLiked: isLiked);
        }).toList();
        
        return videos;
      } on ServerException catch (e) {
        throw ServerFailure(message: e.message);
      }
    } else {
      try {
        // Если нет подключения к интернету, получаем видео из локальной базы данных
        final localVideos = await localDataSource.getVideos();
        
        if (category != null) {
          return localVideos.where((video) => video.category == category).toList();
        }
        
        return localVideos;
      } on CacheException catch (e) {
        throw CacheFailure(message: e.message);
      }
    }
  }
  
  @override
  Future<Video> getVideoDetails(String videoId) async {
    try {
      // Сначала пытаемся получить видео из локальной базы данных
      final video = await localDataSource.getVideoById(videoId);
      
      // Если есть подключение к интернету, обновляем ссылку на видео
      if (await networkInfo.isConnected) {
        try {
          final downloadUrl = await remoteDataSource.getDownloadLink(videoId);
          return video.copyWith(videoUrl: downloadUrl);
        } on ServerException {
          // Если не удалось получить обновленную ссылку, используем сохраненную
          return video;
        }
      }
      
      return video;
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }
  
  @override
  Future<List<Video>> getLikedVideos() async {
    try {
      // Получаем все видео из локальной базы данных
      final videos = await localDataSource.getVideos();
      
      // Получаем все лайки
      final likes = await localDataSource.getLikes();
      
      // Фильтруем видео по лайкам
      return videos
          .where((video) => likes.any((like) => like.videoId == video.id))
          .map((video) => video.copyWith(isLiked: true))
          .toList();
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }
  
  @override
  Future<void> toggleLike(String videoId) async {
    try {
      // Проверяем, есть ли уже лайк для этого видео
      final likes = await localDataSource.getLikes();
      final isLiked = likes.any((like) => like.videoId == videoId);
      
      if (isLiked) {
        // Если лайк уже есть, удаляем его
        await localDataSource.removeLike(videoId);
      } else {
        // Если лайка нет, добавляем его
        await localDataSource.addLike(videoId);
      }
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }
  
  @override
  Future<void> uploadVideo(File videoFile, String title, VideoCategory category, String accessKey) async {
    // Проверяем ключ доступа
    if (accessKey != 'xerxer123') {
      throw InvalidAccessKeyFailure(message: 'Неверный ключ доступа');
    }
    
    // Проверяем подключение к интернету
    if (!await networkInfo.isConnected) {
      throw NoInternetConnectionFailure(message: 'Отсутствует подключение к интернету');
    }
    
    try {
      // Генерируем уникальное имя файла
      final uuid = Uuid();
      final fileName = '${uuid.v4()}_${title.replaceAll(' ', '_')}.mp4';
      
      // Определяем путь для загрузки на Яндекс.Диск
      final remotePath = '/videos/${category == VideoCategory.zhizn ? 'zhizn' : 'nezhizn'}/$fileName';
      
      // Получаем ссылку для загрузки
      final uploadUrl = await remoteDataSource.getUploadLink(remotePath, true);
      
      // Загружаем файл
      final success = await remoteDataSource.uploadFile(uploadUrl, videoFile, null);
      
      if (!success) {
        throw ServerFailure(message: 'Не удалось загрузить видео');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}
