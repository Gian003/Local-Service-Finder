import 'package:flutter/material.dart';

/// Returns a NetworkImage for [url], or null if it's missing/empty.
///
/// The backend sometimes sends an empty string rather than a JSON null for
/// an unset photo — NetworkImage('') throws ("No host specified in URI"),
/// so every avatar in the app needs this instead of a plain `!= null` check.
ImageProvider<Object>? safeNetworkImage(String? url) {
  if (url == null || url.isEmpty) return null;
  return NetworkImage(url);
}
