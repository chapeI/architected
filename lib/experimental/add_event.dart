import 'package:flutter/material.dart';

class AddEvent extends StatefulWidget {
  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  var event = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: event
            ? AppBar(
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_time)),
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.add_location_alt)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.check)),
                  PopupMenuButton(
                      itemBuilder: (context) => [
                            PopupMenuItem(child: Text('+ friend')),
                            PopupMenuItem(child: Text('+ confirms')),
                            PopupMenuItem(
                                child: Text('cancel'),
                                onTap: () {
                                  setState(() {
                                    event = !event;
                                  });
                                }),
                          ]),
                ],
                title: (Text('event name')),
              )
            : null,
        actions: [
          event
              ? Container()
              : IconButton(
                  onPressed: () {
                    setState(() {
                      event = !event;
                    });
                  },
                  icon: Icon(Icons.add)),
        ],
        title: Text('friends name'),
      ),
    );
  }
}
