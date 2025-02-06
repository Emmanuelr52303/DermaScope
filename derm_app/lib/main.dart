import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DermaLight',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 119, 158, 207)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    // Simple validation logic
    if (username.isNotEmpty && password.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Log-in-background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title
          Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold),
                  )),
            ]),
          ),
          // Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _usernameController,
                    decoration: InputDecoration(
                      //filled: true,
                      //fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: Text('Sign In'),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateAccount()),
                      );
                    },
                    child: Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    // Simple validation logic
    if (username.isNotEmpty && password.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          Text(
            'Must contain:\n8 characters\nOne capital\nOne lowercase\nOne number',
            style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _createAccount,
              child: Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DermaLight'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings), // Settings icon
            onPressed: () {
              // Handle settings button press
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // 60% of screen width
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Tutorial'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to tutorial
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Info Page'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LearnScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text('History/Library'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to History/Library screen
                },
              ),
              ListTile(
                leading: Icon(Icons.verified),
                title: Text('Verification Page'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Verification Page
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Welcome to DermaLight!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Learn Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LearnScreen()),
                );
              },
              child: Text('+ Add a Device'),
            ),
          ],
        ),
      ),
    );
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learn About Dermatology'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dermatology Overview:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Dermatology is the branch of medicine that deals with the skin, nails, hair, and their diseases. It involves diagnosis and treatment of conditions such as acne, eczema, psoriasis, and skin cancer.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Common Skin Conditions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '1. Acne\n2. Psoriasis\n3. Eczema\n4. Melanoma\n5. Warts',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                color: Colors.black, // Line color
                thickness: 1, // Line thickness
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width, // Full screen width
                height: 30, // Make it square
                child: OutlinedButton(
                  onPressed: () {
                    // Handle Account info button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.transparent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // No rounded corners
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('Account Info'),
                ),
              ),
              Divider(
                color: Colors.black, // Line color
                thickness: 1, // Line thickness
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width, // Full screen width
                height: 30, // Make it square
                child: OutlinedButton(
                  onPressed: () {
                    // Handle Account info button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.transparent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // No rounded corners
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('App Info'),
                ),
              ),
              Divider(
                color: Colors.black, // Line color
                thickness: 1, // Line thickness
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width, // Full screen width
                height: 30, // Make it square
                child: OutlinedButton(
                  onPressed: () {
                    // Handle Account info button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.transparent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // No rounded corners
                    ),
                    padding: EdgeInsets.zero, // Full width, custom height
                  ),
                  child: Text('Log Out'),
                ),
              ),
              Divider(
                color: Colors.black, // Line color
                thickness: 1, // Line thickness
              ),
            ],
          ),
        ),
      ),
    );
  }
}
