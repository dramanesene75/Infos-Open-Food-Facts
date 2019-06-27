import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'BarCode.dart';

Future<Post> fetchPost(code) async {
  final response =
  await http.get('https://fr.openfoodfacts.org/api/v0/produit/'+code + '.json');

  if (response.statusCode == 200) {
    return Post.fromJson(json.decode(response.body));
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

  Post({this.genericName, this.ingredients, this.allergens, this.traces,this.productName,this.nutritionGrade,this.labels,this.brands,this.origins});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      productName: "Product Name : ${json['product']['product_name']}",
      ingredients: json['product']['ingredients_text'] != null ? json['product']['ingredients_text']:'',
      allergens: json['product']['allergens'] != null ? json['product']['allergens']:'',
      traces: json['product']['traces'] != null ? json['product']['traces'] : '',
      genericName: json['product']['generic_name'] != null ? json['product']['generic_name'] : '',
      nutritionGrade: "Notation : ${json['product']['nutrition_grades']}",
      labels: json['product']['labels'] != null ? json['product']['labels']:'',
      brands: json['product']['brands'] != null ? json['product']['brands']:'',
      origins: json['product']['origins']!= null ?json['product']['origins']:'',

    );
  }
}

class ProductDetails extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final barCode = Provider.of<BarCode>(context);
    String product = barCode.getBarCode();
    print(product);
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