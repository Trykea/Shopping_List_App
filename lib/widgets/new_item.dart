import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Add new Item'),
      ),
      body: Padding(
        padding:const EdgeInsets.all(14),
        child: Form(child: Column(
          children: [
              TextFormField(
                maxLength: 50,
                decoration:const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  return 'err';
                },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration:const InputDecoration(
                      label: Text('Quantity'),
                    ),
                    initialValue: '1',
                  ),
                ),
                SizedBox(width: 24,),
                Expanded(
                  child: DropdownButtonFormField(items: [
                    for (final category in categories.entries)
                      DropdownMenuItem(
                          value: category.value,
                          child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: category.value.color,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(category.value.title),
                        ],
                      ))
                  ], onChanged: (value) {}),
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
