import 'package:flutter/material.dart';

// firebase
import '../firebase/firestore_methods.dart';

// models
import '../models/call.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _friendUsernamectrler = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _friendUsernamectrler.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/profile");
                    },
                    icon: const Icon(Icons.person),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) => Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: _friendUsernamectrler,
                                      decoration: const InputDecoration(hintText: "Friend username"),
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await FirestoreMethods.getInstance().addFriend(_friendUsernamectrler.text);
                                          setState(() {});
                                        },
                                        child: const Text("Add"))
                                  ],
                                ),
                              ));
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Friends"),
            Expanded(
              child: FutureBuilder(
                  future: FirestoreMethods.getInstance().getFriends(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () {
                        setState(() {});
                        return Future(() => null);
                      },
                      child: ListView.separated(
                        separatorBuilder: (ctx, i) => const SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (ctx, index) => Card(
                          
                          child: Padding(                          
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(snapshot.data![index].coverUrl),
                              ),
                              title: Text(snapshot.data![index].username),
                              trailing: SizedBox(
                                width: 110,
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () async {
                                        final user = await FirestoreMethods.getInstance().getCurrentUser();
                                        FirestoreMethods.getInstance().makeCall(
                                          Call.audio(
                                            callerId: user!.uid,
                                            callerAva: user.coverUrl,
                                            callerName: user.username,
                                            receiverId: snapshot.data![index].uid,
                                            receiverAva: snapshot.data![index].coverUrl,
                                            receiverName: snapshot.data![index].username,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.call,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final user = await FirestoreMethods.getInstance().getCurrentUser();
                                        FirestoreMethods.getInstance().makeCall(
                                          Call.video(
                                            callerId: user!.uid,
                                            callerAva: user.coverUrl,
                                            callerName: user.username,
                                            receiverId: snapshot.data![index].uid,
                                            receiverAva: snapshot.data![index].coverUrl,
                                            receiverName: snapshot.data![index].username,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.videocam_rounded,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        itemCount: snapshot.data!.length,
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
