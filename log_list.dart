import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogList extends StatefulWidget {
  final String userId;

  LogList({required this.userId});

  @override
  _LogListState createState() => _LogListState();
}

class _LogListState extends State<LogList>
    with SingleTickerProviderStateMixin {
  String selectedUserId = '';
  String adminSelectedDate = '';
  String userSelectedDate = '';
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Widget> _getEntriesForUser(QueryDocumentSnapshot<Object?> dateDoc) {
    List<Widget> entryWidgets = [];

    var date = dateDoc.id; // Tarih
    var entries = dateDoc.data() as Map<String, dynamic>;

    List<Widget> userEntryWidgets = [];

    // Giriş saatleri
    if (entries.containsKey('giriş')) {
      for (var entry in entries['giriş']) {
        userEntryWidgets.add(Text('Giriş: $entry'));
      }
    }

    // Çıkış saatleri
    if (entries.containsKey('çıkış')) {
      for (var exit in entries['çıkış']) {
        userEntryWidgets.add(Text('Çıkış: $exit'));
      }
    }

    entryWidgets.add(buildUserCard(date, userEntryWidgets));

    return entryWidgets;
  }

// ...

  Widget buildUserCard(String date, List<Widget> entryWidgets) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarih: $date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            if (entryWidgets.isNotEmpty)
              ...entryWidgets
            else
              Text('Henüz giriş/çıkış kaydı bulunmamaktadır.'),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş/Çıkış Logları'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (userSnapshot.hasError) {
                return Text('Kullanıcı verileri getirilirken bir hata oluştu.');
              }

              bool isAdmin = userSnapshot.data?.get('isAdmin') ?? false;

              return isAdmin
                  ? StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot> usersSnapshot) {
                  if (usersSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (usersSnapshot.hasError) {
                    return Text(
                        'Kullanıcı verileri getirilirken bir hata oluştu.');
                  }

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            DropdownButton<String>(
                              value: selectedUserId,
                              items: [
                                DropdownMenuItem<String>(
                                  child: Text('Tüm Kullanıcılar'),
                                  value: '',
                                ),
                                for (var userDoc
                                in usersSnapshot.data!.docs)
                                  DropdownMenuItem<String>(
                                    child: Text(
                                        '${userDoc['name']} ${userDoc['surname']} '),
                                    value: userDoc.id,
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedUserId = value!;
                                  adminSelectedDate = ''; // Reset selected date when user changes.
                                  _animationController.forward();
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            if (selectedUserId.isNotEmpty)
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(selectedUserId)
                                    .collection('Date')
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot>
                                    dateSnapshot) {
                                  if (dateSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  if (dateSnapshot.hasError) {
                                    return Text(
                                        'Tarih verileri getirilirken bir hata oluştu.');
                                  }

                                  List<String> availableDates = dateSnapshot
                                      .data!.docs
                                      .map((dateDoc) => dateDoc.id)
                                      .toList();

                                  return Column(
                                    children: [
                                      DropdownButton<String>(
                                        value: adminSelectedDate,
                                        items: [
                                          DropdownMenuItem<String>(
                                            child: Text('Tüm Tarihler'),
                                            value: '',
                                          ),
                                          for (var date in availableDates)
                                            DropdownMenuItem<String>(
                                              child: Text(date),
                                              value: date,
                                            ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            adminSelectedDate = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: ListView.builder(
                            itemCount: usersSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var userDoc =
                              usersSnapshot.data!.docs[index];
                              return _buildAdminCard(
                                  userDoc, usersSnapshot);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
                  : FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('Date')
                    .get(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot> dateSnapshot) {
                  if (dateSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (dateSnapshot.hasError) {
                    return Text(
                        'Tarih verileri getirilirken bir hata oluştu.');
                  }

                  if (!dateSnapshot.hasData ||
                      dateSnapshot.data!.docs.isEmpty) {
                    return Text(
                        'Henüz giriş/çıkış kaydı bulunmamaktadır.');
                  }

                  var entryWidgets = dateSnapshot.data!.docs
                      .where((dateDoc) =>
                  userSelectedDate.isEmpty ||
                      dateDoc.id == userSelectedDate)
                      .map((dateDoc) =>
                      _getEntriesForUser(dateDoc))
                      .expand((i) => i)
                      .toList();

                  return Column(
                    children: [
                      if (dateSnapshot.data!.docs.isNotEmpty)
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .collection('Date')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot>
                              userDateSnapshot) {
                            if (userDateSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (userDateSnapshot.hasError) {
                              return Text(
                                  'Tarih verileri getirilirken bir hata oluştu.');
                            }

                            List<String> availableDates = userDateSnapshot
                                .data!.docs
                                .map((dateDoc) => dateDoc.id)
                                .toList();

                            return Column(
                              children: [
                                DropdownButton<String>(
                                  value: userSelectedDate,
                                  items: [
                                    DropdownMenuItem<String>(
                                      child: Text('Tüm Tarihler'),
                                      value: '',
                                    ),
                                    for (var date in availableDates)
                                      DropdownMenuItem<String>(
                                        child: Text(date),
                                        value: date,
                                      ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      userSelectedDate = value!;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: entryWidgets,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
      QueryDocumentSnapshot<Object?> userData,
      AsyncSnapshot<QuerySnapshot<Object?>> usersSnapshot) {
    if (selectedUserId.isNotEmpty && selectedUserId != userData.id) {
      return Container();
    }

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personel: ${userData['name']} ${userData['surname']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userData.id)
                  .collection('Date')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> dateSnapshot) {
                if (dateSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (dateSnapshot.hasError) {
                  return Text(
                      'Tarih verileri getirilirken bir hata oluştu.');
                }

                if (!dateSnapshot.hasData ||
                    dateSnapshot.data!.docs.isEmpty) {
                  return Text(
                      'Henüz giriş/çıkış kaydı bulunmamaktadır.');
                }

                List<Widget> logsWidgets = [];

                for (var dateDoc in dateSnapshot.data!.docs) {
                  if (dateDoc.exists) {
                    if (adminSelectedDate.isEmpty ||
                        dateDoc.id == adminSelectedDate) {
                      logsWidgets.addAll(_getEntriesForUser(dateDoc));
                    }
                  } else {
                    logsWidgets
                        .add(Text('Giriş/Çıkış kaydı bulunmamaktadır.'));
                  }
                }

                return Column(
                  children: logsWidgets,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
