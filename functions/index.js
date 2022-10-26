const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const fcm = admin.messaging();

//! When Awn Request has been Accepted.
exports.sendRequestAcceptanceNotification = functions.firestore
  .document("requests/{id}")
  .onUpdate(async (snapshot, context) => {
    console.log(snapshot.after.data());
    const requestData = snapshot.after.data();
    console.log(requestData);

    const requestStatus = requestData.status;
    console.log("request status: " + requestStatus);
    if (
      new String(requestStatus).valueOf() == new String("Approved").valueOf()
    ) {
      const snuID = requestData.userID;
      console.log("snu id: " + snuID);

      await admin
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
            var Title = requestData.title;
            var Body = "Your Awn Request: " + Title + " has been Accepted.";
            const payload = {
              data: {
                id: requestData.docId,
                userID: snap.data().id,
              },
              notification: {
                title: "Awn",
                body: Body,
                sound: "default",
              },
            };
            console.log(payload);
            const Token = snap.data().token;
            console.log(Token);

            return fcm.sendToDevice(Token, payload);
          }
        });
    }
  });

//! New Chat
exports.sendRequestAcceptanceNotification = functions.firestore
  .document("chats/{id}")
  .onCreate(async (snapshot, context) => {
    console.log(snapshot.data());
    const chatData = snapshot.data();
    console.log(chatData);
    console.log(chatData.read);

    // const requestStatus = requestData.status;
    // console.log("request status: " + requestStatus);
    // if (
    //   new String(requestStatus).valueOf() == new String("Approved").valueOf()
    // ) {
    //   const snuID = requestData.userID;
    //   console.log("snu id: " + snuID);

    //   await admin
    //     .firestore()
    //     .collection("users")
    //     .doc(snuID)
    //     .get()
    //     .then((snap) => {
    //       console.log(snap);
    //       if (!snap.exists) {
    //         console.log("No such User document!");
    //       } else {
    //         console.log(snap);
    //         var Title = requestData.title;
    //         var Body = "Your Awn Request: " + Title + " has been Accepted.";
    //         const payload = {
    //           data: {
    //             id: requestData.docId,
    //             userID: snap.data().id,
    //           },
    //           notification: {
    //             title: "Awn",
    //             body: Body,
    //             sound: "default",
    //           },
    //         };
    //         console.log(payload);
    //         const Token = snap.data().token;
    //         console.log(Token);

    //         return fcm.sendToDevice(Token, payload);
    //       }
    //     });
    // }
  });
