import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
/// Based on Aurox-style brand identity: black wallet + orange & teal card gradient.
///
/// Dark mode surfaces follow a 4-level elevation system:
///   Level 0 (scaffold) → Level 1 (card) → Level 2 (modal) → Level 3 (nested)
class AppColors {
  AppColors._(); // Prevent instantiation

  // ── Brand Core ──────────────────────────────────────────────
  static const primaryBlack = Color(0xFF1A1A1A);
  static const background = Color(0xFFF5F6F7);
  static const surface = Color(0xFFFFFFFF);
  static const accentOrange = Color(0xFFF2994A);
  static const accentTeal = Color(0xFF0D9488);

  // ── Dark Mode Elevation System ──────────────────────────────
  // 4 level saja — dari scaffold sampai nested element
  static const darkScaffold = Color(0xFF090F0F);   // Level 0 — scaffold background
  static const darkCard = Color(0xFF131D1D);        // Level 1 — card / surface
  static const darkModal = Color(0xFF1E222B);       // Level 2 — modal / dialog / sheet
  static const darkElevated = Color(0xFF232732);    // Level 3 — nested card / chat bubble

  // ── Transaction ─────────────────────────────────────────────
  static const income = Color(0xFF0D9488);   // Selaras dengan Accent Teal logo
  static const expense = Color(0xFFDC2626);  // Merah standar universal

  // ── Semantic / State ────────────────────────────────────────
  static const error = Color(0xFFDC2626);    // Sama dengan expense
  static const warning = Color(0xFFF59E0B);  // Amber warning (pengganti Colors.amber)

  // ── Text ────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);

  // ── Category Colors ─────────────────────────────────────────
  // Income Family (nuansa Teal, sesuai brand)
  static const catGaji = Color(0xFF0D9488);
  static const catBonus = Color(0xFF14B8A6);
  static const catTerimaTransfer = Color(0xFF2C7A94);

  // Expense Family (variasi hangat & netral)
  static const catMakanan = Color(0xFFB8722E);       // Selaras Accent Orange logo
  static const catBelanja = Color(0xFFAE4277);
  static const catTagihan = Color(0xFFDC2626);
  static const catHiburan = Color(0xFF6C47C0);
  static const catTransportasi = Color(0xFF3B69B3);

  // Netral
  static const catTransfer = Color(0xFF4C46B9);      // Indigo, beda dari Transportasi
  static const catLainLain = Color(0xFF6B7280);

  // ── Snackbar ────────────────────────────────────────────────
  static const snackBarBackground = darkModal;        // Level 2
}
