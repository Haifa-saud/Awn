// import * as admin from "firebase-admin";

const functions = require("firebase-functions");
// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();
// const { a } = require("firebase-admin/app");

// a.initializeApp(functions.config().firebase);

// const fcm = admin.messaging();

// exports.sendRequestAcceptanceNotification = functions.admin.firestore()
//   .document("request/{id}")
//   .onUpdate((snapshot) => {
// 	var snapshot = admin
//       .firestore()
//       .collection("users")
//       .doc("Sm6x7nZbcFSKuBG9maulFkNKvcL2");
//     const name = admin.snapshot.get("name");
//     const subject = snapshot.get("status");
//     const token = snapshot.get("token");

//     const payload = {
//       notification: {
//         title: "from " + name,
//         body: "subject " + subject,
//         sound: "default",
//       },
//     };
//     return fcm.sendToDevice(token, payload);
//   });

exports.makeUppercase = functions.firestore
  .document("users/Sm6x7nZbcFSKuBG9maulFkNKvcL2")
  .onCreate((snap, context) => {
    var snapshot = admin
      .firestore()
      .collection("users")
      .doc("Sm6x7nZbcFSKuBG9maulFkNKvcL2");
    var currData = snap.data();
    const newValue = currData.Email;
    return snapshot
      .get()
      .then((doc) => {
        if (!doc.exists) {
          console.log("No such User document!");
          console.log("Document data:", doc.data().Email);
        } else {
          console.log("Document data:", doc.data());
          console.log("Document data:", doc.data().Email);
          snap.ref.set({ Email: newValue + "newTest" }, { merge: true });
          return true;
        }
      })
      .catch((err) => {
        console.log("Error getting document", err);

        return false;
      });

    // return snap.ref.set({ name: name });
  });
