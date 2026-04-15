import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/room_provider.dart';
import 'routes/app_routes.dart';
import 'utils/app_styles.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/room_hub_screen.dart';
import 'screens/create_room_screen.dart';
import 'screens/join_room_screen.dart';
import 'screens/room_lobby_screen.dart';
import 'screens/dice_rolling_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FateCasterApp());
}

class FateCasterApp extends StatelessWidget {
  const FateCasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
      ],
      child: _AuthWrapper(),
    );
  }
}

/// Listens to Firebase auth state and updates UserProvider accordingly.
class _AuthWrapper extends StatefulWidget {
  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state changes and update UserProvider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (mounted) {
          context.read<UserProvider>().setUser(user);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FateCaster',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _route(const SplashScreen(), settings);
      case AppRoutes.auth:
        return _route(const AuthScreen(), settings);
      case AppRoutes.login:
        return _route(const LoginScreen(), settings);
      case AppRoutes.signup:
        return _route(const SignupScreen(), settings);
      case AppRoutes.home:
        return _route(const HomeScreen(), settings);
      case AppRoutes.profile:
        return _route(const ProfileScreen(), settings);
      case AppRoutes.roomHub:
        return _route(const RoomHubScreen(), settings);
      case AppRoutes.createRoom:
        return _route(const CreateRoomScreen(), settings);
      case AppRoutes.joinRoom:
        return _route(const JoinRoomScreen(), settings);
      case AppRoutes.roomLobby:
        final args = settings.arguments as Map<String, dynamic>?;
        final roomId = args?['roomId'] as String? ?? '';
        return _route(RoomLobbyScreen(roomId: roomId), settings);
      case AppRoutes.diceRolling:
        final args = settings.arguments as Map<String, dynamic>?;
        final roomId = args?['roomId'] as String?;
        return _route(DiceRollingScreen(roomId: roomId), settings);
      default:
        return _route(const SplashScreen(), settings);
    }
  }

  MaterialPageRoute<dynamic> _route(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => screen,
      settings: settings,
    );
  }
}
