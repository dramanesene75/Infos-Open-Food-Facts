import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'BarCode.dart';

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
  final bool found;

  Post({this.genericName, this.ingredients, this.allergens, this.traces,this.productName,this.nutritionGrade,this.labels,this.brands,this.origins,this.found});

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

// Define a custom Form widget.
class ProductDetails extends StatefulWidget {
  @override
  _ProductDetailsFormState createState() => _ProductDetailsFormState();
}

class _ProductDetailsFormState extends State<ProductDetails> {
  bool _allData = false;
  double _height = 480;

  @override
  Widget build(BuildContext context) {
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
                  return
                    Column(
                      children: <Widget>[
                        Image.asset('images/cristalline.jpg',width : 600,height: _height,fit: BoxFit.cover),
                        Row(
                          children: <Widget>[
                            Text("INFORMATIONS DU PRODUIT",
                                style: TextStyle(color: Colors.blueAccent, fontSize: 22)
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 46.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _allData = !_allData;

                                      if(_allData){
                                        _height = 50;
                                      }
                                      else{
                                        _height = 480;
                                      }
                                    });
                                  },
                                  child: Icon(_allData ? Icons.arrow_downward: Icons.arrow_upward),
                                ),

                            ),
                          ],
                        )
                        ,


                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Nom du produit", style: TextStyle(
                                  fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 26.0),
                                  child: Text(snapshot.data.productName)
                              ),
                            ],
                          ),
                        ),

                         ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Nutrition", style: TextStyle(
                                  fontWeight: FontWeight.bold),
                              ),
                           Padding(
                             padding: EdgeInsets.only(left: 73.0),
                             child:Text(snapshot.data.nutritionGrade.toUpperCase()),
                           ),
                            ],
                          ),
                        ),ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Ingrédients", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 54.0),
                            child:Text(snapshot.data.ingredients),
                          ),                        ],
                      ),

                    ),

                ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Nom générique", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child:Text(snapshot.data.genericName),
                          ),
                        ],
                      ),
                    ),ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Marque", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 81.0),
                            child:Text(snapshot.data.brands),
                          ),
                        ],
                      ),
                    ),ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Origine", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 84.0),
                            child:Text(snapshot.data.origins),
                          ),
                        ],
                      ),
                    ),ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Labels", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 90.0),
                            child:Text(snapshot.data.labels),
                          ),
                        ],
                      ),
                    ),ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Traces", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 88.0),
                            child:Text(snapshot.data.traces),
                          ),
                        ],
                      ),
                    ),ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Allergenes", style: TextStyle(
                              fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 58.0),
                            child:Text(snapshot.data.allergens),
                          ),
                        ],
                      ),
                    ),

                      ],
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