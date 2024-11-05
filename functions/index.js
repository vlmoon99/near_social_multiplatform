const functions = require('firebase-functions');
const admin = require('firebase-admin');
const bs58 = require('bs58');
const nearApi = require('near-api-js');

admin.initializeApp();
const db = admin.firestore();


async function verifySignature(signature, publicKeyStr, uuid) {
  try {
    const signatureBytes = bs58.default.decode(signature);

    const publicKey = nearApi.utils.PublicKey.from(publicKeyStr);

    const isVerified = publicKey.verify(new Uint8Array([]), signatureBytes);

    return isVerified;
  } catch (error) {
    console.error('Verification failed:', error);
    return false;
  }
}

async function clearMessages(db, collectionPath) {
    const snapshot = await db.collection(collectionPath).get();

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
    });
    await batch.commit();
}



exports.deleteRoom = functions.https.onCall(async (body, context) => {
    const { roomId, uuid , isSecure } = body.data;

    console.log('Received roomId:', roomId);
    console.log('Received uuid:', uuid);
    console.log('Received isSecure:', isSecure);

    try {
        const sessionDoc = await db.collection('sessions').doc(uuid).get();
        
        if (!sessionDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Session not found');
        }

        const sessionData = sessionDoc.data();
        const { accountId, isActive } = sessionData;

        if (!isActive) {
            throw new functions.https.HttpsError('failed-precondition', 'Session is not active');
        }

        const roomDoc = await db.collection('rooms').doc(roomId).get();

        if (!roomDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Room not found');
        }

        const roomData = roomDoc.data();
        const userIds = roomData.userIds || [];

        if (!userIds.includes(accountId)) {
            throw new functions.https.HttpsError('permission-denied', 'User does not have permission to delete this room');
        }

        await clearMessages(db, `rooms/${roomId}/messages`);

        if (isSecure) {
            await db.collection('rooms').doc(roomId).update({"metadata" : {isSecure: true}}, { merge: false });
            console.log(`Room ${roomId} metadata updated to an empty map with isSecure: true`);
        }
        return { success: true, message: 'Room deleted successfully' };
    } catch (error) {
        console.error('Error deleting the room:', error);
        throw new functions.https.HttpsError('internal', 'An error occurred while deleting the room');
    }
});


exports.verifySignedTransaction = functions.https.onCall(async (body, context) => {
    const { signature, publicKeyStr, uuid, accountId } = body.data;
    console.log('body.data:', body.data);
    console.log('signature:', signature);
    console.log('Received publicKeyStr:', publicKeyStr);
    console.log('Received uuid:', uuid);
    console.log('Received accountId:', accountId);

    try {
        const isVerified = await verifySignature(signature, publicKeyStr, uuid);

        if (isVerified) {
            console.log('isVerified:', isVerified);
            await db.collection('sessions').doc(uuid).set({
                accountId: accountId,
                isActive: true,
            });
            console.log(`Session created for uuid: ${uuid}, accountId: ${accountId}`);

            return { success: true };

        } else {
            console.log('isVerified:', isVerified);
            return { success: false };
        }


    } catch (error) {
        console.error('Error verifying transaction:', error);
        throw new functions.https.HttpsError('internal', 'Verification failed');
    }
});