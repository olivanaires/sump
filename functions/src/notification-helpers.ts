import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

export const getDeviceTokens = async function getDeviceTokens(uid: string) {
    const querySnapshot = await admin.firestore().collection('users').doc(uid).collection('tokens').get();
    const tokens = querySnapshot.docs.map(doc => doc.id);
    functions.logger.info(`User UID ${uid}, with tokens [[${tokens}]]`);
    return tokens;
}

export const sendPushFCM = async function sendPushFCM(tokens: string[], title: string, message: string) {
    if (tokens.length > 0) {
        const payload = {
            notification: {
                title: title,
                body: message,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };

        await admin.messaging().sendToDevice(tokens, payload);
        return;
    }
    return;
}