// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'models/firebModel.dart';
//
// String CheckUserId = '';
//
// firebaseCloudMessagingListeners() {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   final List<Message> messages = [];
//   _firebaseMessaging.configure(
//     onMessage: (Map<String, dynamic> message) async {
//       print("onMessage: $message");
//       final notification = message['notification'];
//       // setState(() {
//       //   messages.add(Message(
//       //       title: notification['title'], body: notification['body']));
//       // });
//     },
//     onLaunch: (Map<String, dynamic> message) async {
//       print("onLaunch: $message");
//
//       final notification = message['data'];
//       // setState(() {
//       //   messages.add(Message(
//       //     title: '${notification['title']}',
//       //     body: '${notification['body']}',
//       //   ));
//       // });
//     },
//     onResume: (Map<String, dynamic> message) async {
//       print("onResume: $message");
//     },
//   );
//   _firebaseMessaging.requestNotificationPermissions(
//       const IosNotificationSettings(sound: true, badge: true, alert: true));
// }
