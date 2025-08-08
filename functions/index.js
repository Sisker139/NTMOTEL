// functions/index.js
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onChatMessageCreated = onDocumentCreated(
  {
    region: "asia-east1",
    document: "chat_rooms/{chatRoomId}/messages/{messageId}",
    retry: false,
  },
  async (event) => {
    const snap = event.data;          // DocumentSnapshot
    if (!snap) return;
    const msg = snap.data();          // <-- lấy dữ liệu ở đây

    const senderId = msg.senderId;
    const receiverId = msg.receiverId;
    const messageType = msg.messageType || "text";
    if (!senderId || !receiverId || senderId === receiverId) return;

    const [senderDoc, receiverDoc] = await Promise.all([
      admin.firestore().doc(`users/${senderId}`).get(),
      admin.firestore().doc(`users/${receiverId}`).get(),
    ]);

    const senderName = senderDoc.data()?.displayName ?? "Người dùng";
    const tokens = receiverDoc.data()?.fcmTokens ?? [];
    if (!tokens.length) {
      logger.info("Receiver has no FCM tokens", { receiverId });
      return;
    }

    const body =
      messageType === "motel_link"
        ? `${senderName} đã gửi cho bạn một liên kết phòng trọ.`
        : (msg.text ?? "Bạn có tin nhắn mới.");

    const res = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title: `Tin nhắn mới từ ${senderName}` },
      data: { click_action: "FLUTTER_NOTIFICATION_CLICK", senderId: String(senderId) },
      android: { priority: "high", notification: { body } },
      apns: { payload: { aps: { alert: { body }, sound: "default" } } }
    });

    const invalid = [];
    res.responses.forEach((r, i) => {
      if (!r.success) {
        logger.error("FCM send failed", { token: tokens[i], code: r.error?.code, message: r.error?.message });
        if (["messaging/registration-token-not-registered", "messaging/invalid-argument"].includes(r.error?.code)) {
          invalid.push(tokens[i]);
        }
      }
    });
    if (invalid.length) {
      await admin.firestore().doc(`users/${receiverId}`)
        .update({ fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalid) });
    }
  }
);
