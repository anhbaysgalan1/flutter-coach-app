import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:money_monitor/main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSignUp = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();
  String _resetFormData = "";
  final Map<String, String> _formData = {
    "email": null,
    "password": null,
    "confirmPassword": null
  };

  void _authenticateWithGoogle() async {
    await GoogleSignIn().signOut();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  void _authenticateWithEmailandPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
    } catch (e) {
      String errorMessage = e.message;
      print(errorMessage);
      String invalidPassword =
          "хэрэглэгчийн нууц үг буруу эсвэл хоосон байна.";
      String userDoesntExist =
          "хэрэглэгч олдсонгүй";

      if (errorMessage == invalidPassword) {
        _buildSignInErrorDialog("Нууц үг буруу байна", true);
      } else if (errorMessage == userDoesntExist) {
        _buildSignInErrorDialog("Хэрэглэгч бүртгэлгүй байна", true);
      } else {
        _buildSignInErrorDialog(
            "Та дахин оролдоно уу", true);
      }
    }
  }

  void _signUpWithEmailandPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      setState(() {
        _showSignUp = false;
      });
    } catch (e) {
      String errorMessage = e.message;
      print(errorMessage);
      if (errorMessage ==
          "аль хэдийн бүртгэлтэй байна.") {
        _buildSignInErrorDialog(
            "аль хэдийн бүртгэлтэй байна.");
      } else {
        _buildSignInErrorDialog(
            "аль хэдийн бүртгэлтэй байна", true);
      }
    }
  }

  _buildSignInErrorDialog(String message, [bool showReset]) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          title: Text("Account Error"),
          actions: <Widget>[
            showReset != null && showReset == true
                ? MaterialButton(
                    child: Text("Нууц үг сэргээх"),
                    onPressed: () {},
                  )
                : Container(),
            MaterialButton(
              child: Text("За"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Text(
      "Expense tracker course",
      style: TextStyle(
        fontSize: 40.0,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).accentColor,
        wordSpacing: 2.0,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return "Та зөв и-мейл хаяг оруулна уу.";
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(30.0),
        ),
        hintText: "и-мейл",
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
      ),
      onSaved: (String value) {
        _formData["email"] = value;
      },
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty || value.length < 8) {
          return "та зөв нууц үг оруулна уу.";
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(30.0),
        ),
        helperText: _showSignUp ? "Багадаа 8 тэмдэгт" : "",
        hintText: "Нууц үг",
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        hasFloatingPlaceholder: true,
        filled: true,
        fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
      ),
      onSaved: (String value) {
        _formData["password"] = value;
      },
      obscureText: true,
    );
  }

  Widget _buildConfirmPassword() {
    return Column(
      children: <Widget>[
        TextFormField(
          validator: (String value) {
            if (value.isEmpty || value.length < 8) {
              return "зөв нууц үг оруулна уу.";
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30.0),
            ),
            hintText: "Нууц үг баталгаажуулах",
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
            ),
            hasFloatingPlaceholder: true,
            filled: true,
            fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
          ),
          onSaved: (String value) {
            _formData["confirmPassword"] = value;
          },
          obscureText: true,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Theme.of(context).accentColor
            : Colors.grey[900],
      ),
      child: MaterialButton(
        onPressed: () async {
          if (!_resetFormKey.currentState.validate()) {
            return "";
          }
          _resetFormKey.currentState.save();
          await FirebaseAuth.instance
              .sendPasswordResetEmail(email: _resetFormData);
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Нууц үг сэргээх"),
                content: Text(
                    "Танд сэргээх и-мейл очсон эсэхийг шалгана уу .")
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("За"),
                  ),
                ],
              );
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.send,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Илгээх",
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildCancelButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Theme.of(context).accentColor
            : Colors.grey[900],
      ),
      child: MaterialButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cancel,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Цуцлах",
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildResetDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 200,
        width: 500,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              "Нууц үг сэргээх",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Card(
              clipBehavior: Clip.none,
              elevation: 3.0,
              margin: EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Form(
                key: _resetFormKey,
                child: TextFormField(
                  onSaved: (String value) => _resetFormData = value,
                  validator: (String value) {
                    if (value.isEmpty ||
                        !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                            .hasMatch(value)) {
                      return "Зөв и-мейл хаяг оруулна уу.";
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    hintText: "и-мейл",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    hasFloatingPlaceholder: true,
                    prefix: Text("  "),
                    filled: true,
                    fillColor: deviceTheme == "light"
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildSaveButton(),
                SizedBox(
                  width: 10,
                ),
                _buildCancelButton()
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetWidth = MediaQuery.of(context).size.width > 550.0
        ? 500.0
        : MediaQuery.of(context).size.width * 0.9;

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: deviceTheme == "light"
                ? Theme.of(context).accentColor
                : Colors.blue[700],
            elevation: 4.0,
            icon: const Icon(MdiIcons.google),
            label: const Text('Google хаягаар нэвтрэх'),
            onPressed: _authenticateWithGoogle,
          ),
          bottomNavigationBar: BottomAppBar(
            color: deviceTheme == "light" ? Colors.white : Colors.grey[750],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 80.0),
                    ),
                    IconButton(
                      icon:
                          Icon(_showSignUp ? MdiIcons.login : Icons.person_add),
                      onPressed: () {
                        setState(() {
                          _showSignUp = !_showSignUp;
                          _formData["email"] = null;
                          _formData["password"] = null;
                          _formData["confirmPassword"] = null;
                          _formKey.currentState.reset();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Container(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: targetWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildHeader(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _buildEmailField(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildPasswordField(),
                        SizedBox(
                          height: 10,
                        ),
                        _showSignUp ? _buildConfirmPassword() : Container(),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: deviceTheme == "light"
                                ? Theme.of(context).accentColor
                                : Colors.blue[700],
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              if (!_formKey.currentState.validate()) {
                                return "";
                              }

                              _formKey.currentState.save();

                              if (_showSignUp) {
                                if (_formData['password'] !=
                                    _formData['confirmPassword']) {
                                  return _buildSignInErrorDialog(
                                      "Please enter matching passwords");
                                }
                                _signUpWithEmailandPassword(
                                    _formData["email"], _formData["password"]);
                              } else {
                                _authenticateWithEmailandPassword(
                                    _formData["email"], _formData["password"]);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  _showSignUp ? "Бүртгүүлэх" : "Нэвтрэх",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FlatButton(
                          child: Text("Нууц үг сэргээх"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildResetDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
