import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered when a new user is created in Firebase Auth
 * Creates a user document in Firestore
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  try {
    await db.collection('users').doc(user.uid).set({
      name: user.displayName || '',
      email: user.email || '',
      role: 'owner', // Default role
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`User document created for ${user.uid}`);
  } catch (error) {
    console.error('Error creating user document:', error);
  }
});

/**
 * Triggered when a booking is created or updated
 * Sends FCM notification to relevant users
 */
export const sendBookingNotifications = functions.firestore
  .document('bookings/{bookingId}')
  .onWrite(async (change, context) => {
    const booking = change.after.exists ? change.after.data() : null;
    if (!booking) return;

    const bookingId = context.params.bookingId;
    const { ownerId, vetId, sitterId, status, type } = booking;

    try {
      // Get user FCM tokens
      const tokens: string[] = [];
      
      if (vetId) {
        const vetDoc = await db.collection('users').doc(vetId).get();
        const vetToken = vetDoc.data()?.fcmToken;
        if (vetToken) tokens.push(vetToken);
      }
      
      if (sitterId) {
        const sitterDoc = await db.collection('users').doc(sitterId).get();
        const sitterToken = sitterDoc.data()?.fcmToken;
        if (sitterToken) tokens.push(sitterToken);
      }

      if (tokens.length === 0) return;

      // Prepare notification
      const statusText = status.toUpperCase();
      const title = `Booking ${statusText}`;
      const body = `Your ${type} booking has been ${statusText.toLowerCase()}`;

      const message: admin.messaging.MulticastMessage = {
        notification: {
          title,
          body,
        },
        data: {
          type: 'booking',
          bookingId,
          status,
        },
        tokens,
      };

      // Send notification
      const response = await messaging.sendEachForMulticast(message);
      console.log(`Sent ${response.successCount} notifications`);
    } catch (error) {
      console.error('Error sending booking notification:', error);
    }
  });

/**
 * Triggered when a message is written to a chat
 * Updates chat lastMessage and lastUpdated
 */
export const onMessageWrite = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const chatId = context.params.chatId;
    const message = snap.data();
    const messageText = message.text || '📷 Image';

    try {
      await db.collection('chats').doc(chatId).update({
        lastMessage: messageText,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Optionally send push notification to recipient
      const chatDoc = await db.collection('chats').doc(chatId).get();
      const participants = chatDoc.data()?.participants || [];
      const recipientId = participants.find((id: string) => id !== message.senderId);

      if (recipientId) {
        const recipientDoc = await db.collection('users').doc(recipientId).get();
        const fcmToken = recipientDoc.data()?.fcmToken;

        if (fcmToken) {
          await messaging.send({
            token: fcmToken,
            notification: {
              title: 'New Message',
              body: messageText,
            },
            data: {
              type: 'chat',
              chatId,
            },
          });
        }
      }
    } catch (error) {
      console.error('Error updating chat:', error);
    }
  });

/**
 * Scheduled function to send booking reminders
 * Runs daily at 9 AM
 */
export const scheduledReminders = functions.pubsub
  .schedule('0 9 * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    try {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0);

      const dayAfter = new Date(tomorrow);
      dayAfter.setDate(dayAfter.getDate() + 1);

      // Find bookings for tomorrow
      const bookingsSnapshot = await db
        .collection('bookings')
        .where('startDateTime', '>=', admin.firestore.Timestamp.fromDate(tomorrow))
        .where('startDateTime', '<', admin.firestore.Timestamp.fromDate(dayAfter))
        .where('status', '==', 'ACCEPTED')
        .get();

      const tokens: string[] = [];
      for (const doc of bookingsSnapshot.docs) {
        const booking = doc.data();
        const ownerDoc = await db.collection('users').doc(booking.ownerId).get();
        const token = ownerDoc.data()?.fcmToken;
        if (token) tokens.push(token);
      }

      if (tokens.length > 0) {
        await messaging.sendEachForMulticast({
          notification: {
            title: 'Booking Reminder',
            body: 'You have a booking scheduled for tomorrow',
          },
          tokens,
        });
      }
    } catch (error) {
      console.error('Error sending reminders:', error);
    }
  });

