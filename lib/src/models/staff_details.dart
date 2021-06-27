class StaffDetails {
  String id;
  String hOfficeId;
  String merchantId;
  String fName;
  String lName;
  String email;
  String role;
  String createdAt;

  StaffDetails({
    this.id,
    this.hOfficeId,
    this.merchantId,
    this.fName,
    this.lName,
    this.email,
    this.role,
    this.createdAt
  });

  StaffDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hOfficeId = json['hoffice_id'];
    merchantId = json['merchant_id'];
    fName = json['fname'];
    lName = json['lname'];
    email = json['email'];
    role = json['role'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['hoffice_id'] = hOfficeId;
    data['merchant_id'] = merchantId;
    data['fname'] = fName;
    data['lname'] = lName;
    data['email'] = email;
    data['role'] = role;
    data['created_at'] = createdAt;
    return data;
  }

}