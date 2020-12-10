import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
const nodemailer = require('nodemailer');
import * as notification from './notification-helpers';

export const onCreateGroupInUser = functions.firestore.document("/groups/{groupId}")
    .onWrite(async (snapshot, context) => {
        const group: any = snapshot.after.data();
        const existingUsers = group.users.filter((element: any) => element.status === 0 );
        const invitationUsers = group.users.filter((element: any) => element.status === 1);

        createExistingUsers(existingUsers);
        createInvitations(invitationUsers);

        function createExistingUsers(usersSelected: any) {
            usersSelected.forEach(async (element: any) => {
                const data = {
                    groupId: context.params.groupId,
                    name: group.name,
                    status: 4,
                    requester: element.requester,
                    name_requester: element.name_requester,
                    email: element.email

                }
                await admin.firestore().collection('users').doc(element.userId).collection('groups').doc(data.groupId).set(data);

                await admin.firestore().collection('groups').doc(context.params.groupId).update({
                    users: admin.firestore.FieldValue.arrayRemove(element),
                })
                element.status = 4;
                await admin.firestore().collection('groups').doc(context.params.groupId).update({
                    users: admin.firestore.FieldValue.arrayUnion(element),
                })
                const msg = `Você foi convidado para entrar no grupo ${group.name}`;
                await notififyUserGroup(element.userId, msg);

            });
        }

        function createInvitations(invitations: any) {
            invitations.forEach(async (element: any) => {
                const data = {
                    groupId: context.params.groupId,
                    name: group.name,
                    email: element.email,
                    status: element.status,
                    requester: element.requester,
                    name_requester: element.name_requester,
                }
                const invitations = await admin.firestore().collection('invitations').where("email", "==", data.email).where("groupId", "==", data.groupId).get();
                if(invitations.docs.length < 1 ){
                    await admin.firestore().collection('invitations').add(data);
                }
                
            });
        }
    })


export const sendEmailInvitations = functions.firestore.document("/invitations/{invationId}")
    .onCreate(async (snapshot, context) => {
        functions.logger.log("init sendEmailInvitations");
        try {
            let transporter = nodemailer.createTransport({
                service: 'gmail',
                auth: {
                    user: 'gcmsolucoesdiadia@gmail.com',
                    pass: 'dani2019'
                }
            });


            const val = snapshot.data();
            const mailOptions = {
                from: 'SUM APP<noreply@firebase.com>', // Something like: Jane Doe <janedoe@gmail.com>
                to: val.email,
                subject: 'OLá, você foi convidado para partipar do grupo', // email subject
                html: `<p style="font-size: 16px;">Baixe nosso aplicativo e cadastre-se.</p>
            <br />
        ` // email content in HTML
            };


            await transporter.sendMail(mailOptions);
            functions.logger.log("E-MAIL ENVIADO COM SUCESSO");
        } catch (error) {
            functions.logger.log("ERRO AO ENVIAR E-MAIL", error);
        }
        return null;
    });

export const onCreateGroupsInNewUsers = functions.firestore.document("/users/{userId}")
    .onCreate(async (snapshot, context) => {
        try {
            const user: any = snapshot.data();
            var invitationsData = await admin.firestore().collection('invitations').where('email', '==', user.email);
            await invitationsData.get().then(function (querySnapshot) {
                querySnapshot.forEach(async function (doc) {
                    await admin.firestore().collection('users').doc(context.params.userId).collection('groups').add(doc.data());
                });
            });

        } catch (error) {
            functions.logger.error("erro ao salvar os documentos", error);
        }


    })

// export const onChangeGroupsByUsers = functions.firestore.document('/users/{userUid}/groups/{groupId}')
//     .onUpdate(async (snapshot, context) => {
//         try {
//             let data = snapshot.after.data();
//             if(data.status === 2 || data.status === 3) {
//                 let groupId = data.groupId;
//                 let email = data.email;
//
//                 var invitationsData = await admin.firestore().collection('groups').doc(groupId);
//                 await invitationsData.get().then(async function (querySnapshot: any) {
//                     let dataUser = querySnapshot.data();
//                     let users: any = dataUser.users;
//                     let findUser = users.find((element: any) => element.email.toString() === email.toString());
//                     await invitationsData.update({
//                         users: admin.firestore.FieldValue.arrayRemove(findUser),
//                     })
//                 });
//
//                 await invitationsData.update({
//                     users: admin.firestore.FieldValue.arrayUnion(data),
//                 })
//                 functions.logger.error("Atualizado com sucesso");
//             }
//
//         } catch (error) {
//             functions.logger.error("erro ao salvar os documentos", error);
//         }
//
//
//     });

    async function notififyUserGroup( userId: string, msg: string) {

        functions.logger.info(`Pus MSG: ${msg}`);
        const tokens: string[] = await notification.getDeviceTokens(userId);
        functions.logger.info(`Sending push to ${userId} with tokens ${tokens}`);
        await notification.sendPushFCM(tokens, 'Grupo', msg);
    
    }
    