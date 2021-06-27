class ProductReports {
    String product;
    int quantity;
    int time;
    int fastestTime;
    int slowestTime;
    int avgTime;
    int sum;


    ProductReports({
    this.product,
    this.quantity,
    this.time,
      this.fastestTime,
      this.slowestTime,
      this.avgTime,
      this.sum
    });

    ProductReports.fromJson(Map<String, dynamic> json){
      product = json['product'];
      quantity = json['quantity'];
      time = json['time'];
    }

    ProductReports.fromJsonDB(Map<String, dynamic> json){
      product = json['product'];
      quantity = json['quantity'];
      time = json['time'];
      fastestTime = json['fastest'];
      slowestTime = json['slowest'];
      avgTime = json['avg_time'];
      sum = json['sum'];
    }

    Map<String, dynamic> toJson(){
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['product'] = product;
      data['quantity'] = quantity;
      data['time'] = time;
      return data;
    }

}

class ItemRanks {
  int quantity;
  String productName;
  List<int> fastestTime;
  List<int> slowestTime;
  List<int> averageTime;

  ItemRanks({
    this.quantity,
    this.productName,
    this.fastestTime,
    this.slowestTime,
    this.averageTime
  });
}