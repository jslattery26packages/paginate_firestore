class User {
  User({
    required this.city,
    required this.country,
    required this.streetName,
    required this.zipCode,
    required this.prefix,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.number,
  });
  User.fromJson(Map<String, Object?> json)
      : this(
          city: json['city'].toString(),
          country: json['country'].toString(),
          streetName: json['streetName'].toString(),
          zipCode: json['zipCode'].toString(),
          prefix: json['prefix'].toString(),
          firstName: json['firstName'].toString(),
          lastName: json['lastName'].toString(),
          email: json['email'].toString(),
          userName: json['userName'].toString(),
          number: json['number'].toString(),
        );

  final String city;
  final String country;
  final String streetName;
  final String zipCode;

  final String prefix;
  final String firstName;
  final String lastName;

  final String email;
  final String userName;
  final String number;

  Map<String, Object?> toJson() {
    return {
      'city': city,
      'country': country,
      'streetName': streetName,
      'zipCode': zipCode,
      'prefix': prefix,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userName': userName,
      'number': number,
    };
  }
}
