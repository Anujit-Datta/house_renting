class Contract {
  final String id;
  final String contractId;
  final int tenantId;
  final int landlordId;
  final int propertyId;
  final int? rentalRequestId;
  final Map<String, dynamic> contractData;
  final String contractHash;
  final String? pdfFilename;
  final String? pdfFilepath;
  final String? verificationUrl;
  final String? qrCodeData;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? activatedAt;
  final DateTime? tenantSignedAt;
  final DateTime? landlordSignedAt;
  final String? tenantSignature;
  final String? landlordSignature;
  final Map<String, dynamic>? property;
  final Map<String, dynamic>? tenant;
  final Map<String, dynamic>? landlord;
  final Map<String, dynamic>? terms;

  Contract({
    required this.id,
    required this.contractId,
    required this.tenantId,
    required this.landlordId,
    required this.propertyId,
    this.rentalRequestId,
    required this.contractData,
    required this.contractHash,
    this.pdfFilename,
    this.pdfFilepath,
    this.verificationUrl,
    this.qrCodeData,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.activatedAt,
    this.tenantSignedAt,
    this.landlordSignedAt,
    this.tenantSignature,
    this.landlordSignature,
    this.property,
    this.tenant,
    this.landlord,
    this.terms,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id']?.toString() ?? '',
      contractId: json['contract_id'] ?? '',
      tenantId: json['tenant_id'] ?? 0,
      landlordId: json['landlord_id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      rentalRequestId: json['rental_request_id'],
      contractData: json['contract_data'] ?? {},
      contractHash: json['contract_hash'] ?? '',
      pdfFilename: json['pdf_filename'],
      pdfFilepath: json['pdf_filepath'],
      verificationUrl: json['verification_url'],
      qrCodeData: json['qr_code_data'],
      status: json['status'] ?? 'pending_signatures',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'])
          : null,
      tenantSignedAt: json['tenant_signed_at'] != null
          ? DateTime.parse(json['tenant_signed_at'])
          : null,
      landlordSignedAt: json['landlord_signed_at'] != null
          ? DateTime.parse(json['landlord_signed_at'])
          : null,
      tenantSignature: json['tenant_signature'],
      landlordSignature: json['landlord_signature'],
      property: json['property'],
      tenant: json['tenant'],
      landlord: json['landlord'],
      terms: json['terms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_id': contractId,
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'property_id': propertyId,
      'rental_request_id': rentalRequestId,
      'contract_data': contractData,
      'contract_hash': contractHash,
      'pdf_filename': pdfFilename,
      'pdf_filepath': pdfFilepath,
      'verification_url': verificationUrl,
      'qr_code_data': qrCodeData,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'tenant_signed_at': tenantSignedAt?.toIso8601String(),
      'landlord_signed_at': landlordSignedAt?.toIso8601String(),
      'tenant_signature': tenantSignature,
      'landlord_signature': landlordSignature,
      'property': property,
      'tenant': tenant,
      'landlord': landlord,
      'terms': terms,
    };
  }

  String get formattedStartDate {
    try {
      final date = DateTime.parse(terms?['start_date'] ?? '');
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return terms?['start_date'] ?? 'N/A';
    }
  }

  String get formattedEndDate {
    try {
      final date = DateTime.parse(terms?['end_date'] ?? '');
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return terms?['end_date'] ?? 'N/A';
    }
  }

  String get formattedMonthlyRent {
    return 'Tk ${(terms?['monthly_rent'] ?? 0).toStringAsFixed(0)}';
  }

  String get formattedSecurityDeposit {
    return 'Tk ${(terms?['security_deposit'] ?? 0).toStringAsFixed(0)}';
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending_signatures':
        return 'Pending Signatures';
      case 'partially_signed':
        return 'Partially Signed';
      case 'fully_signed':
        return 'Fully Signed';
      case 'active':
        return 'Active';
      case 'terminated':
        return 'Terminated';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending_signatures':
        return '#FFA726';
      case 'partially_signed':
        return '#FFC107';
      case 'fully_signed':
        return '#66BB6A';
      case 'active':
        return '#27AE60';
      case 'terminated':
        return '#E74C3C';
      case 'cancelled':
        return '#95A5A6';
      default:
        return '#9E9E9E';
    }
  }

  bool get isFullySigned {
    return tenantSignature != null && landlordSignature != null;
  }

  bool get isActive {
    return status.toLowerCase() == 'active' ||
        status.toLowerCase() == 'fully_signed';
  }

  bool get isTenantSigned {
    return tenantSignature != null;
  }

  bool get isLandlordSigned {
    return landlordSignature != null;
  }

  // Convenience getters for contract terms
  double get monthlyRent {
    final rent = terms?['monthly_rent'] ?? contractData['monthly_rent'] ?? 0;
    return (rent is num) ? rent.toDouble() : 0.0;
  }

  double get securityDeposit {
    final deposit = terms?['security_deposit'] ?? contractData['security_deposit'] ?? 0;
    return (deposit is num) ? deposit.toDouble() : 0.0;
  }

  String? get propertyName {
    return property?['property_name'] ?? property?['name'] ?? contractData['property_name'];
  }

  String? get propertyAddress {
    return property?['location'] ?? property?['address'] ?? contractData['property_address'];
  }

  String? get tenantName {
    return tenant?['name'] ?? contractData['tenant_name'];
  }

  String? get landlordName {
    return landlord?['name'] ?? contractData['landlord_name'];
  }

  int? get durationMonths {
    return terms?['duration_months'] ?? contractData['duration_months'];
  }

  int? get paymentDay {
    return terms?['payment_day'] ?? contractData['payment_day'];
  }

  Contract copyWith({
    String? id,
    String? contractId,
    int? tenantId,
    int? landlordId,
    int? propertyId,
    int? rentalRequestId,
    Map<String, dynamic>? contractData,
    String? contractHash,
    String? pdfFilename,
    String? pdfFilepath,
    String? verificationUrl,
    String? qrCodeData,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? activatedAt,
    DateTime? tenantSignedAt,
    DateTime? landlordSignedAt,
    String? tenantSignature,
    String? landlordSignature,
    Map<String, dynamic>? property,
    Map<String, dynamic>? tenant,
    Map<String, dynamic>? landlord,
    Map<String, dynamic>? terms,
  }) {
    return Contract(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      propertyId: propertyId ?? this.propertyId,
      rentalRequestId: rentalRequestId ?? this.rentalRequestId,
      contractData: contractData ?? this.contractData,
      contractHash: contractHash ?? this.contractHash,
      pdfFilename: pdfFilename ?? this.pdfFilename,
      pdfFilepath: pdfFilepath ?? this.pdfFilepath,
      verificationUrl: verificationUrl ?? this.verificationUrl,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activatedAt: activatedAt ?? this.activatedAt,
      tenantSignedAt: tenantSignedAt ?? this.tenantSignedAt,
      landlordSignedAt: landlordSignedAt ?? this.landlordSignedAt,
      tenantSignature: tenantSignature ?? this.tenantSignature,
      landlordSignature: landlordSignature ?? this.landlordSignature,
      property: property ?? this.property,
      tenant: tenant ?? this.tenant,
      landlord: landlord ?? this.landlord,
      terms: terms ?? this.terms,
    );
  }

  @override
  String toString() {
    return 'Contract(id: $id, contractId: $contractId, status: $status)';
  }
}

class Payment {
  final int id;
  final int rentalId;
  final int contractId;
  final double amount;
  final String currency;
  final String status;
  final DateTime paymentDate;
  final DateTime dueDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.rentalId,
    required this.contractId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentDate,
    required this.dueDate,
    this.paymentMethod,
    this.transactionId,
    this.receiptUrl,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      rentalId: json['rental_id'] ?? 0,
      contractId: json['contract_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BDT',
      status: json['status'] ?? 'pending',
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      receiptUrl: json['receipt_url'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rental_id': rentalId,
      'contract_id': contractId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_date': paymentDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'receipt_url': receiptUrl,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA726';
      case 'paid':
        return '#66BB6A';
      case 'overdue':
        return '#E74C3C';
      case 'failed':
        return '#F44336';
      case 'cancelled':
        return '#9E9E9E';
      default:
        return '#9E9E9E';
    }
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status.toLowerCase() != 'paid';
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isPaid {
    return status.toLowerCase() == 'paid';
  }

  bool get isConfirmed {
    return status.toLowerCase() == 'paid' ||
        status.toLowerCase() == 'confirmed';
  }

  bool get isRejected {
    return status.toLowerCase() == 'rejected' ||
        status.toLowerCase() == 'failed';
  }

  bool get hasReceipt {
    return receiptUrl != null && receiptUrl!.isNotEmpty;
  }

  String get paymentMethodText {
    if (paymentMethod == null) return 'N/A';
    // Capitalize first letter
    return paymentMethod![0].toUpperCase() + paymentMethod!.substring(1);
  }

  Payment copyWith({
    int? id,
    int? rentalId,
    int? contractId,
    double? amount,
    String? currency,
    String? status,
    DateTime? paymentDate,
    DateTime? dueDate,
    String? paymentMethod,
    String? transactionId,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      rentalId: rentalId ?? this.rentalId,
      contractId: contractId ?? this.contractId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      dueDate: dueDate ?? this.dueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, amount: $amount, status: $status)';
  }
}

class RentalRequest {
  final int id;
  final int propertyId;
  final int? unitId; // Added
  final int tenantId;
  final String propertyName; // Added
  final String tenantName; // Added
  final String tenantEmail; // Added
  final String? tenantPhone; // Added
  final String? nationalId; // Added
  final String moveInDate; // Added (was implicit or missing)
  final int rentalDuration; // Added
  final double monthlyRent; // Added
  final double securityDeposit; // Added
  final String? paymentMethod; // Added
  final bool hasPets; // Added
  final String? currentAddress; // Added
  final int? numOccupants; // Added
  final String? occupation; // Added
  final String? emergencyContact; // Added
  final String? emergencyPhone; // Added
  final String? notes; // Added
  final String? messageToLandlord;
  final String status;
  final DateTime? approvedAt;
  final DateTime requestDate; // Renamed from createdAt/updatedAt logic
  final List<String>? documents; // Added
  final String? documentPath; // Added
  final Map<String, dynamic> property;
  final Map<String, dynamic>? unit; // Added
  final Map<String, dynamic> tenant;

  RentalRequest({
    required this.id,
    required this.propertyId,
    this.unitId,
    required this.tenantId,
    required this.propertyName,
    required this.tenantName,
    required this.tenantEmail,
    this.tenantPhone,
    this.nationalId,
    required this.moveInDate,
    required this.rentalDuration,
    required this.monthlyRent,
    required this.securityDeposit,
    this.paymentMethod,
    required this.hasPets,
    this.currentAddress,
    this.numOccupants,
    this.occupation,
    this.emergencyContact,
    this.emergencyPhone,
    this.notes,
    this.messageToLandlord,
    required this.status,
    this.approvedAt,
    required this.requestDate,
    this.documents,
    this.documentPath,
    required this.property,
    this.unit,
    required this.tenant,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      unitId: json['unit_id'],
      tenantId: json['tenant_id'] ?? 0,
      propertyName: json['property_name'] ?? '',
      tenantName: json['tenant_name'] ?? '',
      tenantEmail: json['tenant_email'] ?? '',
      tenantPhone: json['tenant_phone'],
      nationalId: json['national_id'],
      moveInDate: json['move_in_date'] ?? '',
      rentalDuration: json['rental_duration'] ?? 0,
      monthlyRent: (json['monthly_rent'] ?? 0).toDouble(),
      securityDeposit: (json['security_deposit'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'],
      hasPets: json['has_pets'] ?? false,
      currentAddress: json['current_address'],
      numOccupants: json['num_occupants'],
      occupation: json['occupation'],
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      notes: json['notes'],
      messageToLandlord: json['message_to_landlord'],
      status: json['status'] ?? 'pending',
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      requestDate: json['request_date'] != null
          ? DateTime.parse(json['request_date'])
          : DateTime.now(),
      documents: json['documents'] != null
          ? List<String>.from(json['documents'])
          : null,
      documentPath: json['document_path'],
      property: json['property'] ?? {},
      unit: json['unit'],
      tenant: json['tenant'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'unit_id': unitId,
      'tenant_id': tenantId,
      'property_name': propertyName,
      'tenant_name': tenantName,
      'tenant_email': tenantEmail,
      'tenant_phone': tenantPhone,
      'national_id': nationalId,
      'move_in_date': moveInDate,
      'rental_duration': rentalDuration,
      'monthly_rent': monthlyRent,
      'security_deposit': securityDeposit,
      'payment_method': paymentMethod,
      'has_pets': hasPets,
      'current_address': currentAddress,
      'num_occupants': numOccupants,
      'occupation': occupation,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'notes': notes,
      'message_to_landlord': messageToLandlord,
      'status': status,
      'approved_at': approvedAt?.toIso8601String(),
      'request_date': requestDate.toIso8601String(),
      'documents': documents,
      'document_path': documentPath,
      'property': property,
      'unit': unit,
      'tenant': tenant,
    };
  }

  String get formattedMoveInDate {
    try {
      final date = DateTime.parse(moveInDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return moveInDate;
    }
  }

  String get formattedMonthlyRent {
    return 'Tk ${monthlyRent.toStringAsFixed(0)}';
  }

  String get formattedSecurityDeposit {
    return 'Tk ${securityDeposit.toStringAsFixed(0)}';
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'accepted':
        return 'Accepted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA726';
      case 'approved':
      case 'accepted':
        return '#66BB6A';
      case 'rejected':
        return '#EF5350';
      case 'cancelled':
        return '#78909C';
      default:
        return '#9E9E9E';
    }
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isAccepted {
    return status.toLowerCase() == 'accepted' ||
        status.toLowerCase() == 'approved';
  }

  bool get isRejected {
    return status.toLowerCase() == 'rejected';
  }

  RentalRequest copyWith({
    int? id,
    int? propertyId,
    int? unitId,
    int? tenantId,
    String? propertyName,
    String? tenantName,
    String? tenantEmail,
    String? tenantPhone,
    String? nationalId,
    String? moveInDate,
    int? rentalDuration,
    double? monthlyRent,
    double? securityDeposit,
    String? paymentMethod,
    bool? hasPets,
    String? currentAddress,
    int? numOccupants,
    String? occupation,
    String? emergencyContact,
    String? emergencyPhone,
    String? notes,
    String? messageToLandlord,
    String? status,
    DateTime? approvedAt,
    DateTime? requestDate,
    List<String>? documents,
    String? documentPath,
    Map<String, dynamic>? property,
    Map<String, dynamic>? unit,
    Map<String, dynamic>? tenant,
  }) {
    return RentalRequest(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      unitId: unitId ?? this.unitId,
      tenantId: tenantId ?? this.tenantId,
      propertyName: propertyName ?? this.propertyName,
      tenantName: tenantName ?? this.tenantName,
      tenantEmail: tenantEmail ?? this.tenantEmail,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      nationalId: nationalId ?? this.nationalId,
      moveInDate: moveInDate ?? this.moveInDate,
      rentalDuration: rentalDuration ?? this.rentalDuration,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      hasPets: hasPets ?? this.hasPets,
      currentAddress: currentAddress ?? this.currentAddress,
      numOccupants: numOccupants ?? this.numOccupants,
      occupation: occupation ?? this.occupation,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      notes: notes ?? this.notes,
      messageToLandlord: messageToLandlord ?? this.messageToLandlord,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      requestDate: requestDate ?? this.requestDate,
      documents: documents ?? this.documents,
      documentPath: documentPath ?? this.documentPath,
      property: property ?? this.property,
      unit: unit ?? this.unit,
      tenant: tenant ?? this.tenant,
    );
  }
}
