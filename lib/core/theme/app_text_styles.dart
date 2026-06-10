import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // ── Display — 34px ────────────────────────────────────
  static const display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.12,
    color: AppColors.ink,
  );

  // ── H1 — 27px ─────────────────────────────────────────
  static const h1 = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.ink,
  );

  // ── H2 — 22px ─────────────────────────────────────────
  static const h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
    color: AppColors.ink,
  );

  // ── H3 — 18px ─────────────────────────────────────────
  static const h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.ink,
  );

  // ── Body — 16px ───────────────────────────────────────
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.ink,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.ink,
  );

  static const bodySemiBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.ink,
  );

  // ── Small — 14px ──────────────────────────────────────
  static const small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.ink2,
  );

  static const smallMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AppColors.ink2,
  );

  static const smallSemiBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    color: AppColors.ink,
  );

  // ── XS — 12.5px ───────────────────────────────────────
  static const xs = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink3,
  );

  static const xsMedium = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink3,
  );

  static const xsSemiBold = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.ink2,
  );

  // ── Navigation label ──────────────────────────────────
  static const navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ── Button ────────────────────────────────────────────
  static const btnLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1,
  );

  // ── XP Badge ──────────────────────────────────────────
  static const xpBadge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.amber,
  );

  // ── Level badge ───────────────────────────────────────
  static const levelBadge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: AppColors.onCoral,
    letterSpacing: 0,
  );
}
