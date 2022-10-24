const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const fcm = admin.messaging();

exports.sendRequestAcceptanceNotification = functions.firestore
  .document("requests/{id}")
  .onUpdate((snapshot, context) => {
    // return snap.get().then((snapshot) => {
    //   snapshot.forEach((doc) => {
    console.log(snapshot.after.data());
    const requestData = snapshot.after.data();
    // const previousValue = snapshot.before.data();
    console.log(requestData);

    const requestStatus = requestData.status;
    console.log("request status: " + requestStatus);
    if (requestStatus == "Approved") {
      const snuID = requestData.userID;
      admin
        .firestore()
        .collection("users")
        .doc(snuID)
        .get()
        .then((snap) => {
          console.log(snap);
          if (!snap.exists) {
            console.log("No such User document!");
          } else {
            console.log(snap);
          }
        });

      //   else {
      //         console.log("Document data:", snap.data);
      //         const token = snap.data.token;
      //         const payload = {
      //           notification: {
      //             title: "from ",
      //             body: "subject ",
      //             sound: "default",
      //           },
      //         };
      //         snapshot.ref.set({ title: "it is working" }, { merge: true });
      //         return fcm.sendToDevice(token, payload);
      //       }
      //     });
      //   });
    }
  });
//   });

// exports.makeUppercase2 = functions.firestore
//   .document("users/Sm6x7nZbcFSKuBG9maulFkNKvcL2")
//   .onCreate((snap, context) => {
//     var snapshot = admin
//       .firestore()
//       .collection("users")
//       .doc("Sm6x7nZbcFSKuBG9maulFkNKvcL2");
//     var currData = snap.data();
//     const newValue = currData.Email;
//     return snapshot
//       .get()
//       .then((doc) => {
//         if (!doc.exists) {
//           console.log("No such User document!");
//           console.log("Document data:", doc.data().Email);
//         } else {
//           console.log("Document data:", doc.data());
//           console.log("Document data:", doc.data().Email);
//           snap.ref.set({ Email: newValue + "newTest" }, { merge: true });
//           return true;
//         }
//       })
//       .catch((err) => {
//         console.log("Error getting document", err);

//         return false;
//       });
//   });
