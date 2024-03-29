import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:market/login/provider/login_provider.dart';
import 'package:market/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(credential);
      userCredential = credential;
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        // logic
        print(e.toString());
      } else if (e.code == "wrong-password") {
        // logic
        print(e.toString());
      }
    } catch (e) {
      // logic
      print(e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    print("accessToken: ${credential.accessToken}");
    print("idToken: ${credential.idToken}");

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/fastcampus_logo.png"),
            Text(
              "마트",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 42,
              ),
            ),
            SizedBox(height: 64),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "이메일",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "이메일 주소를 입력하세요.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: pwdTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "비밀번호",
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "비밀번호를 입력하세요.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Consumer(
                builder: (context, ref, child) {
                  return MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final result = await signIn(
                            emailTextController.text.trim(),
                            pwdTextController.text.trim());

                        if (result == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("로그인 실패"),
                              ),
                            );
                          }
                          return;
                        }
                        ref.watch(userCredentialProvider.notifier).state =
                            result;
                        // 로그인 및 검증 성공
                        if (context.mounted) {
                          context.go("/");
                        }
                      }
                    },
                    height: 48,
                    minWidth: double.infinity,
                    color: Colors.red,
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => context.push("/sign_up"),
              child: Text("계정이 없나요? 회원가입"),
            ),
            const Divider(),
            InkWell(
                onTap: () async {
                  final userCredit = await signInWithGoogle();

                  if (userCredit == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("구글 로그인 실패"),
                    ));
                    return;
                  }
                  if (context.mounted) {
                    context.go("/");
                  }
                },
                child: Image.asset("assets/btn_google_signin.png")),
          ],
        ),
      )),
    );
  }
}
