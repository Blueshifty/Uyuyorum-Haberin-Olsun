class Message {
  int _id;
  String _contactName;
  String _message;

  Message(this._contactName, this._message);

  Message.map(dynamic obj) {
    this._id = obj['id'];
    this._contactName = obj['contactName'];
    this._message = obj['message'];
  }

  int get id => _id;

  String get contactName => _contactName;

  String get message => _message;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['contactName'] = _contactName;
    map['message'] = _message;

    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._contactName = map['contactName'];
    this._message = map['message'];
  }
}
