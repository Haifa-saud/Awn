// import * as admin from "firebase-admin";

const functions = require("firebase-functions");
// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();
// const { a } = require("firebase-admin/app");

// a.initializeApp(functions.config().firebase);

const fcm = admin.messaging();

exports.sendDevices = functions.firestore
  .document("posts/{id}")
  .onUpdate((snapshot) => {
    const name = snapshot.get("name");
    const subject = snapshot.get("status");
    const token = snapshot.get("token");

    const payload = {
      notification: {
        title: "from " + name,
        body: "subject " + subject,
        sound: "default",
      },
    };
    return fcm.sendToDevice(token, payload);
  });

exports.makeUppercase = functions.firestore
  .document("UserDisabilityType/{documentId}")
  .onCreate((snap, context) => {
    // Grab the current value of what was written to Firestore.
    const original = snap.data().original;

    // Access the parameter `{documentId}` with `context.params`
    functions.logger.log("Uppercasing", context.params.documentId, original);

    const uppercase = original.toUpperCase();

    // You must return a Promise when performing asynchronous tasks inside a Functions such as
    // writing to Firestore.
    // Setting an 'uppercase' field in Firestore document returns a Promise.
    return snap.ref.set({ uppercase }, { merge: true });
  });

exports.makeUppercase2 = functions.firestore
  .document("UserDisabilityType/{documentId}")
  .onCreate((snap, context) => {
    // Grab the current value of what was written to Firestore.
    const name = snap.data().original + "I am functions";
    // const name = snap.get("name") + "I am functions";

    // Access the parameter `{documentId}` with `context.params`
    functions.logger.log("Uppercasing", context.params.documentId, original);

    // const uppercase = original.toUpperCase();

    // You must return a Promise when performing asynchronous tasks inside a Functions such as
    // writing to Firestore.
    // Setting an 'uppercase' field in Firestore document returns a Promise.
    return snap.ref.set({ name }, { merge: true });
  });
