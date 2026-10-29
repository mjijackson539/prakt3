import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'interceptors/api_key_interceptor.dart';
import 'widgets/cat_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiKey = const String.fromEnvironment('API_NINJAS_KEY');
  GetIt.instance.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1',
      
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    dio.interceptors.addAll([
      ApiKeyInterceptor(apiKey),
      PrettyDioLogger(requestHeader: false, responseBody: true),
    ]);
    return dio;
  });
  runApp(const CatApp());
}

class CatApp extends StatelessWidget {
  const CatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Породы кошек',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        appBar: _CatAppBar(),
        body: CatList(),
      ),
    );
  }
}

class _CatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CatAppBar();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Породы кошек'));
}
