import 'package:sumpapp/model/user_model.dart';

class DoctorModel extends UserModel {
  String celPhone;
  String pix;

  String cpf;
  String crm;
  String uf;

  String street;
  String streetNumber;
  String neigborhood;
  String city;
  String state;
  String cep;

  String type = 'DOCTOR';

  DoctorModel();

  DoctorModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];

    name = map['name'];
    email = map['email'];
    celPhone = map['celPhone'];
    pix = map['pix'];

    cpf = map['cpf'];
    crm = map['crm'];
    uf = map['uf'];

    street = map['street'];
    streetNumber = map['streetNumber'];
    neigborhood = map['neigborhood'];
    city = map['city'];
    state = map['state'];
    cep = map['cep'];
    profileImgURL = map['profileImgURL'];

    type = map['type'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'celPhone': celPhone,
      'pix': pix,
      'cpf': cpf,
      'crm': crm,
      'uf': uf,
      'street': street,
      'streetNumber': streetNumber,
      'neigborhood': neigborhood,
      'city': city,
      'state': state,
      'cep': cep,
      'profileImgURL': profileImgURL,
      'type': type,
    };
  }
}
