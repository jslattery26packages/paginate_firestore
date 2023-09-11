import 'package:example/firebase_options.dart';
import 'package:example/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/widgets/empty_separator.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

late CollectionReference<User> collection;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    UncontrolledProviderScope(
      container: ProviderContainer(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore pagination library',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(keepPage: true);
    final scrollConroller = useScrollController(keepScrollOffset: true);
    final type = useState<PaginateType>(PaginateType.gridView);
    final options = List<PaginateType>.from(PaginateType.values);
    List<DocumentSnapshot> saveAsYouLoad = [];
    //* For example we don't want to show the startAfter option
    options.remove(PaginateType.pageViewStartAfter);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore pagination example'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          DropdownButtonFormField<PaginateType>(
            value: type.value,
            items: options
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toString()),
                    ))
                .toList(),
            onChanged: (v) => type.value = v!,
          ),
          Expanded(
            child: PaginateFirestore(
              scrollController: scrollConroller,
              pageController: pageController,
              itemsPerPage: 9,
              itemBuilderType: type.value,
              onLoaded: (loaded) {
                // * Everytime you paginate more, save the document snapshotss
                saveAsYouLoad = loaded.documentSnapshots;
              },
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              separatorEveryAmount: 3,
              separator: type.value == PaginateType.pageViewSeparated
                  ? Container(
                      color: Colors.brown,
                      child: const Center(
                        child: Text('Ad'),
                      ),
                    )
                  : const EmptySeparator(),
              itemBuilder: (index, context, documentSnapshot) {
                final data = documentSnapshot.data();
                final user = User.fromJson(data!);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: data == null
                          ? const Text('Error in data')
                          : Text(user.firstName),
                      subtitle: Text(documentSnapshot.id),
                      onTap: () {
                        //* When you want to go into a detail
                        //* Send the loaded docs to a "pageViewStartAfter"

                        //* This line checks if the user scrolls, loads, loads, loads,
                        //  * but then they can also scroll back up (we need their current index);

                        final docsLoaded =
                            saveAsYouLoad.getRange(0, index).toList();
                        //* We need to tell the query to start after the last document loaded
                        var startAfter =
                            index == 0 ? null : saveAsYouLoad[index - 1];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) {
                              return DetailsScreenWithPositionSaved(
                                // * Send index to start page controller on the correct thing
                                index: index,
                                prefixDocuments: docsLoaded,
                                startAfter: startAfter,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              query: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('firstName'),
              isLive: true,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsScreenWithPositionSaved extends HookWidget {
  const DetailsScreenWithPositionSaved({
    Key? key,
    required this.index,
    required this.startAfter,
    required this.prefixDocuments,
  }) : super(key: key);

  final int index;
  final DocumentSnapshot? startAfter;
  final List<DocumentSnapshot> prefixDocuments;
  @override
  Widget build(BuildContext context) {
    final pageController =
        usePageController(initialPage: index, keepPage: true);
    return Scaffold(
      appBar: AppBar(),
      body: PaginateFirestore(
        itemsPerPage: 5,
        //* ----------------------------------------------
        itemBuilderType: PaginateType.pageViewStartAfter,
        pageController: pageController,
        startAfterDocument: startAfter,
        prefixDocuments: prefixDocuments,
        //* ----------------------------------------------

        //* You can see here, that when you scroll up, since we already
        // * loaded in the previous page, the load count doesn't increase
        // * (only when you continue your journey and scroll down)
        onLoaded: (docs) {},
        itemBuilder: (index, context, documentSnapshot) {
          final data = documentSnapshot.data();
          final user = User.fromJson(data!);
          return SizedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 3,
              ),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                    ),
                    Text(user.userName),
                    Text(user.email),
                    Text(user.city),
                  ],
                ),
              ),
            ),
          );
        },
        query:
            FirebaseFirestore.instance.collection('users').orderBy('firstName'),
      ),
    );
  }
}
