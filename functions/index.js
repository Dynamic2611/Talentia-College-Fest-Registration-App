const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendEventNotification = onSchedule("every 5 minutes", async (event) => {
    const now = new Date();
    const thresholdTime = new Date();
    thresholdTime.setMinutes(thresholdTime.getMinutes() + 15);

    const eventsRef = admin.firestore().collection("events");
    const querySnapshot = await eventsRef
        .where("eventDate", "<=", thresholdTime)
        .get();

    if (querySnapshot.empty) {
        console.log("No upcoming events in the next 15 minutes.");
        return null;
    }

    const messages = [];

    for (const doc of querySnapshot.docs) {
        const eventData = doc.data();
        const eventId = doc.id;

        const registrationsRef = admin
            .firestore()
            .collection("registrations")
            .where("eventID", "==", eventId);

        const registeredUsers = await registrationsRef.get();

        for (const userDoc of registeredUsers.docs) {
            const userData = await admin
                .firestore()
                .collection("users")
                .doc(userDoc.data().userID)
                .get();
            const fcmToken = userData.data().fcmToken;

            if (fcmToken) {
                messages.push({
                    notification: {
                        title: `Upcoming Event: ${eventData.name}`,
                        body: `Reminder! Your event "${eventData.name}" starts in 15 minutes at ${eventData.location}.`,
                    },
                    token: fcmToken,
                });
            }
        }
    }

    if (messages.length > 0) {
        await admin.messaging().sendEachForMulticast({ messages });
        console.log("Notifications sent!");
    }
    return null;
});
