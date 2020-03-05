import 'dart:io';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:binalyto_hrm/index.dart';
import 'package:http/http.dart';
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




  void _makeGetRequest() async {
//     make POST request
    print("makeGETREnsdjsbcj");
    String url = 'http://irtc.binalyto.com/api/method/login';
    Response response = await post(url,body: {"usr":_email, "pwd":_password});
    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers =response.headers;
    print(headers);
    String contentType = headers['content-type'];

//    String rawCookie = response.headers['set-cookie'];
//    var index=rawCookie.split(';');
//    var ind=index[4];
//    var Sid=ind.split(',');
//    var SID=Sid[1].split('=');
//    var orsid=SID[1];
//    print(orsid);
//    print(contentType);
//    print(rawCookie);
    String json = response.body;

    var data = jsonDecode(response.body);
    print(json);

    print(data["full_name"]);
    var rest = data["message"];
    if(rest=="Logged In"){
      print("############");
      rest=1;
    }
    else{
      rest=0;
    }
    print(rest);

//    final sidprefs=await SharedPreferences.getInstance();
//    sidprefs.setString('sid', orsid);

    final prefs=await SharedPreferences.getInstance();
    prefs.setInt('rest',rest);
    var emp=data["full_name"];
    final emprefs=await SharedPreferences.getInstance();
    emprefs.setString("employee",emp );

    if(rest == 1) {
      if(prefs.getInt('rest')==1){
        print("testSharedPreferences");
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => IndexPage()),

        );

      }

    }
    else
    {
      AlertDialog(title: Text("Incorrect Username or password"));
      Navigator.push(context,
        MaterialPageRoute(builder: (context)=>Loginpage()),
      );

    }


    }





  }

