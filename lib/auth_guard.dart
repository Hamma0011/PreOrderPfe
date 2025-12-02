import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return const RouteSettings(name: '/login');
    return null; // ok, on reste sur la route demandée
  }
}
