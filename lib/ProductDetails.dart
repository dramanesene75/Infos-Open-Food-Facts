import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'BarCode.dart';
import 'WaveClipper.dart';
import "WaveArrow.dart";
Future<Post> fetchPost(response) async {
  if(int.tryParse(response) !=null) {
    return fetchPostByBarCode(response);
  }
  else {
    return fetchPostByName(response);
  }
}

Future<Post> fetchPostByBarCode(code) async {
  final response =
  await http.get('https://fr.openfoodfacts.org/api/v0/produit/'+code + '.json');

  if (response.statusCode == 200) {
    return Post.fromJsonByBarCode(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<Post> fetchPostByName(name) async {
  final response =
  await http.get('https://world.openfoodfacts.org/cgi/search.pl?search_terms='+name+'&search_simple=1&action=process&json=1');
  if (response.statusCode == 200) {
    return Post.fromJsonByName(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}
class Post {
  final String genericName;
  final String ingredients;
  final String allergens;
  final String traces;
  final String productName;
  final String nutritionGrade;
  final String labels;
  final String brands;
  final String origins;
  final String picture;
  final bool found;

  Post({this.genericName, this.ingredients, this.allergens, this.traces,this.productName,this.nutritionGrade,this.labels,this.brands,this.origins,this.found, this.picture});

  factory Post.fromJsonByBarCode(Map<String, dynamic> json) {
    return Post(
      productName: json ['status'] ==1&& json['product']['product_name'] != '' ?json['product']['product_name']:'-',
      ingredients: json ['status']==1 && json['product']['ingredients_text'] != '' ? json['product']['ingredients_text']:'-',
      allergens: json ['status']==1 && json['product']['allergens'] != '' ? json['product']['allergens']:'-',
      traces:  json ['status']==1 && json['product']['traces'] != '' ? json['product']['traces'] : '-',
      genericName: json ['status'] ==1&& json['product']['generic_name'] != '' ? json['product']['generic_name'] : '-',
      nutritionGrade:  json ['status'] ==1?  json['product']['nutrition_grades']:"-",
      labels:  json ['status']==1 &&json['product']['labels'] != '' ? json['product']['labels']:'-',
      brands:  json ['status']==1 &&json['product']['brands'] != '' ? json['product']['brands']:'-',
      origins: json ['status']==1 && json['product']['origins']!= '' ?json['product']['origins']:'-',
      picture : json ['status']==1 && json['product']['image_url']!= '' ?json['product']['image_url']:'',
      found : json ['status'] == 1

    );
  }

  factory Post.fromJsonByName(Map<String, dynamic> json) {
    if (json['products'].isNotEmpty){
    return Post(
        productName: json['products'][0]['product_name'] != '' ?json['products'][0]['product_name']:'-',
        ingredients: json['products'][0]['ingredients_text'] != '' ? json['products'][0]['ingredients_text']:'-',
        allergens:json['products'][0]['allergens'] != '' ? json['products'][0]['allergens']:'-',
        traces:  json['products'][0]['traces'] != '' ? json['products'][0]['traces'] : '-',
        genericName: json['products'][0]['generic_name'] != '' ? json['products'][0]['generic_name'] : '-',
        nutritionGrade:  json['products'][0]['nutrition_grades'] != '' ? json['products'][0]['nutrition_grades'] : '-',
        labels:  json['products'][0]['labels'] != '' ? json['products'][0]['labels']:'-',
        brands:  json['products'][0]['brands'] != '' ? json['products'][0]['brands']:'-',
        origins:json['products'][0]['origins']!= '' ?json['products'][0]['origins']:'-',
        picture : json['products'][0]['image_url'],
        found : true

    );
  }
  else {
    return Post(
        productName: '',
        ingredients: '',
        allergens:'',
        traces:'',
        genericName:  '',
        nutritionGrade:  '',
        labels:  '',
        brands:  '',
        origins:'',
        found : false
    );
    }
    }
}

class ProductDetails extends StatefulWidget {
  @override
  _ProductDetailsFormState createState() => _ProductDetailsFormState();
}

class _ProductDetailsFormState extends State<ProductDetails> {

  bool _allData = false;
  double _height = 510;
  double _positionText = 0.85;
  double _positionArrow = 0.93;
  int index = 0;
  MediaQueryData queryData;
  DragStartDetails startHorizontalDragDetails;
  DragUpdateDetails updateHorizontalDragDetails;

  @override
  Widget build(BuildContext context) {
    List pictures = [];
    pictures.add('https://m-naturellement.com/98-large_default/eau-cristalline-50cl.jpg');
    double _widthScreen = MediaQuery.of(context).size.width;
    double _heightScreen = MediaQuery.of(context).size.height;
    double _width = _widthScreen;

    final barCode = Provider.of<BarCode>(context);
    String product = barCode.getBarCode();
    final Future<Post> post = fetchPost(product) ;
    return MaterialApp(
      title: 'Product Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(

        body: Center(
          child: FutureBuilder<Post>(
            future: post,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data.found) {
                  pictures.add(snapshot.data.picture);
                  return
                    AnimatedContainer(
                      duration:Duration(milliseconds:1000),
                      decoration: new BoxDecoration(color: Colors.grey[300]) ,
                      child:
                      GestureDetector(
                        onHorizontalDragStart: (DragStartDetails details) {
                          startHorizontalDragDetails = details;
                        },
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          updateHorizontalDragDetails = details;
                        },

                        onHorizontalDragEnd : (dragDetails) {
                          if (updateHorizontalDragDetails.globalPosition.dx >
                              startHorizontalDragDetails.globalPosition.dx) {
                            setState(() {
                              index = 0;
                            });
                          }
                          else {
                            setState(() {
                              index = 1;
                            });
                          }
                          double dy= updateHorizontalDragDetails.globalPosition.dy -
                              startHorizontalDragDetails.globalPosition.dy;
                          print(dy);
                          setState(() {
                            if(dy < 0 ) {
                              _allData = true;
                              _height = 0.25*_heightScreen;
                              _positionText=0.55;
                              _positionArrow=0.75;
                            }
                            else{
                              _allData = false;

                              _height = 0.75*_heightScreen;
                              _positionText=0.85;
                              _positionArrow=0.93;
                            }

                          });

                        },

                        child: Column(
                        children: <Widget>[

                          Stack(
                            children: <Widget>[
                        ClipPath(
                          child : Container(
                            decoration: new BoxDecoration(color: Colors.white) ,
                            child: ClipPath(
                        child:
                              AnimatedContainer(
                                duration:Duration(milliseconds: 1000),
                                width : _width,
                                height: _height,
                                child:  snapshot.data.picture != ''
                                    ? Image.network(
                                    pictures[index],fit: BoxFit.cover)
                                    : Image.asset('images/no-img.png'),
                            ),
                                clipper: WaveArrow(),
                                  ),
                          ),


                            clipper: WaveClipper(),
                                          ),

                            AnimatedContainer(
                                                            duration:Duration(milliseconds:1000),
                                                            height: _height,
                                                              width: _widthScreen,
                                                              child: Align(
                                                                alignment: Alignment(-.8,_positionText),
                                                                child: Text("INFORMATIONS",
                                                                  style: TextStyle(color: Color(0xFF00889B), fontSize: 22),
                                                                ),
                                                              ),
                                                            ),
                            AnimatedContainer(
                                                            duration:Duration(milliseconds:1000),
                                                            height: _height,
                                                            width: _widthScreen,
                                                            child: Align(
                                                              alignment: Alignment(-.83,0.95),
                                                              child: Text("DU PRODUIT",
                                                                style: TextStyle(color: Color(0xFF00889B), fontSize: 22),
                                                              ),
                                                            ),
                                                          ),
                            AnimatedContainer(
                                                              duration:Duration(milliseconds:1000),
                                                              height: _height,
                                                              width: _widthScreen,
                                                              child: Align(
                                                              alignment: Alignment(0.65,_positionArrow),
                                        child:GestureDetector(
                                                              onTap: () {
                                        setState(() {
                                        _allData = !_allData;
                                        if(_allData){
                                        _height = 0.25*_heightScreen;
                                        _positionText=0.55;
                                        _positionArrow=0.75;
                                        }
                                        else{
                                        _height = 0.75*_heightScreen;
                                        _positionText=0.85;
                                        _positionArrow=0.93;
                                        }
                                        });
                                        },
                                        child: Icon(_allData ? Icons.arrow_downward : Icons.arrow_upward, color: Color(0xFF00889B)),
                                        ),
                                                              ),
                                                            )
                                                  ],
                                                ),
                          AnimatedContainer(
                            duration:Duration(milliseconds:1000),
                            height: _heightScreen/15,
                            child: ListTile(
                              title: Stack(
                                children: [
                                  Text("Nom du produit", style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: _widthScreen/3),
                                      child: Text(snapshot.data.productName)
                                  ),
                                ],
                              ),
                            ),
                          ),
                           Container(
                             height: _heightScreen/15,
                             child: ListTile(
                              title: Stack(
                                children: [
                                  Text("Nutrition", style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                  ),
                               Padding(
                                 padding: EdgeInsets.only(left: _widthScreen/3),
                                 child:Image.asset('images/'+snapshot.data.nutritionGrade.toLowerCase()+'.png', width: 24,height: 24,),
                               ),
                                ],
                              ),
                          ),
                           ),
                           Container(
                             height: _heightScreen/15,
                             child: ListTile(
                               contentPadding : EdgeInsets.symmetric(horizontal:16, vertical: -28.0),

                               title: Stack(
                          children: [
                              Text(
                                "Ingrédients",
                                style: TextStyle(height : 0.5,fontWeight: FontWeight.bold, fontSize: 16.0),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: _widthScreen/3),
                                child: Text(
                                    snapshot.data.ingredients,
                                    maxLines: 3 ,
                                    style: TextStyle(fontSize: 16.0,                                  height : 0.5,
                                    )
                                ),
                              ),
                          ]
                          ),
                          ),
                           ),

                          _allData ?
                              Container(
                            height: _heightScreen/15,
                            child:
                            ListTile(
                        title: Stack(
                            children: [
                              Text("Nom générique", style: TextStyle(
                                  fontWeight: FontWeight.bold),
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: _widthScreen/3),
                                child:Text(snapshot.data.genericName),
                              ),
                            ],
                        ),
                      ),
              ):Container(),

                          _allData ?
                              Container(
                            height: _heightScreen/15,

                            child:ListTile(
                        title: Stack(
                          children: [
                            Text("Marque", style: TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _widthScreen/3),
                              child:Text(snapshot.data.brands),
                            ),
                          ],
                        ),
                      ),
                          ):Container(),
                          _allData ?
                              Container(
                                height: _heightScreen/15,
                                child:ListTile(
                        title: Stack(
                          children: [
                            Text("Origine", style: TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _widthScreen/3),
                              child:Text(snapshot.data.origins, overflow: TextOverflow.ellipsis,softWrap: true,),
                            ),
                          ],
                        ),
                      ),):Container(),
                          _allData ?
                              Container(
                            height: _heightScreen/15,

                            child:ListTile(
                        title: Stack(
                          children: [
                            Text("Labels", style: TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _widthScreen/3),
                              child:Text(snapshot.data.labels),
                            ),
                          ],
                        ),
                      ),):Container(),
                          _allData ?
                              Container(
                            height: _heightScreen/15,
                            child:ListTile(
                        title: Stack(
                          children: [
                            Text("Traces", style: TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _widthScreen/3),
                              child:Text(snapshot.data.traces),
                            ),
                          ],
                        ),
                      ),):Container(),
                          _allData ?ListTile(
                        title: Stack(

                          children: [
                            Text("Allergenes", style: TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left:_widthScreen/3),
                              child:Text(snapshot.data.allergens),
                            ),
                          ],
                        ),
                      ):Container(),

                        ],
                      ),
                    ),
                    );
                }
              else
                return Text("Product no found");
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}