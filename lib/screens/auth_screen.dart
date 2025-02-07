import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cityguideapp/screens/city_selection_screen.dart';


class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('AuthScreen initialized');
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User is already signed in: ${user.email}');
      print('User is already signed in: ${user.uid}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CitySelectionScreen())
        );
      });
    } else {
      print('No user currently signed in');
    }
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential;
        if (_isLogin) {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        }
        if (userCredential.user != null) {
// Replace Navigator.pushReplacementNamed with:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CitySelectionScreen())
          );        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
        _showErrorSnackbar(e.message ?? 'An error occurred. Please try again.');
      } catch (error) {
        print('Error during authentication: $error');
        _showErrorSnackbar('An unexpected error occurred. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }


  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
// Replace Navigator.pushReplacementNamed with:
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CitySelectionScreen())
      );    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google Sign In: ${e.code} - ${e.message}');
      _showErrorSnackbar(e.message ?? 'An error occurred during Google Sign In. Please try again.');
    } catch (error) {
      print('Error during Google Sign In: $error');
      _showErrorSnackbar('An unexpected error occurred during Google Sign In. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
// Replace Navigator.pushReplacementNamed with:
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CitySelectionScreen())
      );    } on SignInWithAppleAuthorizationException catch (e) {
      print('SignInWithAppleAuthorizationException: ${e.code} - ${e.message}');
      _showErrorSnackbar(e.message);
    } catch (error) {
      print('Error during Apple Sign In: $error');
      _showErrorSnackbar('An unexpected error occurred during Apple Sign In. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your email to reset password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      _showErrorSnackbar('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during password reset: ${e.code} - ${e.message}');
      _showErrorSnackbar(e.message ?? 'An error occurred during password reset. Please try again.');
    } catch (error) {
      print('Error during password reset: $error');
      _showErrorSnackbar('An unexpected error occurred during password reset. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building AuthScreen');
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bckgrd.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to City Guide',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover the world\'s most amazing cities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin ? 'Login' : 'Create Account',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CupertinoColors.systemIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : Text(
                              _isLogin ? 'Login' : 'Register',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading ? null : () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin
                                  ? 'Need an account? Register'
                                  : 'Have an account? Login',
                            ),
                          ),
                          if (_isLogin)
                            TextButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              child: const Text('Forgot Password?'),
                            ),
                          const SizedBox(height: 24),
                          const Text(
                            'Or continue with',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _SocialButton(
                                onPressed: _isLoading ? null : _signInWithGoogle,
                                icon: 'icons/google.jpg',
                                label: 'Google',
                              ),
                              _SocialButton(
                                onPressed: _isLoading ? null : _signInWithApple,
                                icon: 'icons/apple.jpg',
                                label: 'Apple',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                icon,
                height: 24,
                width: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

