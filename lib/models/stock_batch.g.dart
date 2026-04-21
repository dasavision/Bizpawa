// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_batch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockBatchAdapter extends TypeAdapter<StockBatch> {
  @override
  final int typeId = 1;

  @override
  StockBatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockBatch(
      batchNumber: fields[0] as int,
      quantity: fields[1] as int,
      buyingPrice: fields[2] as int,
      sellingPrice: fields[3] as int,
      date: fields[4] as DateTime,
      remainingStock: fields[5] as int,
      batchBarcodeId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockBatch obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.batchNumber)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.buyingPrice)
      ..writeByte(3)
      ..write(obj.sellingPrice)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.remainingStock)
      ..writeByte(6)
      ..write(obj.batchBarcodeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockBatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
