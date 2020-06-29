import 'package:money_monitor/main.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  String _nameFormData;
  bool darkThemeVal;

  @override
  void initState() {
    super.initState();
    _nameFormData = "";
    darkThemeVal = deviceTheme == "light" ? false : true;
  }

  _buildSaveButton(Function changeName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Theme.of(context).accentColor
            : Colors.grey[900],
      ),
      child: MaterialButton(
        onPressed: () {
          if (!_nameFormKey.currentState.validate()) {
            return "";
          }
          _nameFormKey.currentState.save();
          changeName(_nameFormData);
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Хадгалах",
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

  _buildNameDialog(Function changeName) {
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
              "Нэрээ өөрчлөх",
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
                key: _nameFormKey,
                child: TextFormField(
                  onSaved: (String value) => _nameFormData = value,
                  validator: (String value) {
                    if (value.length == 0) {
                      return "Та нэрээ оруулаад үргэлжлүүлнэ үү";
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
                    hintText: "Нэрээ харуулах",
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
                _buildSaveButton(changeName),
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
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        return GestureDetector(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: deviceTheme == "light"
                    ? Theme.of(context).accentColor
                    : Colors.grey[900],
                pinned: false,
                floating: false,
                expandedHeight: 200.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 40),
                    child: SafeArea(
                      bottom: false,
                      top: true,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Тохиргоо",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  MdiIcons.logout,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  await GoogleSignIn().signOut();
                                  await FirebaseAuth.instance.signOut();
                                  model.logoutUser();
                                  restartApp();
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  child: model.authenticatedUser.photoUrl !=
                                          null
                                      ? CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              model.authenticatedUser.photoUrl),
                                        )
                                      : CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.blue[700],
                                          foregroundColor: Colors.white,
                                          child: Text(model.authenticatedUser
                                              .displayName[0]),
                                        ),
                                  width: 50.0,
                                  height: 50.0,
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: new BoxDecoration(
                                    color:
                                        const Color(0xFFFFFFFF), // border color
                                    shape: BoxShape.circle,
                                  )),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      print("Дарна уу");
                                    },
                                    child: Text(
                                      model.authenticatedUser != null &&
                                              model.authenticatedUser
                                                      .displayName !=
                                                  null
                                          ? model.authenticatedUser.displayName
                                          : "Нэр нэмэх",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    model.authenticatedUser.email,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.only(left: 7),
                          child: Text(
                            "Хэрэглэгчийн тохиргоо",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      color: deviceTheme == "light"
                          ? Theme.of(context).accentColor
                          : Colors.grey[900],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text("Хэрэглэгчийн нэр"),
                        subtitle: Text(model.authenticatedUser.displayName),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  _buildNameDialog(model.changeUserName),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text("Нууц үг сэргээх"),
                        trailing: IconButton(
                          icon: Icon(MdiIcons.restore),
                          onPressed: () async {
                            FirebaseUser user =
                                await FirebaseAuth.instance.currentUser();
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: user.email);
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Нууц үг имейл рүү илгээсэн."),
                                backgroundColor: deviceTheme == "light"
                                    ? Colors.blueAccent
                                    : Colors.blue[800],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Text(
                            "Харуулах",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      color: deviceTheme == "light"
                          ? Theme.of(context).accentColor
                          : Colors.grey[900],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        onChanged: (bool value) async {
                          if (!value) {
                            model.updateTheme("light");
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            await pref.setString("theme", "light");
                            restartApp();
                          } else {
                            model.updateTheme("dark");
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            await pref.setString("theme", "dark");
                            restartApp();
                          }
                        },
                        value: darkThemeVal,
                        title: Text("Харанхуй"),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Text(
                            "Тохиргоо",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      color: deviceTheme == "light"
                          ? Theme.of(context).accentColor
                          : Colors.grey[900],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text("Мөнгөн тэмдэгт"),
                        subtitle: Text(model.userCurrency != null
                            ? model.userCurrency
                            : "Тохиргоог шалгаж байна"),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: model.userCurrency == null
                              ? null
                              : () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: 200,
                                        child: ListView(
                                          children: <Widget>[
                                            RadioListTile(
                                              groupValue: model.userCurrency,
                                              value: "£",
                                              title: Text("Pounds (£)"),
                                              activeColor:
                                                  Theme.of(context).accentColor,
                                              onChanged: (String value) {
                                                model.updateCurrency(value);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            RadioListTile(
                                              groupValue: model.userCurrency,
                                              value: "\$",
                                              title: Text("Dollars (\$)"),
                                              activeColor:
                                                  Theme.of(context).accentColor,
                                              onChanged: (String value) {
                                                model.updateCurrency(value);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            RadioListTile(
                                              groupValue: model.userCurrency,
                                              value: "€",
                                              title: Text("Euros (€)"),
                                              activeColor:
                                                  Theme.of(context).accentColor,
                                              onChanged: (String value) {
                                                model.updateCurrency(value);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Text(
                            "Manage Your Data",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      color: deviceTheme == "light"
                          ? Theme.of(context).accentColor
                          : Colors.grey[900],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text("Бүх зарлагыг арилгах"),
                        subtitle: model.allExpenses.length == 0
                            ? Text("Зарлага олдсонгүй.")
                            : Text("Энэ үйлдэл нь буцах боломжгүй гэдгийг анхаарна уу."),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: model.allExpenses.length == 0
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Бүх зарлагыг устгах"),
                                        content: Text(
                                            "Та бүх зарлагыг устгахдаа итгэлтэй байна уу энэ үйлдэл нь буцаагдах боломжгүй гэдгийг анхааруулья"),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text(
                                              "Бүгдийг устгах",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              model.clearExpenses();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          FlatButton(
                                            child: Text("Цуцлах"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text("Бүх зарлагыг backup хийх"),
                        subtitle: model.allExpenses.length == 0
                            ? Text("зарлага олдсонгүй.")
                            : Text("зарлагыг local д хадгалах."),
                        trailing: IconButton(
                          icon: Icon(Icons.save),
                          onPressed: model.allExpenses.length == 0
                              ? null
                              : () {
                                  model.backupExpenses();
                                },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3.0),
                      color: deviceTheme == "light"
                          ? Colors.white
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text("Бүх зарлагыг сэргээх"),
                        subtitle: model.allExpenses.length == 0
                            ? Text("зарлага олдсонгүй.")
                            : Text("файлаас сэргээх."),
                        trailing: IconButton(
                          icon: Icon(Icons.restore),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Сэргээх"),
                                  content: Text(
                                      "Буцах боломжгүй гэдгийг анхаарна уу"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Сэргээх",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        model.restoreExpense();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("Цуцлах"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    ;
  }
}
