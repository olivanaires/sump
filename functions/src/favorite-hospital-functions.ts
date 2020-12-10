import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onAddFavoriteHospital = functions.firestore.document('/users/{userUid}/favHospital/{hospitalUid}')
    .onCreate(async (snapshot, context) => {
        const userUid = context.params.userUid;
        const hospitalUid = context.params.hospitalUid;

        await admin.firestore().collection('hospitals')
            .doc(hospitalUid)
            .collection('favoritedByUsers')
            .doc(userUid).set({'userUid': userUid});

        functions.logger.info(`UserUID ${userUid} favoritou hospitalUID ${hospitalUid}`);
    });

export const onRemoveFavoriteHospital = functions.firestore.document('/users/{userUid}/favHospital/{hospitalUid}')
    .onDelete(async (snapshot, context) => {
        const userUid = context.params.userUid;
        const hospitalUid = context.params.hospitalUid;

        await admin.firestore().collection('hospitals')
            .doc(hospitalUid)
            .collection('favoritedByUsers')
            .doc(userUid).delete();

        functions.logger.info(`UserUID ${userUid} removeu hospitalUID ${hospitalUid} dos favoritos`);
    });