class Invitation {
  final String id;
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String weddingTime;
  final String venueName;
  final String venueAddress;
  final String groomParents;
  final String brideParents;
  final String templateId;
  final String additionalInfo;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    required this.weddingTime,
    required this.venueName,
    required this.venueAddress,
    this.groomParents = '',
    this.brideParents = '',
    required this.templateId,
    this.additionalInfo = '',
    required this.createdAt,
  });

  factory Invitation.empty() => Invitation(
    id: '',
    groomName: '',
    brideName: '',
    weddingDate: DateTime.now(),
    weddingTime: '08:00',
    venueName: '',
    venueAddress: '',
    groomParents: '',
    brideParents: '',
    templateId: 'default',
    additionalInfo: '',
    createdAt: DateTime.now(),
  );

  factory Invitation.fromMap(String id, Map<String, dynamic> data) {
    return Invitation(
      id: id,
      groomName: data['groomName'] ?? '',
      brideName: data['brideName'] ?? '',
      weddingDate: DateTime.parse(data['weddingDate']),
      weddingTime: data['weddingTime'] ?? '08:00',
      venueName: data['venueName'] ?? '',
      venueAddress: data['venueAddress'] ?? '',
      groomParents: data['groomParents'] ?? '',
      brideParents: data['brideParents'] ?? '',
      templateId: data['templateId'] ?? 'default',
      additionalInfo: data['additionalInfo'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'groomName': groomName,
    'brideName': brideName,
    'weddingDate': weddingDate.toIso8601String(),
    'weddingTime': weddingTime,
    'venueName': venueName,
    'venueAddress': venueAddress,
    'groomParents': groomParents,
    'brideParents': brideParents,
    'templateId': templateId,
    'additionalInfo': additionalInfo,
    'createdAt': createdAt.toIso8601String(),
  };

  Invitation copyWith({
    String? groomName,
    String? brideName,
    DateTime? weddingDate,
    String? weddingTime,
    String? venueName,
    String? venueAddress,
    String? groomParents,
    String? brideParents,
    String? templateId,
    String? additionalInfo,
  }) =>
      Invitation(
        id: id,
        groomName: groomName ?? this.groomName,
        brideName: brideName ?? this.brideName,
        weddingDate: weddingDate ?? this.weddingDate,
        weddingTime: weddingTime ?? this.weddingTime,
        venueName: venueName ?? this.venueName,
        venueAddress: venueAddress ?? this.venueAddress,
        groomParents: groomParents ?? this.groomParents,
        brideParents: brideParents ?? this.brideParents,
        templateId: templateId ?? this.templateId,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        createdAt: createdAt,
      );
}
