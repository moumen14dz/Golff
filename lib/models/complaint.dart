class Complaint {
  final int id;
  final String title;
  final String createdBy;
  final String createdTo;
  final String type;
  final String date;

  Complaint({
    this.id,
    this.title,
    this.createdBy,
    this.createdTo,
    this.type,
    this.date,
  });
}

class User {
  final int id;
  final String name;
  final String phone;

  User({
    this.id,
    this.name,
    this.phone,
  });
}

class ComplaintMessage {
  final int id;
  final String createdBy;
  final String text;
  final String date;

  ComplaintMessage({
    this.id,
    this.createdBy,
    this.text,
    this.date,
  });
}
