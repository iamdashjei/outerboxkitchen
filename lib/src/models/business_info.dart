class BusinessInfo {
  String businessName;
  String businessLogo;
  String cashierName;
  String merchantId;
  String salesId;
  String accountType;

  BusinessInfo({
    this.businessName,
    this.businessLogo,
    this.cashierName,
    this.merchantId,
    this.salesId,
    this.accountType
  });

  BusinessInfo.fromJson(Map<String, dynamic> json) {
    businessName = json['businessName'];
    businessLogo = json['businessLogo'];
    cashierName = json['cashierName'];
    merchantId = json['merchantId'];
    salesId = json['salesId'];
  }

  Map<String,dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['businessName'] = businessName;
    data['businessLogo'] = businessLogo;
    data['cashierName'] = cashierName;
    data['merchantId'] = merchantId;
    data['salesId'] = salesId;
    return data;
  }
}