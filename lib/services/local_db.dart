import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local cache for offline reads, and an outbox for writes made while
/// offline. Each cache table stores the raw API JSON per row (re-decoded via
/// the same *Model.fromJson used for live data) rather than a fully
/// normalized schema — this is a read-through cache, not a source of truth,
/// so it only needs to survive being overwritten wholesale on every
/// successful fetch.
class LocalDb {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'lsf_cache.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_services (
            id INTEGER PRIMARY KEY,
            json TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_bookings (
            id INTEGER PRIMARY KEY,
            scope TEXT NOT NULL,
            json TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_addresses (
            id INTEGER PRIMARY KEY,
            json TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE outbox (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT NOT NULL,
            method TEXT NOT NULL,
            body TEXT NOT NULL,
            idempotency_key TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  // ── Services ─────────────────────────────────────────────────────────────

  static Future<void> cacheServices(List<Map<String, dynamic>> services) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('cached_services');
      for (final service in services) {
        final id = service['id'];
        if (id == null) continue;
        await txn.insert('cached_services', {
          'id': id,
          'json': jsonEncode(service),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getCachedServices() async {
    final db = await _open();
    final rows = await db.query('cached_services');
    return rows
        .map((row) => jsonDecode(row['json'] as String) as Map<String, dynamic>)
        .toList();
  }

  // ── Bookings ─────────────────────────────────────────────────────────────

  static Future<void> cacheBookings(
    String scope,
    List<Map<String, dynamic>> bookings,
  ) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('cached_bookings', where: 'scope = ?', whereArgs: [scope]);
      for (final booking in bookings) {
        final id = booking['id'];
        if (id == null) continue;
        await txn.insert('cached_bookings', {
          'id': id,
          'scope': scope,
          'json': jsonEncode(booking),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getCachedBookings(String scope) async {
    final db = await _open();
    final rows = await db.query(
      'cached_bookings',
      where: 'scope = ?',
      whereArgs: [scope],
    );
    return rows
        .map((row) => jsonDecode(row['json'] as String) as Map<String, dynamic>)
        .toList();
  }

  // ── Addresses ────────────────────────────────────────────────────────────

  static Future<void> cacheAddresses(List<Map<String, dynamic>> addresses) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('cached_addresses');
      for (final address in addresses) {
        final id = address['id'];
        if (id == null) continue;
        await txn.insert('cached_addresses', {
          'id': id,
          'json': jsonEncode(address),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getCachedAddresses() async {
    final db = await _open();
    final rows = await db.query('cached_addresses');
    return rows
        .map((row) => jsonDecode(row['json'] as String) as Map<String, dynamic>)
        .toList();
  }

  // ── Outbox (queued writes made while offline) ───────────────────────────

  static Future<void> enqueue({
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
    required String idempotencyKey,
  }) async {
    final db = await _open();
    await db.insert('outbox', {
      'endpoint': endpoint,
      'method': method,
      'body': jsonEncode(body),
      'idempotency_key': idempotencyKey,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getOutbox() async {
    final db = await _open();
    return db.query('outbox', orderBy: 'id ASC');
  }

  static Future<void> removeFromOutbox(int id) async {
    final db = await _open();
    await db.delete('outbox', where: 'id = ?', whereArgs: [id]);
  }
}
