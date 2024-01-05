import 'package:kolay_app/providers/reminder_provider.dart';
import 'package:kolay_app/providers/shopping_list_provider.dart';
import 'package:kolay_app/providers/meal_plan_provider.dart';
// The Cloud Functions for Firebase SDK to set up triggers and logging.
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {getMessaging} = require("firebase-admin/messaging");

// The Firebase Admin SDK to delete inactive users.
const admin = require("firebase-admin");
admin.initializeApp();


exports.scheduledFunctionCrontab = onSchedule('*/5 * * * *', async (event) => {
  // Create a list containing up to 500 registration tokens.
  // These registration tokens come from the client FCM SDKs.
  const registrationTokens = [
      'cGgLJFF4Rby112twH8C8aY:APA91bFLKAnIU18gI1xTh2vqBCKZoXVvKIPA0YoSZppkfISQiOk96zHCiMmSzgON48WpYnzRlH_im-PVOCulmUx-toNGbV0sMh1pYHYrEJ6sktTw2cVzWFH-FhHHHyWYRPK6b0AyaoCT',
      // …
      'fDS20MOMR1uKuuP6tKhHKA:APA91bGLkfuR2FNlJ2jP-AEiLw7Eh2Q-ckkygi7CCDOFkB6Tnr-mvcr8bmg1go2yNOHvRqGrBu2XliLZJ1LPtBod8Rotplk0Kbp0NhhKil82lTlXWNDFLhLwXyZURmk3r2_Mb5-6J7h5',
  ];
  
  const _fireStoreService = FirebaseFirestore.instance;
  
  /* const message = {
      data: { title: 'Todays Plan', body: 'You have things to do today' },
      tokens: registrationTokens,
  }; */

  // Call the Dart function from JavaScript and get the response
  const response = await fetch('http://localhost:PORT', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ action: 'getIncompleteToDoTasksForHomeScreen' }),
  });

  // Get the JSON response from the Dart function
  const results = await response.json();

  // Modify the message body using the results from the Dart function
  const messageBody = `Tasks: ${results.join(', ')}`;

  const message = {
    notification: { title: 'Today\'s Plan', body: messageBody },
    tokens: registrationTokens,
  };
    
  getMessaging().sendEachForMulticast(message)
    .then((response) => {
      console.log(response.successCount + ' messages were sent successfully');
    });
});


