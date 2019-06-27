import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ProductDetails.dart';
import 'BarCode.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enter BarCode',
      home:  MyCustomForm(),

    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter BarCode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: myController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) {

                  return Scaffold(
                  body: ChangeNotifierProvider<BarCode>(
                      builder: (_) => BarCode(myController.text),
                  child: ProductDetails(),
                  )
                  );
                },
              )
      );
    },
        child: Icon(Icons.text_fields),
      ),
    );
  }
}

