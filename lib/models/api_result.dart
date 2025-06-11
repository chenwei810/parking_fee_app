// 停車費帳單明細
class ParkingBill {
  final String billNo;
  final String parkingDate;
  final String payLimitDate;
  final int billStatus;
  final double parkingHours;
  final int amount;
  final int payAmount;
  final String? location;

  ParkingBill({
    required this.billNo,
    required this.parkingDate,
    required this.payLimitDate,
    required this.billStatus,
    required this.parkingHours,
    required this.amount,
    required this.payAmount,
    this.location,
  });

  factory ParkingBill.fromJson(Map<String, dynamic> json) {
    // 處理可能的字符串金額或浮點數
    var amount = json['Amount'];
    int parsedAmount = 0;
    if (amount is int) {
      parsedAmount = amount;
    } else if (amount is double) {
      parsedAmount = amount.toInt();
    } else if (amount is String) {
      // 移除可能的逗號，然後嘗試轉換為數值
      if (amount.contains('.')) {
        // 如果包含小數點，則先解析為 double，再轉換為 int
        parsedAmount = double.tryParse(amount.replaceAll(',', ''))?.toInt() ?? 0;
      } else {
        parsedAmount = int.tryParse(amount.replaceAll(',', '')) ?? 0;
      }
    }

    // 處理可能的字符串金額或浮點數
    var payAmount = json['PayAmount'] ?? amount;
    int parsedPayAmount = 0;
    if (payAmount is int) {
      parsedPayAmount = payAmount;
    } else if (payAmount is double) {
      parsedPayAmount = payAmount.toInt();
    } else if (payAmount is String) {
      // 移除可能的逗號，然後嘗試轉換為數值
      if (payAmount.contains('.')) {
        // 如果包含小數點，則先解析為 double，再轉換為 int
        parsedPayAmount = double.tryParse(payAmount.replaceAll(',', ''))?.toInt() ?? 0;
      } else {
        parsedPayAmount = int.tryParse(payAmount.replaceAll(',', '')) ?? 0;
      }
    }

    // 處理停車時數
    var parkingHours = json['ParkingHours'] ?? -1;
    double parsedParkingHours = -1;
    if (parkingHours is int) {
      parsedParkingHours = parkingHours.toDouble();
    } else if (parkingHours is double) {
      parsedParkingHours = parkingHours;
    } else if (parkingHours is String) {
      parsedParkingHours = double.tryParse(parkingHours) ?? -1;
    }

    return ParkingBill(
      billNo: json['BillNo'] ?? '',
      parkingDate: json['ParkingDate'] ?? '',
      payLimitDate: json['PayLimitDate'] ?? '',
      billStatus: json['BillStatus'] is int ? json['BillStatus'] : int.tryParse(json['BillStatus'].toString()) ?? 0,
      parkingHours: parsedParkingHours,
      amount: parsedAmount,
      payAmount: parsedPayAmount,
      location: json['Location'],
    );
  }

  // 取得帳單狀態文字說明
  String get statusText {
    switch (billStatus) {
      case 0:
        return '未逾期';
      case 1:
        return '逾期轉催繳中';
      case 2:
        return '催繳';
      case 3:
        return '告發';
      default:
        return '未知狀態';
    }
  }
}

// 催繳單明細
class Reminder {
  final String reminderNo;
  final String reminderLimitDate;
  final int amount;
  final int extraCharge;
  final int payAmount;
  final List<ParkingBill> bills;
  final int isProsecuted;
  final String prosecuteLimitDate;

  Reminder({
    required this.reminderNo,
    required this.reminderLimitDate,
    required this.amount,
    required this.extraCharge,
    required this.payAmount,
    required this.bills,
    required this.isProsecuted,
    required this.prosecuteLimitDate,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    // 處理可能的字符串金額或浮點數
    var amount = json['Amount'];
    int parsedAmount = 0;
    if (amount is int) {
      parsedAmount = amount;
    } else if (amount is double) {
      parsedAmount = amount.toInt();
    } else if (amount is String) {
      if (amount.contains('.')) {
        parsedAmount = double.tryParse(amount.replaceAll(',', ''))?.toInt() ?? 0;
      } else {
        parsedAmount = int.tryParse(amount.replaceAll(',', '')) ?? 0;
      }
    }

    // 處理可能的工本費
    var extraCharge = json['ExtraCharge'] ?? 0;
    int parsedExtraCharge = 0;
    if (extraCharge is int) {
      parsedExtraCharge = extraCharge;
    } else if (extraCharge is double) {
      parsedExtraCharge = extraCharge.toInt();
    } else if (extraCharge is String) {
      if (extraCharge.contains('.')) {
        parsedExtraCharge = double.tryParse(extraCharge.replaceAll(',', ''))?.toInt() ?? 0;
      } else {
        parsedExtraCharge = int.tryParse(extraCharge.replaceAll(',', '')) ?? 0;
      }
    }

    // 處理應繳總金額
    var payAmount = json['PayAmount'] ?? (parsedAmount + parsedExtraCharge);
    int parsedPayAmount = 0;
    if (payAmount is int) {
      parsedPayAmount = payAmount;
    } else if (payAmount is double) {
      parsedPayAmount = payAmount.toInt();
    } else if (payAmount is String) {
      if (payAmount.contains('.')) {
        parsedPayAmount = double.tryParse(payAmount.replaceAll(',', ''))?.toInt() ?? 0;
      } else {
        parsedPayAmount = int.tryParse(payAmount.replaceAll(',', '')) ?? 0;
      }
    }

    // 解析催繳單所含的停車單
    List<ParkingBill> billsList = [];
    if (json['Bills'] != null) {
      billsList = List<ParkingBill>.from(
        (json['Bills'] as List).map((x) => ParkingBill.fromJson(x)),
      );
    }

    // 處理告發狀態
    var isProsecuted = json['IsProsecuted'] ?? 0;
    int parsedIsProsecuted = 0;
    if (isProsecuted is int) {
      parsedIsProsecuted = isProsecuted;
    } else if (isProsecuted is String) {
      parsedIsProsecuted = int.tryParse(isProsecuted) ?? 0;
    }

    return Reminder(
      reminderNo: json['ReminderNo'] ?? '',
      reminderLimitDate: json['ReminderLimitDate'] ?? '',
      amount: parsedAmount,
      extraCharge: parsedExtraCharge,
      payAmount: parsedPayAmount,
      bills: billsList,
      isProsecuted: parsedIsProsecuted,
      prosecuteLimitDate: json['ProsecuteLimitDate'] ?? '',
    );
  }

  // 取得告發狀態文字說明
  String get prosecutedStatusText {
    return isProsecuted == 1 ? '已告發' : '無告發';
  }
}

// API查詢結果
class ParkingBillResult {
  final String carId;
  final String carType;
  final int totalCount;
  final int totalAmount;
  final List<ParkingBill> bills;
  final List<Reminder> reminders;
  final String cityCode;
  final String authorityCode;
  final String updateTime;

  ParkingBillResult({
    required this.carId,
    required this.carType,
    required this.totalCount,
    required this.totalAmount,
    required this.bills,
    required this.reminders,
    required this.cityCode,
    required this.authorityCode,
    required this.updateTime,
  });

  factory ParkingBillResult.fromJson(Map<String, dynamic> json) {
    // 處理停車單
    List<ParkingBill> billList = [];
    if (json['Bills'] != null) {
      billList = List<ParkingBill>.from(
        (json['Bills'] as List).map((x) => ParkingBill.fromJson(x)),
      );
    }

    // 處理催繳單
    List<Reminder> reminderList = [];
    if (json['Reminders'] != null) {
      reminderList = List<Reminder>.from(
        (json['Reminders'] as List).map((x) => Reminder.fromJson(x)),
      );
    }

    // 處理可能的字符串金額或浮點數
    var totalAmount = json['TotalAmount'];
    int parsedAmount = 0;
    if (totalAmount is int) {
      parsedAmount = totalAmount;
    } else if (totalAmount is double) {
      parsedAmount = totalAmount.toInt();
    } else if (totalAmount is String) {
      // 移除可能的逗號，然後嘗試轉換為數值
      if (totalAmount.contains('.')) {
        // 如果包含小數點，則先解析為 double，再轉換為 int
        parsedAmount = double.tryParse(totalAmount.replaceAll(',', ''))?.toInt() ?? 0;
      } else {
        parsedAmount = int.tryParse(totalAmount.replaceAll(',', '')) ?? 0;
      }
    }

    var totalCount = json['TotalCount'];
    int parsedCount = 0;
    if (totalCount is int) {
      parsedCount = totalCount;
    } else if (totalCount is double) {
      parsedCount = totalCount.toInt();
    } else if (totalCount is String) {
      parsedCount = int.tryParse(totalCount.replaceAll(',', '')) ?? 0;
    }

    return ParkingBillResult(
      carId: json['CarID'] ?? '',
      carType: json['CarType'] ?? '',
      totalCount: parsedCount,
      totalAmount: parsedAmount,
      bills: billList,
      reminders: reminderList,
      cityCode: json['CityCode'] ?? '',
      authorityCode: json['AuthorityCode'] ?? '',
      updateTime: json['UpdateTime'] ?? '',
    );
  }

  // 獲取車種文字
  String get carTypeText {
    switch (carType) {
      case 'C':
        return '汽車';
      case 'M':
        return '機車';
      case 'O':
        return '其他';
      default:
        return '未知';
    }
  }
}

// 城市查詢結果
class CityQueryResult {
  final String city;
  final String status;
  final String message;
  final ParkingBillResult? result;
  final Map<String, dynamic>? rawResponse;

  CityQueryResult({
    required this.city,
    required this.status,
    required this.message,
    this.result,
    this.rawResponse,
  });

  bool get isSuccess => status == 'SUCCESS' || status == 'OK';
  bool get hasUnpaidBills => isSuccess && result != null && result!.totalCount > 0;

  factory CityQueryResult.fromJson(Map<String, dynamic> json) {
    return CityQueryResult(
      city: json['city'] ?? '',
      status: json['status'] ?? 'ERROR',
      message: json['message'] ?? '',
      result: json['result'] != null ? ParkingBillResult.fromJson(json['result']) : null,
      rawResponse: json['raw_response'],
    );
  }

  factory CityQueryResult.error(String city, String errorMessage) {
    return CityQueryResult(
      city: city,
      status: 'ERROR',
      message: errorMessage,
      result: null,
    );
  }
}