import 'package:connectapp/screens/events/presentation/cubits/events_cubit.dart';
import 'package:connectapp/screens/notification/data/firebase_notification_repo.dart';
import 'package:connectapp/screens/notification/presentation/cubits/notification_cubits.dart';
import 'package:connectapp/screens/post/data/firebase_post_repo.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_cubits.dart';
import 'package:connectapp/screens/splah_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:connectapp/services/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final firebasePostRepo = FirebasePostRepo();
  final firebaseNotificationRepo = FirebaseNotificationRepo();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
          ),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
            notificationRepo: firebaseNotificationRepo,
          ),
        ),
        BlocProvider(create: (_) => EventsCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Connect App',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          brightness: Brightness.light,
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          //brightness: Brightness.dark,
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: SplashScreen(),
      ),
    );
  }
}
