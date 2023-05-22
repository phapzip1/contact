class Call {
  late String callerId;
  late String callerName;
  late String callerAva;
  late String receiverId;
  late String receiverName;
  late String receiverAva;
  late bool video;
  late String token;
  late bool caller;

  Call.audio({
    required this.callerId,
    required this.callerAva,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAva,
    this.token = "",
    this.caller = true,
  }) {
    video = false;
  }

  Call.video({
    required this.callerId,
    required this.callerAva,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAva,
    this.token = "",
    this.caller = true,
  }) {
    video = true;
  }

  static Map<String, dynamic> toMap(Call call) {
    return {
      "caller_id": call.callerId,
      "caller_name": call.callerName,
      "caller_ava": call.callerAva,
      "receiver_id": call.receiverId,
      "receiver_name": call.receiverName,
      "receiver_ava": call.receiverAva,
      "token": call.token,
      "caller": call.caller,
      "video": call.video
    };
  }

  Call.fromMap(Map callMap) {
    callerId = callMap["caller_id"];
    callerName = callMap["caller_name"];
    callerAva = callMap["caller_ava"];
    receiverId = callMap["receiver_id"];
    receiverName = callMap["receiver_name"];
    receiverAva = callMap["receiver_ava"];
    token = callMap["token"];
    caller = callMap["caller"];
    video = callMap["video"];
  }
}
