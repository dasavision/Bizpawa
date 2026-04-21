// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellerPermissionsAdapter extends TypeAdapter<SellerPermissions> {
  @override
  final int typeId = 12;

  @override
  SellerPermissions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SellerPermissions(
      canRecordSales: fields[0] as bool,
      canDeleteOwnSales: fields[1] as bool,
      canViewOtherSales: fields[2] as bool,
      canDeleteOtherSales: fields[3] as bool,
      canBackdateSales: fields[4] as bool,
      canDeleteBackdatedSales: fields[5] as bool,
      canRefund: fields[6] as bool,
      canViewProducts: fields[7] as bool,
      canAddProduct: fields[8] as bool,
      canAddStock: fields[9] as bool,
      canViewBuyingPrice: fields[10] as bool,
      canDeleteProduct: fields[11] as bool,
      canEditProductPrice: fields[12] as bool,
      canEditProductInfo: fields[13] as bool,
      canViewProductHistory: fields[14] as bool,
      canPayDebt: fields[15] as bool,
      canViewAllDebts: fields[16] as bool,
      canRecordExpenses: fields[17] as bool,
      canDeleteOwnExpenses: fields[18] as bool,
      canViewOtherExpenses: fields[19] as bool,
      canDeleteOtherExpenses: fields[20] as bool,
      canDeleteBackdatedExpenses: fields[21] as bool,
      canViewDailyReport: fields[22] as bool,
      canViewSalesReport: fields[23] as bool,
      canViewDebtReport: fields[24] as bool,
      canViewProductReport: fields[25] as bool,
      canViewExpenseReport: fields[26] as bool,
      canViewProfitReport: fields[27] as bool,
      canViewCustomerReport: fields[28] as bool,
      canViewSalesAnalytics: fields[29] as bool,
      canViewProfitAnalytics: fields[30] as bool,
      canViewProductAnalytics: fields[31] as bool,
      canViewExpenseAnalytics: fields[32] as bool,
      canViewCustomerAnalytics: fields[33] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SellerPermissions obj) {
    writer
      ..writeByte(34)
      ..writeByte(0)
      ..write(obj.canRecordSales)
      ..writeByte(1)
      ..write(obj.canDeleteOwnSales)
      ..writeByte(2)
      ..write(obj.canViewOtherSales)
      ..writeByte(3)
      ..write(obj.canDeleteOtherSales)
      ..writeByte(4)
      ..write(obj.canBackdateSales)
      ..writeByte(5)
      ..write(obj.canDeleteBackdatedSales)
      ..writeByte(6)
      ..write(obj.canRefund)
      ..writeByte(7)
      ..write(obj.canViewProducts)
      ..writeByte(8)
      ..write(obj.canAddProduct)
      ..writeByte(9)
      ..write(obj.canAddStock)
      ..writeByte(10)
      ..write(obj.canViewBuyingPrice)
      ..writeByte(11)
      ..write(obj.canDeleteProduct)
      ..writeByte(12)
      ..write(obj.canEditProductPrice)
      ..writeByte(13)
      ..write(obj.canEditProductInfo)
      ..writeByte(14)
      ..write(obj.canViewProductHistory)
      ..writeByte(15)
      ..write(obj.canPayDebt)
      ..writeByte(16)
      ..write(obj.canViewAllDebts)
      ..writeByte(17)
      ..write(obj.canRecordExpenses)
      ..writeByte(18)
      ..write(obj.canDeleteOwnExpenses)
      ..writeByte(19)
      ..write(obj.canViewOtherExpenses)
      ..writeByte(20)
      ..write(obj.canDeleteOtherExpenses)
      ..writeByte(21)
      ..write(obj.canDeleteBackdatedExpenses)
      ..writeByte(22)
      ..write(obj.canViewDailyReport)
      ..writeByte(23)
      ..write(obj.canViewSalesReport)
      ..writeByte(24)
      ..write(obj.canViewDebtReport)
      ..writeByte(25)
      ..write(obj.canViewProductReport)
      ..writeByte(26)
      ..write(obj.canViewExpenseReport)
      ..writeByte(27)
      ..write(obj.canViewProfitReport)
      ..writeByte(28)
      ..write(obj.canViewCustomerReport)
      ..writeByte(29)
      ..write(obj.canViewSalesAnalytics)
      ..writeByte(30)
      ..write(obj.canViewProfitAnalytics)
      ..writeByte(31)
      ..write(obj.canViewProductAnalytics)
      ..writeByte(32)
      ..write(obj.canViewExpenseAnalytics)
      ..writeByte(33)
      ..write(obj.canViewCustomerAnalytics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerPermissionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 13;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      username: fields[3] as String,
      pin: fields[4] as String,
      roleString: fields[5] as String,
      permissions: fields[6] as SellerPermissions,
      mustChangePinOnFirstLogin: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.pin)
      ..writeByte(5)
      ..write(obj.roleString)
      ..writeByte(6)
      ..write(obj.permissions)
      ..writeByte(7)
      ..write(obj.mustChangePinOnFirstLogin)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
