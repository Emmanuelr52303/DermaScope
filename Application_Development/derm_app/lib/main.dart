import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:network_info_plus/network_info_plus.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: username, password: password);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign In Failed: ${e.toString()}')),
        );
      }
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
                      border: OutlineInputBorder(),
                      labelText: 'Email',
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Regular expression for password validation (including special character)
    RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]_-)[A-Za-z\d!@#$%^&*(),.?":{}|<>_-]{8,}$',
    );

    if (username.isNotEmpty && password.isNotEmpty) {
      if (!passwordRegExp.hasMatch(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, and one special character.')),
        );
        return;
      }

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: username,
          password: password,
        );

        // Add user data to Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'email': username,
          'password': password,
          'created_at': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account Creation Failed: ${e.toString()}')),
        );
      }
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
                labelText: 'Email',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.verified),
                title: Text('Verification Page'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Verification Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerificationScreen()),
                  );
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
              onPressed: () =>
                  // Navigate to dermascop connectivity screen
                  showWifiCheckModal(context),
              child: Text('Image Capture'),
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
      body: Column(
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
                  MaterialPageRoute(builder: (context) => AccountInfoScreen()),
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
                // Handle App info button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppInfoScreen()),
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
                // Handle Log Out button press
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
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        centerTitle: true,
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify'),
        centerTitle: true,
      ),
    );
  }
}

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user != null
            ? SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                  ),
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width, // Full screen width
                    height: 30, // Make it square
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Pushes text apart
                      children: [
                        Text("Email:",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold)), // Left side
                        Text(user.email ?? "Not available",
                            style: TextStyle(fontSize: 13)), // Right side
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                  ),
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width, // Full screen width
                    height: 30, // Make it square
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Pushes text apart
                      children: [
                        Text("User ID:",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold)), // Left side
                        Text(user.uid,
                            style: TextStyle(fontSize: 13)), // Right side
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                  ),
                ],
              ))
            : Text("No user is logged in"),
      ),
    );
  }
}

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Info'),
        centerTitle: true,
      ),
    );
  }
}

void showWifiCheckModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => WifiCheckContent(),
  );
}

class WifiCheckContent extends StatefulWidget {
  const WifiCheckContent({super.key});

  @override
  _WifiCheckContentState createState() => _WifiCheckContentState();
}

class _WifiCheckContentState extends State<WifiCheckContent> {
  bool isChecking = false;
  bool isConnectedToPico = true;
  bool isPolling = false;
  bool isConnected = false;
  bool isReceiving = true;
  Timer? pollTimer;
  Uint8List? imageData;
  late Socket _socket;
  List<int> imageBytes = [];
  String picoIp = "192.168.4.1"; // Pico IP
  int picoPort = 4242;

  final Duration pollingInterval = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    // requestPermissions();
    // checkConnection();
  }

  /*Future<void> requestPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> checkConnection() async {
    setState(() {
      isChecking = true;
    });

    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      print("Connected to Wi-Fi.");

      final info = NetworkInfo();
      final wifiName = await info.getWifiName(); // SSID

      debugPrint("Current Wi-Fi: $wifiName");

      if (wifiName?.contains('DermaScope') == true) {
        setState(() {
          isConnectedToPico = true;
          isChecking = false;
        });
        print("Connected to Pico's Wi-Fi!");
      } else {
        setState(() {
          isChecking = false;
          isConnected = true;
        });
        print("Not connected to DermaScope Wi-Fi.");
      }
    } else {
      setState(() {
        isChecking = false;
      });
      print("No Wi-Fi connection.");
    }
  }*/

  Future<void> saveImage(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath =
        '${directory.path}/captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = File(imagePath);

    await imageFile.writeAsBytes(imageBytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image saved to: $imagePath')),
    );
  }

  void startPollingForImage() async {
    setState(() {
      isPolling = true;
      imageBytes = [];
      imageData = null;
    });

    print("Connecting to Pico TCP server...");
    try {
      _socket = await Socket.connect(picoIp, picoPort);
      print("Connected to Pico!");
      setState(() {
        isConnected = true;
      });

      int? expectedImageSize;
      List<int> buffer = [];

      _socket.listen((List<int> event) {
        buffer.addAll(event);

        if (expectedImageSize == null && buffer.length >= 4) {
          // Extract the first 4 bytes as the image size
          expectedImageSize =
              ByteData.sublistView(Uint8List.fromList(buffer.sublist(0, 4)))
                  .getUint32(0, Endian.big);
          print("Expected image size: $expectedImageSize bytes");

          // Remove those 4 bytes from buffer so only image data remains
          buffer = buffer.sublist(4);
        }

        if (expectedImageSize != null) {
          imageBytes.addAll(buffer);
          buffer.clear();

          if (imageBytes.length >= expectedImageSize!) {
            print("Full image received: ${imageBytes.length} bytes");
            _socket.close();
            setState(() {
              imageData = Uint8List.fromList(imageBytes);
              isReceiving = false;
            });
          }
        }
      });
    } catch (e) {
      print("Error connecting to Pico: $e");
    }
  }

  void stopPolling() {
    pollTimer?.cancel();
    setState(() {
      isPolling = false;
    });
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    //   if (isConnectedToPico) {
    if (isPolling) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Capturing Image...", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: stopPolling,
              child: Text("Stop Capture"),
            ),
          ],
        ),
      );
    }

    if (imageData != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Captured Image:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Image.memory(
              imageData!,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveImage(imageData!),
              child: Text("Save Image"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: startPollingForImage,
              child: Text("Capture Another"),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Connected to DermaScope!", style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isConnectedToPico ? startPollingForImage : null,
            child: Text("Start Image Capture"),
          ),
        ],
      ),
    );
//    }

/*    if (isConnected) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please connect to 'DermaScope' Wi-Fi network",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("No Wifi network", style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );*/
  }
}
