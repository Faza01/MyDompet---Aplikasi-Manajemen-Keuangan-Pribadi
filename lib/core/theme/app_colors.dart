import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
/// Based on Aurox-style brand identity: black wallet + orange & teal card gradient.
///
/// Dark mode surfaces follow a 4-level elevation system:
///   Level 0 (scaffold) → Level 1 (card) → Level 2 (modal) → Level 3 (nested)
class AppColors {
  AppColors._(); // Prevent instantiation

  // 5 Warna Kunci (Single Source of Truth)
  static const primaryBlack = Color(0xFF1A1A1A);
  static const accentTeal = Color(0xFF0D9488);
  static const accentOrange = Color(0xFFF2994A);
  static const neutralGray = Color(0xFF6B7280);
  static const semanticRed = Color(0xFFDC2626);

  // Background & Surface
  static const background = Color(0xFFF5F6F7);
  static const surface = Color(0xFFFFFFFF);

  // ── Dark Mode Elevation System ──────────────────────────────
  // 4 level saja — dari scaffold sampai nested element
  static const darkScaffold = Color(0xFF090F0F);   // Level 0 — scaffold background
  static const darkCard = Color(0xFF131D1D);        // Level 1 — card / surface
  static const darkModal = Color(0xFF1E222B);       // Level 2 — modal / dialog / sheet
  static const darkElevated = Color(0xFF232732);    // Level 3 — nested card / chat bubble

  // Transaction
  static const income = accentTeal;
  static const expense = semanticRed;

  // ── Semantic / State ────────────────────────────────────────
  static const error = semanticRed;
  static const warning = Color(0xFFF59E0B);  // Amber warning (pengganti Colors.amber)

  // Text
  static const textPrimary = primaryBlack;
  static const textSecondary = neutralGray;

  // ── Category Colors (Sophisticated Muted Palette) ───────────
  // Income — Fresh Teal variants
  static const catGaji = Color(0xFF34B8A8);           // Fresh Teal
  static const catBonus = Color(0xFF4ECDC4);          // Mint Teal
  static const catTerimaTransfer = Color(0xFF6BD9C5); // Light Jade

  // Expense — Unique color per category
  static const catBelanja = Color(0xFFE8845C);        // Warm Terracotta
  static const catMakanan = Color(0xFFE6A65D);        // Golden Sand
  static const catTagihan = Color(0xFFE05A5A);        // Soft Crimson
  static const catHiburan = Color(0xFFA78BDA);        // Lavender Mist
  static const catTransportasi = Color(0xFF5BA4D9);   // Sky Slate

  // Neutral
  static const catTransfer = Color(0xFF8B96A3);       // Steel Gray
  static const catLainLain = Color(0xFFA0AAB4);       // Mist Gray

  // ── Snackbar ────────────────────────────────────────────────
  static const snackBarBackground = darkModal;        // Level 2
}

enum CategoryType {
  gaji, bonus, terimaTransfer,
  makanan, belanja, tagihan, hiburan, transportasi,
  transfer, lainLain,
}

extension CategoryColorExtension on CategoryType {
  Color get color {
    switch (this) {
      // Teal Family
      case CategoryType.transportasi: return AppColors.catTransportasi;
      case CategoryType.gaji:          return AppColors.catGaji;
      case CategoryType.bonus:         return AppColors.catBonus;
      case CategoryType.terimaTransfer: return AppColors.catTerimaTransfer;

      // Orange Family
      case CategoryType.belanja:  return AppColors.catBelanja;
      case CategoryType.makanan:  return AppColors.catMakanan;
      case CategoryType.hiburan:  return AppColors.catHiburan;

      // Gray Family
      case CategoryType.transfer:  return AppColors.catTransfer;
      case CategoryType.lainLain:  return AppColors.catLainLain;

      // Red (semantic)
      case CategoryType.tagihan: return AppColors.catTagihan;
    }
  }
}
