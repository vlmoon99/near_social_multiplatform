const admin = require('firebase-admin');

admin.initializeApp({ projectId: "near-social-mobile-777" });

const db = admin.firestore();

db.settings({
  host: 'localhost:1111',
  ssl: false,             
});

async function saveData(collection, documentId, data) {
  try {
    await db.collection(collection).doc(documentId).set(data);
    console.log(`Document ${documentId} successfully written in ${collection} collection!`);
  } catch (error) {
    console.error('Error writing document:', error);
  }
}

const sampleData = {
  name: 'John Doe',
  age: 30,
  city: 'New York',
};

saveData('users', 'user123', sampleData);
