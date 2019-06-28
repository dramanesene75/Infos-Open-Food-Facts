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
      productName: json ['status'] ==1&& json['product']['product_name'] != '' ?json['product']['product_name']:'',
      ingredients: json ['status']==1 && json['product']['ingredients_text'] != '' ? json['product']['ingredients_text']:'Ingredients Unknown',
      allergens: json ['status']==1 && json['product']['allergens'] != '' ? json['product']['allergens']:'No allergens',
      traces:  json ['status']==1 && json['product']['traces'] != '' ? json['product']['traces'] : 'No traces',
      genericName: json ['status'] ==1&& json['product']['generic_name'] != '' ? json['product']['generic_name'] : '',
      nutritionGrade:  json ['status'] ==1?"Notation : ${json['product']['nutrition_grades']}":"Grade Unkwonwn",
      labels:  json ['status']==1 &&json['product']['labels'] != '' ? json['product']['labels']:'No labels',
      brands:  json ['status']==1 &&json['product']['brands'] != '' ? json['product']['brands']:'Brands Unknown',
      origins: json ['status']==1 && json['product']['origins']!= '' ?json['product']['origins']:'Origin Unknows',
      found : json ['status'] == 1

    );
  }

  factory Post.fromJsonByName(Map<String, dynamic> json) {
    if (json['products'].isNotEmpty){
    return Post(
        productName: json['products'][0]['product_name'] != '' ?json['products'][0]['product_name']:'',
        ingredients: json['products'][0]['ingredients_text'] != '' ? json['products'][0]['ingredients_text']:'Ingredients Unknown',
        allergens:json['products'][0]['allergens'] != '' ? json['products'][0]['allergens']:'No allergens',
        traces:  json['products'][0]['traces'] != '' ? json['products'][0]['traces'] : 'No traces',
        genericName: json['products'][0]['generic_name'] != '' ? json['products'][0]['generic_name'] : '',
        nutritionGrade:  "Notation : ${json['products'][0]['nutrition_grades']}",
        labels:  json['products'][0]['labels'] != '' ? json['products'][0]['labels']:'No labels',
        brands:  json['products'][0]['brands'] != '' ? json['products'][0]['brands']:'Brand Unknwown',
        origins:json['products'][0]['origins']!= '' ?json['products'][0]['origins']:'Origin Unknwon',
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

class ProductDetails extends StatelessWidget {


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
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: Center(
          child: FutureBuilder<Post>(
            future: post,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data.found) {
                  return
                    ListView(
                      children: <Widget>[
                        ListTile(
                          title: Text(snapshot.data.productName),
                        ), ListTile(
                          title: Text(snapshot.data.nutritionGrade),
                        ),
                        ListTile(
                          title: Text(snapshot.data.genericName),
                        ),
                        ListTile(
                          title: Text(snapshot.data.allergens),
                        ), ListTile(
                          title: Text(snapshot.data.traces),
                        ), ListTile(
                          title: Text(snapshot.data.labels),
                        ), ListTile(
                          title: Text(snapshot.data.brands),
                        ), ListTile(
                          title: Text(snapshot.data.origins),
                        ), ListTile(
                          title: Text(snapshot.data.ingredients),
                        )
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