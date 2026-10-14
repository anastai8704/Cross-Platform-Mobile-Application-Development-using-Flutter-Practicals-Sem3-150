import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username') ?? '';

  runApp(MyApp(loggedIn: loggedIn, username: username));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  final String username;

  const MyApp({
    super.key,
    required this.loggedIn,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loggedIn
          ? HomeScreen(username: username)
          : const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final user = TextEditingController();
  final pass = TextEditingController();
  bool remember = false;

  void login() async {
    if (user.text.trim().isEmpty || pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username and password')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.text.trim());
    await prefs.setBool('isLoggedIn', remember);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(username: user.text.trim()),
      ),
    );
  }

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: user,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              value: remember,
              title: const Text('Remember Me'),
              onChanged: (value) {
                setState(() => remember = value ?? false);
              },
            ),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('isLoggedIn');

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $username',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}