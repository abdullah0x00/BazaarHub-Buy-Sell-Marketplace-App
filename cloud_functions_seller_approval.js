/**
 * Firebase Cloud Function for Seller Approval
 *
 * Instructions:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Login: firebase login
 * 3. Init functions: firebase init functions (Select JavaScript/TypeScript)
 * 4. Copy this code into your functions/index.js
 * 5. Deploy: firebase deploy --only functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Triggered when a User document is updated in Firestore.
 * This handles background logic after an Admin approves a seller.
 */
exports.onSellerApproval = functions.firestore
    .document("users/{userId}")
    .onUpdate(async (change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();

        // Check if isApprovedSeller was changed from false to true
        if (newValue.isApprovedSeller === true && previousValue.isApprovedSeller === false) {
            const userId = context.params.userId;
            const userName = newValue.name;
            const shopName = newValue.shopName;

            console.log(`Processing approval for Seller: ${userName} (${userId})`);

            try {
                // 1. Perform background tasks (e.g., Update system counters)
                await admin.firestore().collection("system_stats").doc("sellers").set({
                    totalApproved: admin.firestore.FieldValue.increment(1)
                }, { merge: true });

                // 2. Send Push Notification to the user
                const payload = {
                    notification: {
                        title: "Shop Approved! 🚀",
                        body: `Congratulations ${userName}! Your shop "${shopName}" is now live. Start adding products now.`,
                        clickAction: "FLUTTER_NOTIFICATION_CLICK"
                    },
                    data: {
                        type: "seller_approval",
                        status: "approved"
                    }
                };

                // Assume user has a fcmToken stored in their document
                if (newValue.fcmToken) {
                    await admin.messaging().sendToDevice(newValue.fcmToken, payload);
                }

                // 3. Optional: Send an Email using a trigger or third-party service
                // (e.g., writing to a 'mail' collection for 'Trigger Email' extension)
                await admin.firestore().collection("mail").add({
                    to: newValue.email,
                    message: {
                        subject: "Your Seller Account is Approved!",
                        html: `Hello ${userName}, <br><br> Your application for <b>${shopName}</b> has been approved. You can now access your seller dashboard.`
                    }
                });

                return console.log(`Approval background tasks completed for ${userId}`);
            } catch (error) {
                return console.error("Error processing seller approval:", error);
            }
        }

        return null;
    });
