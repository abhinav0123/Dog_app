import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(DogApp());
class DogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/history': (context) => HistoryPage(),
        '/cart': (context) => CartPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String imageUrl = '';

  Future<void> fetchDogImage() async {
    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        imageUrl = data['message'];
      });
      addToHistory(imageUrl);
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to fetch dog image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> addToHistory(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(imageUrl);
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              imageUrl,
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchDogImage,
              child: Text('Fetch New Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: Text('View History'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: Text('View Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  Future<List<String>> getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('history') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: FutureBuilder<List<String>>(
        future: getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final history = snapshot.data!;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Image ${index + 1}'),
                  leading: Image.network(
                    history[index],
                    height: 50,
                    width: 50,
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No history available.'),
            );
          }
        },
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];



  void addToCart(String Dogname, double price) {
    setState(() {
      cartItems.add(CartItem(Dogname: Dogname, price: price));
    });
  }

  double calculateTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                String Dogname='';
                return ListTile(
                  title: Text('Item ${index + 1}',


                  ),

                  trailing: Text('\$${cartItems[index].price.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: \$${calculateTotal().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a new item to the cart
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String Dogname = '';
              double price = 0.0;

              return AlertDialog(
                title: Text('Add to Cart'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(

                      decoration: InputDecoration(labelText: 'Dog name'),
                      onChanged: (name) {
                        Dogname = name ;
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        price = double.tryParse(value) ?? 0.0;
                      },
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      addToCart(Dogname, price);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}



class CartItem {
  final String Dogname;
  final double price;

  CartItem({required this.Dogname, required this.price});
}
