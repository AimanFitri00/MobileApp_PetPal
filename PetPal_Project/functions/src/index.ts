import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import crypto from 'crypto';

admin.initializeApp();

const db = admin.firestore();

type BookingPayload = {
  ownerId: string;
  petId: string;
  status: string;
  date: admin.firestore.Timestamp;
  time?: string;
};

const getUserTokens = async (uid: string): Promise<string[]> => {
  const doc = await db.collection('users').doc(uid).get();
  const data = doc.data();
  return (data?.fcmTokens as string[]) ?? [];
};

const sendPush = async (tokens: string[], title: string, body: string) => {
  if (!tokens.length) {
    return;
  }
  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
  });
};

export const preventPasswordReuse = functions.https.onCall(async (data, context) => {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign in to update your password.');
  }
  const uid = context.auth.uid;
  const newPassword: string = data.newPassword;
  if (!newPassword) {
    throw new functions.https.HttpsError('invalid-argument', 'newPassword is required.');
  }
  const hash = crypto.createHash('sha256').update(newPassword).digest('hex');
  const historyRef = db.collection('users').doc(uid).collection('security').doc('passwordHistory');
  const snapshot = await historyRef.get();
  const hashes: string[] = snapshot.exists ? snapshot.data()?.hashes ?? [] : [];
  if (hashes.includes(hash)) {
    throw new functions.https.HttpsError('failed-precondition', 'Choose a password you have not used recently.');
  }
  const updatedHistory = [hash, ...hashes].slice(0, 3);
  await historyRef.set({ hashes: updatedHistory }, { merge: true });
  return { success: true };
});

const createStatusChangeHandler = (collection: string) =>
  functions.firestore.document(`${collection}/{bookingId}`).onWrite(async (change, context) => {
    const after = change.after.exists ? (change.after.data() as BookingPayload) : null;
    const before = change.before.exists ? (change.before.data() as BookingPayload) : null;

    if (!after) {
      return;
    }

    if (before && before.status === after.status) {
      return;
    }

    const ownerTokens = await getUserTokens(after.ownerId);
    await sendPush(ownerTokens, 'Booking update', `Your ${collection === 'vetBookings' ? 'vet' : 'sitter'} booking is now ${after.status}.`);

    const providerId = collection === 'vetBookings' ? (after as any).vetId : (after as any).sitterId;
    const providerTokens = providerId ? await getUserTokens(providerId) : [];
    await sendPush(providerTokens, 'New booking status', `Booking for pet ${after.petId} is ${after.status}.`);
  });

export const onVetBookingStatusChange = createStatusChangeHandler('vetBookings');
export const onSitterBookingStatusChange = createStatusChangeHandler('sitterBookings');

export const appointmentReminders = functions.pubsub.schedule('every 30 minutes').onRun(async () => {
  const now = admin.firestore.Timestamp.now();
  const upcoming = now.toDate();
  const future = new Date(upcoming.getTime() + 60 * 60 * 1000);
  const query = await db
    .collection('vetBookings')
    .where('date', '>=', now)
    .where('date', '<=', admin.firestore.Timestamp.fromDate(future))
    .get();

  await Promise.all(
    query.docs.map(async (doc) => {
      const booking = doc.data() as BookingPayload;
      if (booking.status !== 'accepted') return;
      const tokens = await getUserTokens(booking.ownerId);
      await sendPush(tokens, 'Appointment reminder', `Appointment for pet ${booking.petId} is coming up soon.`);
    }),
  );
});

