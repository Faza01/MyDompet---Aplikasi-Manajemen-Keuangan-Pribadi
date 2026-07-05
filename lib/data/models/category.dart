import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Category {
  final int? id;
  final String name;
  final String type; // 'income' | 'expense'
  final String? icon;
  final bool isDefault;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.isDefault = false,
  });

  Color get color {
    switch (icon) {
      // Teal Family
      case 'directions_car':
        return AppColors.catTransportasi;
      case 'work':
        return AppColors.catGaji;
      case 'card_giftcard':
        return AppColors.catBonus;
      case 'download':
        return AppColors.catTerimaTransfer;

      // Orange Family
      case 'shopping_bag':
        return AppColors.catBelanja;
      case 'restaurant':
        return AppColors.catMakanan;
      case 'sports_esports':
        return AppColors.catHiburan;

      // Gray Family
      case 'swap_horiz':
        return AppColors.catTransfer;
      case 'remove_circle':
      case 'add_circle':
        return AppColors.catLainLain;

      // Red semantic
      case 'receipt_long':
        return AppColors.catTagihan;

      default:
        return AppColors.catLainLain;
    }
  }

  Category copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String?,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }
}
