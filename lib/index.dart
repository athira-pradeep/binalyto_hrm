import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:binalyto_hrm/login.dart';




class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_indexPageState();

}


enum FormType {
  login,
  register
}


class _indexPageState  extends State<IndexPage> {

  Future<String>getData() async{

    print("++++++++++++++");
    String url = 'http://irtc.binalyto.com/api/resource/Employee';
    Map<String,String> headers = {'Content-Type':'application/x-www-form-urlencoded', "Accept":"application/json"};
    Response response= await get(url,headers: headers);
    print(response.body);
//    rest=await SharedPreferences.getInstance();


//    String url = 'http://irtc.binalyto.com/api/resource/Employee';
//    Response response=await get(url);
//    String json=response.body;
//    int scode=response.statusCode;
//    print(scode);
//    print(json);


}



  final _formKey = GlobalKey<FormState>();
  FormType _form = FormType.login;


  @override
  void initialState(){
    this.getData();
  }

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
  Widget build(BuildContext context) {
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
                    Text(
                      'Employee Name',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),
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
  Widget _buidSideBar(){
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
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: _setLogout,
//            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),

    );
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
      final type="in";
      _makeGetRequest(type);

    }
  }
  void _checkoutPressed(){
    final type="out";
    _makeGetRequest(type);
    if(_formKey.currentState.validate()){

    }
  }



  void _makeGetRequest(String type) async {

    initialState();
    final emprefs = await SharedPreferences.getInstance();
    final empname = emprefs.getString('employee');
    print(empname);
    var _employee="EMP-CKIN-03-2020-000001";
    var _logtype="IN";
//    var _Time=currentTimeInSeconds();
//    print(_Time);
//    var _time=jsonEncode(_Time);
    if(type=="in"){

      Map<String,String> json ={
        "log_type":"IN"
      };

      final msg = jsonEncode(json);

      String url = 'http://irtc.binalyto.com/api/resource/Employee Checkin';
      Map<String,String> headers = {'Content-Type':'application/x-www-form-urlencoded', "Accept":"application/json"};
//      final msg = jsonEncode({"full_name":_employee,"time":"05-03-2020T11:09:05","log_type":_logtype});
//
//      var response = await post(url,
//        headers: headers,
//        body: msg,
//      );
      Response response = await post(url, headers: headers, body: msg);
      int statusCode = response.statusCode;
      print(statusCode);
      String b1 = response.body;
      print(b1);




//      Response response = await post(url,body: {"employee":_employee,"time":_time,"log_type":_logtype},headers: {"Content-Type":"appliction/x-www-form-urlencoded"});
//      int statusCode = response.statusCode;
//      Map<String, String> headers = response.headers;
//      String contentType = headers['content-type'];
//      String json = response.body;
//
//      print("***************************");
//
//      print(json);
//      var data = jsonDecode(response.body);

    }
    else{
      String url = 'http://irtc.binalyto.com/api/resource/Employee Checkin';
      var _Time=currentTimeInSeconds();
      print(_Time);

      Response response = await post(url,body:{"employee":"EMP-CKIN-03-2020-000001","time":"2018-03-29T16:40:00.000","log_type":"OUT"},headers: {"Accept":"application/json"});
      int statusCode = response.statusCode;
      Map<String, String> headers = response.headers;
      String contentType = headers['content-type'];
      String json = response.body;
      print(json);
      var data = jsonDecode(response.body);



    }

  }

  static  currentTimeInSeconds() {
    var ms = (new DateTime.now());
//    final tm=ms;
    return ms;
  }

 void _setLogout() async{
   final prefs=await SharedPreferences.getInstance();
   prefs.remove('rest');
    print('test');
    print(prefs.getInt('rest'));
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Loginpage()));


 }



}




