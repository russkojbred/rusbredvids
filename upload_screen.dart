import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russkiy_bred/domain/entities/video.dart';
import 'package:russkiy_bred/presentation/blocs/upload/upload_bloc.dart';
import 'package:russkiy_bred/presentation/widgets/custom_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accessKeyController = TextEditingController();
  final _titleController = TextEditingController();
  
  VideoCategory _selectedCategory = VideoCategory.zhizn;
  File? _selectedVideo;
  String? _selectedVideoName;

  @override
  void dispose() {
    _accessKeyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedVideo = File(result.files.first.path!);
        _selectedVideoName = result.files.first.name;
      });
    }
  }

  void _uploadVideo() {
    if (_formKey.currentState!.validate() && _selectedVideo != null) {
      context.read<UploadBloc>().add(
        UploadVideoEvent(
          videoFile: _selectedVideo!,
          title: _titleController.text,
          category: _selectedCategory,
          accessKey: _accessKeyController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RusskiyBredAppBar(
        title: 'Загрузка видео',
      ),
      body: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Видео успешно загружено'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is UploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка загрузки: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAccessKeyField(),
                  const SizedBox(height: 16.0),
                  _buildTitleField(),
                  const SizedBox(height: 16.0),
                  _buildCategorySelector(),
                  const SizedBox(height: 24.0),
                  _buildVideoSelector(),
                  const SizedBox(height: 32.0),
                  _buildUploadButton(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccessKeyField() {
    return TextFormField(
      controller: _accessKeyController,
      decoration: const InputDecoration(
        labelText: 'Ключ доступа',
        hintText: 'Введите ключ доступа',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Пожалуйста, введите ключ доступа';
        }
        if (value != 'xerxer123') {
          return 'Неверный ключ доступа';
        }
        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Название видео',
        hintText: 'Введите название видео',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Пожалуйста, введите название видео';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Категория',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: RadioListTile<VideoCategory>(
                title: const Text('Жизнь'),
                value: VideoCategory.zhizn,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<VideoCategory>(
                title: const Text('Нежизнь'),
                value: VideoCategory.nezhizn,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Видеофайл',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedVideoName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Выбрано: $_selectedVideoName',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Выбрать видео'),
              ),
            ],
          ),
        ),
        if (_selectedVideo == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              'Пожалуйста, выберите видеофайл',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadButton(UploadState state) {
    return ElevatedButton(
      onPressed: state is UploadLoading ? null : _uploadVideo,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: state is UploadLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  'Загрузка... ${(state.progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            )
          : const Text(
              'Загрузить видео',
              style: TextStyle(fontSize: 16.0),
            ),
    );
  }
}
