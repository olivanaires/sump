import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import * as doctor_call from './doctor-call-functions';
import * as favorite_hospital from './favorite-hospital-functions';
import * as invitations from  './invitations';


admin.initializeApp(functions.config().firebase);

module.exports = {
    'onCreateDoctorCall': doctor_call.onCreateDoctorCall,
    'onUpdateDoctorCall': doctor_call.onUpdateDoctorCall,
    'onDeleteDoctorCall': doctor_call.onDeleteDoctorCall,
    'onAddFavoriteHospital': favorite_hospital.onAddFavoriteHospital,
    'onRemoveFavoriteHospital': favorite_hospital.onRemoveFavoriteHospital,
    'onCreateGroupInUser': invitations.onCreateGroupInUser,
    'sendEmailInvitations': invitations.sendEmailInvitations,
    'onCreateGroupsInNewUsers': invitations.onCreateGroupsInNewUsers,
    'onChangeGroupsByUsers': invitations.onChangeGroupsByUsers,
};
