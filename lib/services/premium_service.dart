import 'package:flutter/material.dart';

/// Tracks whether the (demo) user has subscribed to Premium. No real
/// payment is ever processed — this is a UI-only flag so the rest of the
/// app (the Profile banner, etc.) can react to subscription state.
class PremiumService {
  static ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);
}
