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
    
  /* const message = {
      data: { title: 'Todays Plan', body: 'You have things to do today' },
      tokens: registrationTokens,
  }; */

  const message = {
    notification: { title: 'Todays Plan', body: 'You have things to do today' },
    tokens: registrationTokens,
  };
    
  getMessaging().sendEachForMulticast(message)
    .then((response) => {
      console.log(response.successCount + ' messages were sent successfully');
    });
});
