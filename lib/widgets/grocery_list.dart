import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'flutter-prep-f2f33-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');
    final respone = await http.get(url);
    if (respone.statusCode >=400) {
      setState(() {
        _error = 'Something went wrong, please try again';
      });
    }
    if (respone.body == 'null') {
      setState(() {
      _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listdata =
    json.decode(respone.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listdata.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });

  }

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
    _loadItem();
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'flutter-prep-f2f33-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${item.id}.json');
    final response =  await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            child: Image.network(
              'https://cdn4.iconfinder.com/data/icons/office-vol-1-11/16/clipboard-empty-list-shipping-512.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Failed to load image');
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const Text(
            'You have no item 💤💤',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator(),);
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) =>
              Dismissible(
                  key: ValueKey(
                    _groceryItems[index].id,
                  ),
                  onDismissed: (direction) {
                    _removeItem(_groceryItems[index]);
                  },
                  child: ListTile(
                    title: Text(_groceryItems[index].name),
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: _groceryItems[index].category.color,
                    ),
                    trailing: Text(_groceryItems[index].quantity.toString()),
                  )));
    }
    if (_error !=null) {
      content = Center(child: Text(_error!),);


    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }
}
