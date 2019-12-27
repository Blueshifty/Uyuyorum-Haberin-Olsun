class Message {
  int _id;
  String _contactName;
  String _message;
  String _phoneNumber;

  Message(this._contactName, this._message, this._phoneNumber);

  Message.map(dynamic obj) {
    this._id = obj['id'];
    this._contactName = obj['contactName'];
    this._message = obj['message'];
    this._phoneNumber = obj['phoneNumber'];

  }

  int get id => _id;

  String get contactName => _contactName;

  String get message => _message;

  String get phoneNumber => _phoneNumber;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['contactName'] = _contactName;
    map['message'] = _message;
    map['phoneNumber'] = _phoneNumber;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._contactName = map['contactName'];
    this._message = map['message'];
    this._phoneNumber = map['phoneNumber'];
  }
}
