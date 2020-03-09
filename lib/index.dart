import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:binalyto_hrm/login.dart';

class IndexPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() =>_indexPageState();

}


enum FormType {
  login,
  register
}


class _indexPageState  extends State<IndexPage> {

  String data = "";
  String name_str;
  TextEditingController controller = TextEditingController();
  Future<SharedPreferences> pref=SharedPreferences.getInstance();

  Future<void> main() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    print(status);
    runApp(MaterialApp(home: status == true ? Loginpage() : IndexPage()));

  }


//  Future<String> getName() async{
//    SharedPreferences prefs=await SharedPreferences.getInstance();
//    name_str=prefs.getString('full_name');
//
//
//    return name_str;
//  }



  final _formKey = GlobalKey<FormState>();
  FormType _form = FormType.login;

  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: _buildBar(),
      drawer:_buidSideBar(),

      body: new Center(
        child: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(20.0),
            child: Center(
              child: new Form(
                key: _formKey,
                child: new Column(
                  children: <Widget>[
                    TextField(
                      obscureText: getText(),
                    ),
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



  @override
  Widget _buidSideBar() {
    return new Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: _setLogout,
          ),
        ],
      ),

    );
  }



  @override
  Widget _Textfied(String name){
    return Text(
      'Employee name',
    );

  }


  getText() async{
    SharedPreferences pre=await SharedPreferences.getInstance();
    name_str=pre.getString('full_name');
    print("++++++++++++");
    return name_str;
  }





  Widget _buildBar() {
    return new AppBar(
      title: new Text("Login to Binlyto_HRM"),
      centerTitle: true,
    );
  }


  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[

            const SizedBox(height: 50),
          new RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),

                ),
                padding : EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
                color: Colors.lightBlueAccent,
                child: new Text('Check In',style: TextStyle(fontWeight: FontWeight.bold),),
                textColor:Colors.white,
                onPressed: _checkinPressed,
              ),
            const SizedBox(height: 30),
            new RaisedButton(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),

              ),
              padding : EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),

              color: Colors.lightBlueAccent,
              child: new Text('Check Out',style: TextStyle(fontWeight: FontWeight.bold)),
              textColor:Colors.white,
              onPressed: _checkoutPressed,
            ),
          ],
        ),
      );
    }
  }

  void _checkinPressed() {
    if (_formKey.currentState.validate()) {
      final type="IN";
      _makeGetRequest(type);

    }
  }
  void _checkoutPressed(){
    final type="OUT";
    _makeGetRequest(type);
    if(_formKey.currentState.validate()){

    }
  }



  void _makeGetRequest(String type) async {
    var now = new DateTime.now(); // Generate time
    SharedPreferences prefs = await SharedPreferences.getInstance(); //Load shared prefs
    String sid = prefs.getString('ERP_sid');

    Map<String, String> header = {"Cookie": "sid=$sid", "Accept": "application/json","Content-Type": "application/json"}; // Prepare header
    String url = 'http://irtc.binalyto.com/api/resource/Employee Checkin'; //Target
    String rqstBody = '{"time":"$now", "log_type": "$type"}'; //body. Employee ID will be picked automatically by server.

    //Make post request
    var response = await http.post(url, headers: header, body: rqstBody.toString());

    //Let's validate response
    int statusCode = response.statusCode; //Return status code.
    if(statusCode == 200) {
      print("Success");// Do success things
    } else {
      print(response.body.toString()); // Manage Errors here.
    }

  }

  static  currentTimeInSeconds() {
    var ms = (new DateTime.now());
//    final tm=ms;
    return ms;
  }

 void _setLogout() async {

   SharedPreferences prefs = await SharedPreferences.getInstance();
   prefs?.clear();// Clear preferences
   Navigator.pushReplacement(context,
     MaterialPageRoute(builder: (BuildContext context) => Loginpage()),

   );
 }



}




