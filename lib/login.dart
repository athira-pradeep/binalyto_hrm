import 'dart:io';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:binalyto_hrm/index.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';



class Loginpage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_newLoginState();

}


enum FormType {
  login,
  register
}

class _newLoginState extends State<Loginpage>{




  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _email = "";
  String _password = "";
  FormType _form = FormType.login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _newLoginState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }


  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }
//
  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange () async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();

  }

  void startTimer() {
    Timer(Duration(seconds: 50), () {
      navigateUser(); //It will redirect  after 3 seconds
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(),
      body: new Center(
        child: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(20.0),
            child: Center(
              child:new Form(
                key: _formKey,
                child: new Column(
                  children: <Widget>[
                    _buildTextFields(context),
                    _buildButtons(),
                  ],
                ),

              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar() {
    return new AppBar(
      title: new Text("Login to Binlyto_HRM"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            padding: EdgeInsets.all(17.0),
            child: new TextFormField(
              validator: (value){
                if(value.isEmpty){
                  return "Please enter your email address";
                }
                return null;
              },
              controller: _emailFilter,
              decoration: new InputDecoration(
                  hintText: 'Email',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
              ),
            ),
          ),
          new Container(
            padding: EdgeInsets.all(17.0),
            child: new TextFormField(
              validator: (value){
                if(value.isEmpty){
                  return "Please enter password";
                }
              },
              controller: _passwordFilter,
              decoration: new InputDecoration(
                hintText: 'Password',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.all(12),
              color: Colors.lightBlueAccent,
              child: new Text('Login'),
              onPressed: _loginPressed,
            ),
            new FlatButton(
              child: new Text('Dont have an account? Tap here to register.'),
              onPressed: _formChange,
            ),
            new FlatButton(
              child: new Text('Forgot Password?'),
              onPressed: _passwordReset,
            )
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Create an Account'),
              onPressed: _createAccountPressed,
            ),
            new FlatButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  void _loginPressed () {

    if (_formKey.currentState.validate()) {
      _makeGetRequest();

    }


    print('The user wants to login with $_email and $_password');

  }

  void _createAccountPressed () {
    print('The user wants to create an accoutn with $_email and $_password');

  }

  void _passwordReset () {
    print("The user wants a password reset request sent to $_email");
  }


  void navigateUser() async{ // Login validation
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    print(status);
    if (status) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => IndexPage()),

      );

    } else {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => Loginpage()),

      );
      ;
    }
  }


  void _makeGetRequest() async {
//     make POST request
    Map<String, String> header = {"Accept": "application/json","Content-Type": "application/json"};
    String url = 'http://irtc.binalyto.com/api/method/login';
    String rqstBody = '{"usr":"$_email", "pwd":"$_password"}';

    //Make post request
    var response = await http.post(url, headers: header, body: rqstBody);

    //Let's validate response
    int statusCode = response.statusCode; //Return status code.

    print(statusCode);
      if(statusCode == 200) {// If login is success.

          SharedPreferences pref = await SharedPreferences.getInstance();
          pref?.setBool("isLoggedIn", true);
          print(response.headers);
          String sid = response.headers['set-cookie'].split(',')[4].split(';')[0].split('=')[1].toString(); //Split header to get sid
          String full_name = jsonDecode(response.body)["full_name"];
          SharedPreferences prefs = await SharedPreferences.getInstance(); //Load shared preferences to store session data
          await prefs.setInt('ERP_status', 1);
          await prefs.setString("ERP_sid", sid);
          await prefs.setString("full_name", full_name);
          print(prefs.getInt('ERP_status'));
          if(prefs.getInt('ERP_status')==1){
            //Navigate to Next page
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => IndexPage()),

            );


          }

        }

      else { //if not succeeded
        return showDialog<void>(//Load DialogBox
          context: context,
          builder: (BuildContext context) {
            return AlertDialog( // Load AlertDialoge
              content: const Text('Incorrect username or password'),
              actions: <Widget>[
                FlatButton( //FlatButton
                  child: Text('Ok'),
                  onPressed: () {//Press ok ,Navigate to Login page
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Loginpage()),

                    );
                  },
                ),
              ],
            );
          },
        );
      }

    }

}

