// The Cloud Functions for Firebase SDK to set up triggers and logging.
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {getMessaging} = require("firebase-admin/messaging");

// The Firebase Admin SDK to delete inactive users.
const admin = require("firebase-admin");
admin.initializeApp();



exports.scheduledFunctionCrontab = onSchedule('*/5 * * * *', async (event) => {
  const registrationTokens = [
    'cGgLJFF4Rby112twH8C8aY:APA91bFLKAnIU18gI1xTh2vqBCKZoXVvKIPA0YoSZppkfISQiOk96zHCiMmSzgON48WpYnzRlH_im-PVOCulmUx-toNGbV0sMh1pYHYrEJ6sktTw2cVzWFH-FhHHHyWYRPK6b0AyaoCT',
    // …
    'fDS20MOMR1uKuuP6tKhHKA:APA91bGLkfuR2FNlJ2jP-AEiLw7Eh2Q-ckkygi7CCDOFkB6Tnr-mvcr8bmg1go2yNOHvRqGrBu2XliLZJ1LPtBod8Rotplk0Kbp0NhhKil82lTlXWNDFLhLwXyZURmk3r2_Mb5-6J7h5',

    'dDhPDJA5Rv6_x9qHo7ee51:APA91bHTlfhtXYt41n_S85MswN_C6OmuINGGVO0fxZ4Lc2IV7t-_LXkJnCtguCcEEgPY6D2jqucHX36i4Jy6k0maXO4ejsOxsQX2vpGpkZh0CYDvoFlQJk3y5iaO6qGkSIkHqPhVa1GE',
];


  const db = admin.firestore();
  let message_text = "You have ";

  try {
    const snapshot = await db.collection("USERS").get();

    const promises = snapshot.docs.map(async (doc) => {
      const shoppingLists = await db.collection("USERS").doc(doc.id).collection('shoppingLists').get();
      const now = new Date();
      const formattedDate = now.toLocaleDateString('tr-TR');

      let counter = 0;

      await Promise.all(shoppingLists.docs.map(async (shopDoc) => {
        const timestamp = shopDoc.data().datetime;
        const date = timestamp.toDate();
        const shoppingListDate = date.toLocaleDateString('tr-TR', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric',
        });

        if (formattedDate.localeCompare(shoppingListDate) === 0) {
          counter++;
        }
      }));

      message_text += `${counter} shopping lists for user ${doc.id}. `;
    });

    await Promise.all(promises);

    const message = {
      notification: { title: 'Todays Plan', body: message_text },
      tokens: registrationTokens,
    };

    await getMessaging().sendMulticast(message);
    console.log('Notification sent successfully');
  } catch (error) {
    console.error('Error:', error);
  }
});
