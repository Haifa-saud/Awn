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
                type: "requestAcceptance",
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
exports.sendChatNotification = functions.firestore
  .document("requests/{id}/chats/{chatId}")
  .onCreate(async (snapshot, context) => {
    console.log(snapshot.data());
    const chatData = snapshot.data();
    console.log(chatData);
    console.log(chatData.read);
    console.log(snapshot.ref.parent.parent.id);
    console.log(snapshot.ref.id);

    var reqID = snapshot.ref.parent.parent.id;
    if (
      new String(chatData.text).valueOf() !=
      new String(
        "This chat offers Text to Speech service, please long press on the chat to try it."
      ).valueOf()
    ) {
      await admin
        .firestore()
        .collection("requests")
        .doc(reqID)
        .get()
        .then(async (snap) => {
          console.log(snap);
          if (!snap.exists) {
            console.log("No such Request document!");
          } else {
            console.log(snap);

            var receiverID =
              new String(snap.data().VolID).valueOf() ==
              new String(chatData.author).valueOf()
                ? snap.data().userID
                : snap.data().VolID;
            await admin
              .firestore()
              .collection("users")
              .doc(receiverID)
              .get()
              .then((data) => {
                console.log(data);
                if (!snap.exists) {
                  console.log("No such User document!");
                } else {
                  console.log(data);
                  var name = data.data().name;
                  var Title = "New Chat from: " + name;
                  var Body =
                    new String(chatData.text).valueOf() ==
                    new String("").valueOf()
                      ? new String(chatData.audio).valueOf() ==
                        new String("").valueOf()
                        ? "Image"
                        : "Audio Chat"
                      : chatData.text;
                  const payload = {
                    data: {
                      id: reqID,
                      type: "chat",
                    },
                    notification: {
                      title: Title,
                      body: Body,
                      sound: "default",
                    },
                  };
                  console.log(payload);
                  const Token = data.data().token;
                  console.log(Token);

                  return fcm.sendToDevice(Token, payload);
                }
              });
          }
        });
    }
  });
