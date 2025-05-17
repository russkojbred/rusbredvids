import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russkiy_bred/domain/entities/video.dart';
import 'package:russkiy_bred/presentation/blocs/video/video_bloc.dart';
import 'package:russkiy_bred/presentation/widgets/custom_app_bar.dart';
import 'package:russkiy_bred/presentation/widgets/video_card.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          context.read<VideoBloc>().add(LoadVideosEvent(category: VideoCategory.zhizn));
          break;
        case 1:
          context.read<VideoBloc>().add(LoadVideosEvent(category: VideoCategory.nezhizn));
          break;
        case 2:
          context.read<VideoBloc>().add(LoadLikedVideosEvent());
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RusskiyBredAppBar(
        title: 'Русский Бред видеоматериалы',
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/upload'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.file_upload),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Жизнь'),
          Tab(text: 'Нежизнь'),
          Tab(text: 'Любо'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildVideoGrid(VideoCategory.zhizn),
        _buildVideoGrid(VideoCategory.nezhizn),
        _buildVideoGrid(null, isLiked: true),
      ],
    );
  }

  Widget _buildVideoGrid(VideoCategory? category, {bool isLiked = false}) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VideoLoaded) {
          final videos = isLiked
              ? state.videos.where((video) => video.isLiked).toList()
              : state.videos.where((video) => video.category == category).toList();

          if (videos.isEmpty) {
            return Center(
              child: Text(
                'Нет видео в этом разделе',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return VideoCard(
                video: video,
                onTap: () => context.push('/player/${video.id}'),
                onLike: () => context.read<VideoBloc>().add(ToggleLikeEvent(videoId: video.id)),
              );
            },
          );
        } else if (state is VideoError) {
          return Center(
            child: Text(
              'Ошибка: ${state.message}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
