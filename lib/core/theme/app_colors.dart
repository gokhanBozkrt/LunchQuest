import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand — Coral (Primary) ────────────────────────────
  static const coral = Color(0xFFE8490F);
  static const coral600 = Color(0xFFCF3D09);
  static const coral700 = Color(0xFFB23408);
  static const coralTint = Color(0xFFFCEBE2);
  static const coralTint2 = Color(0xFFFBDFD2);
  static const onCoral = Color(0xFFFFFFFF);

  // ── Brand — Navy (Secondary) ───────────────────────────
  static const navy = Color(0xFF1A1F36);
  static const navy600 = Color(0xFF2E3658);
  static const navy700 = Color(0xFF232A47);
  static const onNavy = Color(0xFFFFFFFF);

  // ── Accent — Amber ─────────────────────────────────────
  static const amber = Color(0xFFF4A52A);
  static const amberTint = Color(0xFFFDF1DC);

  // ── Accent — Green ─────────────────────────────────────
  static const green = Color(0xFF16A34A);
  static const greenTint = Color(0xFFE4F6EB);

  // ── Accent — Violet (AI) ───────────────────────────────
  static const violet = Color(0xFF6C5CE7);
  static const violetTint = Color(0xFFEEEBFC);

  // ── Neutral ────────────────────────────────────────────
  static const bg = Color(0xFFF7F5F0);
  static const card = Color(0xFFFFFFFF);
  static const cardSunken = Color(0xFFF3F0E9);

  // ── Text / Ink ─────────────────────────────────────────
  static const ink = Color(0xFF1A1F36);       // primary text
  static const ink2 = Color(0xFF5B6178);      // secondary text
  static const ink3 = Color(0xFF8B91A4);      // tertiary / placeholder

  // ── Border ─────────────────────────────────────────────
  static const border = Color(0xFFECE7DC);
  static const borderStrong = Color(0xFFE1DBCD);

  // ── Shadow ─────────────────────────────────────────────
  static const shadowSm = Color(0x0F1A1F36);
  static const shadowMd = Color(0x141A1F36);
  static const shadowLg = Color(0x1E1A1F36);
  static const shadowCoral = Color(0x52E8490F);
  static const shadowNavy = Color(0x471A1F36);

  // ── Overlay ────────────────────────────────────────────
  static const overlay12 = Color(0x1F1A1F36);
  static const overlay45 = Color(0x731A1F36);

  // ── Status ─────────────────────────────────────────────
  static const statusActive = Color(0xFF16A34A);
  static const statusFull = Color(0xFFF4A52A);
  static const statusDone = Color(0xFF8B91A4);

  // ── White variants ─────────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const white86 = Color(0xDBFFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white18 = Color(0x2EFFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white06 = Color(0x0FFFFFFF);
}
