// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtPaymentAdapter extends TypeAdapter<DebtPayment> {
  @override
  final int typeId = 6;

  @override
  DebtPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtPayment(
      id: fields[0] as String,
      amount: fields[1] as int,
      paymentMethod: fields[2] as String,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DebtPayment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.paymentMethod)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleItemEntryAdapter extends TypeAdapter<SaleItemEntry> {
  @override
  final int typeId = 7;

  @override
  SaleItemEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItemEntry(
      productId: fields[0] as String,
      productName: fields[1] as String,
      unit: fields[2] as String,
      quantity: fields[3] as int,
      sellingPrice: fields[4] as int,
      buyingPrice: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItemEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.sellingPrice)
      ..writeByte(5)
      ..write(obj.buyingPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RefundItemAdapter extends TypeAdapter<RefundItem> {
  @override
  final int typeId = 8;

  @override
  RefundItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RefundItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      unit: fields[2] as String,
      quantity: fields[3] as int,
      sellingPrice: fields[4] as int,
      buyingPrice: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RefundItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.sellingPrice)
      ..writeByte(5)
      ..write(obj.buyingPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefundItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RefundEntryAdapter extends TypeAdapter<RefundEntry> {
  @override
  final int typeId = 9;

  @override
  RefundEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RefundEntry(
      id: fields[0] as String,
      originalOrderNumber: fields[1] as String,
      items: (fields[2] as List).cast<RefundItem>(),
      refundAmount: fields[3] as int,
      date: fields[4] as DateTime,
      reason: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RefundEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalOrderNumber)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.refundAmount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefundEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleEntryAdapter extends TypeAdapter<SaleEntry> {
  @override
  final int typeId = 10;

  @override
  SaleEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleEntry(
      orderNumber: fields[0] as String,
      productName: fields[1] as String,
      amount: fields[2] as int,
      date: fields[3] as DateTime,
      paid: fields[4] as bool,
      paidAmount: fields[5] as int,
      customerName: fields[6] as String?,
      customerPhone: fields[7] as String?,
      sellerName: fields[8] as String,
      discount: fields[9] as int,
      note: fields[10] as String?,
      paymentMethod: fields[11] as String?,
      items: (fields[12] as List).cast<SaleItemEntry>(),
      payments: (fields[13] as List).cast<DebtPayment>(),
      isRefunded: fields[14] as bool,
      refundAmount: fields[15] as int,
      totalCogs: fields[16] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SaleEntry obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.orderNumber)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.paid)
      ..writeByte(5)
      ..write(obj.paidAmount)
      ..writeByte(6)
      ..write(obj.customerName)
      ..writeByte(7)
      ..write(obj.customerPhone)
      ..writeByte(8)
      ..write(obj.sellerName)
      ..writeByte(9)
      ..write(obj.discount)
      ..writeByte(10)
      ..write(obj.note)
      ..writeByte(11)
      ..write(obj.paymentMethod)
      ..writeByte(12)
      ..write(obj.items)
      ..writeByte(13)
      ..write(obj.payments)
      ..writeByte(14)
      ..write(obj.isRefunded)
      ..writeByte(15)
      ..write(obj.refundAmount)
      ..writeByte(16)
      ..write(obj.totalCogs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
