import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russkiy_bred/domain/entities/video.dart';
import 'package:russkiy_bred/domain/repositories/video_repository.dart';

// События
abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVideosEvent extends VideoEvent {
  final VideoCategory? category;

  LoadVideosEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class LoadVideoDetailsEvent extends VideoEvent {
  final String videoId;

  LoadVideoDetailsEvent({required this.videoId});

  @override
  List<Object?> get props => [videoId];
}

class LoadLikedVideosEvent extends VideoEvent {}

class ToggleLikeEvent extends VideoEvent {
  final String videoId;

  ToggleLikeEvent({required this.videoId});

  @override
  List<Object?> get props => [videoId];
}

// Состояния
abstract class VideoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> videos;

  VideoLoaded({required this.videos});

  @override
  List<Object?> get props => [videos];
}

class VideoDetailsLoaded extends VideoState {
  final Video video;

  VideoDetailsLoaded({required this.video});

  @override
  List<Object?> get props => [video];
}

class VideoError extends VideoState {
  final String message;

  VideoError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository videoRepository;

  VideoBloc({required this.videoRepository}) : super(VideoInitial()) {
    on<LoadVideosEvent>(_onLoadVideos);
    on<LoadVideoDetailsEvent>(_onLoadVideoDetails);
    on<LoadLikedVideosEvent>(_onLoadLikedVideos);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onLoadVideos(LoadVideosEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final videos = await videoRepository.getVideos(event.category);
      emit(VideoLoaded(videos: videos));
    } catch (e) {
      emit(VideoError(message: e.toString()));
    }
  }

  Future<void> _onLoadVideoDetails(LoadVideoDetailsEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final video = await videoRepository.getVideoDetails(event.videoId);
      emit(VideoDetailsLoaded(video: video));
    } catch (e) {
      emit(VideoError(message: e.toString()));
    }
  }

  Future<void> _onLoadLikedVideos(LoadLikedVideosEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final videos = await videoRepository.getLikedVideos();
      emit(VideoLoaded(videos: videos));
    } catch (e) {
      emit(VideoError(message: e.toString()));
    }
  }

  Future<void> _onToggleLike(ToggleLikeEvent event, Emitter<VideoState> emit) async {
    try {
      await videoRepository.toggleLike(event.videoId);
      
      // Обновляем текущее состояние с новыми данными о лайках
      if (state is VideoLoaded) {
        final currentVideos = (state as VideoLoaded).videos;
        final updatedVideos = await Future.wait(
          currentVideos.map((video) async {
            if (video.id == event.videoId) {
              return video.copyWith(isLiked: !video.isLiked);
            }
            return video;
          }),
        );
        emit(VideoLoaded(videos: updatedVideos));
      } else if (state is VideoDetailsLoaded) {
        final currentVideo = (state as VideoDetailsLoaded).video;
        if (currentVideo.id == event.videoId) {
          final updatedVideo = currentVideo.copyWith(isLiked: !currentVideo.isLiked);
          emit(VideoDetailsLoaded(video: updatedVideo));
        }
      }
    } catch (e) {
      emit(VideoError(message: e.toString()));
    }
  }
}
