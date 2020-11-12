/*
 * 网络结果数据
 */
class ResultData {
  // ignore: non_constant_identifier_names
  var Data;
  // ignore: non_constant_identifier_names
  bool Success;
  // ignore: non_constant_identifier_names
  int Code;
  // ignore: non_constant_identifier_names
  String Message;
  // ignore: non_constant_identifier_names
  var PageInfo;
  var headers;
  ResultData(this.Data, this.Success, this.Code, this.Message,
      // ignore: non_constant_identifier_names
      {this.PageInfo,
      this.headers});

  Map<String, dynamic> toJson() => {
        "Data": Data,
        "Success": Success,
        "Code": Code,
        "Message": Message,
        "PageInfo": PageInfo,
        "headers": headers
      };
}
