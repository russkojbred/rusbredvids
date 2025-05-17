import 'package:equatable/equatable.dart';

enum VideoCategory {
  zhizn, // Жизнь
  nezhizn, // Нежизнь
}

class Video extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String videoUrl;
  final VideoCategory category;
  final DateTime uploadDate;
  final bool isLiked;

  const Video({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    required this.uploadDate,
    this.isLiked = false,
  });

  Video copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    VideoCategory? category,
    DateTime? uploadDate,
    bool? isLiked,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      uploadDate: uploadDate ?? this.uploadDate,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        videoUrl,
        category,
        uploadDate,
        isLiked,
      ];
}
