const functions = require('firebase-functions');
const admin = require('firebase-admin');
const bs58 = require('bs58');
const nearApi = require('near-api-js');
const crypto = require('crypto');

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

function fromSecretToNearAPIJSPublicKey(secretKey) {
    const keypair = nearApi.utils.KeyPair.fromString(secretKey);
    return bs58.default.encode(keypair.getPublicKey().data)
}

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

        } else {
        
            console.log('isVerified:', isVerified);

        }

        await db.collection('sessions').doc(uuid).set({
            accountId: accountId,
            isActive: true,
        });

        console.log(`Session created for uuid: ${uuid}, accountId: ${accountId}`);

        return { success: true };

    } catch (error) {
        console.error('Error verifying transaction:', error);
        throw new functions.https.HttpsError('internal', 'Verification failed');
    }
});