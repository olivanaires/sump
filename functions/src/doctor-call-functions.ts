import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as notificatio from './notification-helpers';

export const onCreateDoctorCall = functions.firestore.document('/doctorCalls/{doctorCallId}')
    .onCreate(async (snapshot, context) => {

        const doctorCallId = context.params.doctorCallId;
        functions.logger.info(`DoctorCall UID: ${doctorCallId}`);

        // TODO Buscar o doctorCall com base no Id e verificar se foi para um grupo.
        // TODO Caso tenha sido, notificar apenas os usuários desse grupo

        const querySnapshot = await admin.firestore().collection('users').get();
        const usersUid = querySnapshot.docs.map(doc => doc.id);
        functions.logger.info(`Users UID to send [[${usersUid}]]`);

        let usersTokens: string[] = [];
        for (const userUid of usersUid) {
            const tokens: string[] = await notificatio.getDeviceTokens(userUid);
            usersTokens = usersTokens.concat(tokens);
        }

        functions.logger.info(`Users tokens [[${usersTokens}]]`);
        await notificatio.sendPushFCM(
            usersTokens,
            'Novo Repasse',
            'Nova repasse cadastrado. Repasse: ' + doctorCallId
        );

    });

export const onUpdateDoctorCall = functions.firestore.document('/doctorCalls/{doctorCallId}')
    .onUpdate(async (snapshot, context) => {
        const docCallBefore = snapshot.before.data();
        const docCallAfter = snapshot.after.data();

        functions.logger.info(`DocUID ${context.params.doctorCallId}: Antes ${snapshot.before.data()['available']} | Depos ${snapshot.after.data()['available']} | Requestor: ${docCallAfter['requestor']}`);
        if (docCallBefore['available'] && !docCallAfter['available']
            && docCallAfter['requestor'] !== null && docCallAfter['requestor']['uid'] !== null) {
            const msg = `Repasse nº ${context.params.doctorCallId} foi solicitado pelo Dr(a). ${docCallAfter['requestor']['name']}`;
            await notiifyDoctorCallOwner(context.params.doctorCallId, docCallAfter['owner']['uid'], msg);

        } else if (!docCallBefore['available'] && docCallAfter['available'] && docCallAfter['requestor'] === null) {
            const msg = `Solicitação do Repasse nº ${context.params.doctorCallId} foi cancelada pelo Dr(a). ${docCallBefore['requestor']['name']}`;
            await notiifyDoctorCallOwner(context.params.doctorCallId, docCallAfter['owner']['uid'], msg);
        }

    });

export const onDeleteDoctorCall = functions.firestore.document('/doctorCalls/{doctorCallId}')
    .onDelete(async (snapshot, context) => {
        const requestor = snapshot.data()['requestor'];
        if (requestor !== null && requestor['uid'] !== null) {
            functions.logger.info(`DocCallUID ${context.params.doctorCallId} foi deletada por ${snapshot.data()['owner']}, avisar solicitante ${requestor['uid']}`);

            const tokens: string[] = await notificatio.getDeviceTokens(requestor['uid']);
            functions.logger.info(`Sending push to ${requestor['uid']} with tokens ${tokens}`);

            const msg = `Repasse nº ${context.params.doctorCallId} foi cancelado pelo Dr(a). ${snapshot.data()['owner']['name']}`;
            await notificatio.sendPushFCM(tokens, 'Repasse De Plantão', msg);
        }
    });

async function notiifyDoctorCallOwner(doctorCallId: string, notifiedId: string, msg: string) {

    functions.logger.info(`Pus MSG: ${msg}`);
    const tokens: string[] = await notificatio.getDeviceTokens(notifiedId);
    functions.logger.info(`Sending push to ${notifiedId} with tokens ${tokens}`);
    await notificatio.sendPushFCM(tokens, 'Repasse De Plantão', msg);

}
