class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String roomHub = '/rooms';
  static const String createRoom = '/rooms/create';
  static const String joinRoom = '/rooms/join';
  // roomLobby and diceRolling use arguments for roomId
  static const String roomLobby = '/room';
  static const String diceRolling = '/room/roll';
}
