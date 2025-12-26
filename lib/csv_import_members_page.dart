// import_members_csv_xlsx_exact.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportMembersExactPage extends StatefulWidget {
  const ImportMembersExactPage({super.key});

  @override
  State<ImportMembersExactPage> createState() => _ImportMembersExactPageState();
}

class _ImportMembersExactPageState extends State<ImportMembersExactPage> {
  bool _running = false;
  int _written = 0;
  int _skipped = 0;
  String _log = "";

  static const String ROOT_COLLECTION = "All_Data";
  static const String ROOT_DOCUMENT = "Student_AUSTRC_ID";
  static const String SUB_COLLECTION = "Members";

  static const REQUIRED_HEADERS = [
    "ID",
    "Name",
    "Student ID",
    "Department",
    "Email",
  ];

  void _logMsg(String m) => setState(() => _log = "$m\n$_log");

  /// 🔒 CRITICAL FUNCTION
  /// Always return EXACT visible Excel value as String
  String _cellAsText(dynamic cellValue) {
    if (cellValue == null) return "";

    // Excel library gives:
    // - TextCellValue
    // - NumericCellValue
    // - FormulaCellValue
    // We convert EVERYTHING to STRING EXACTLY.

    // If already string-like
    final s = cellValue.toString();

    // Remove trailing ".0" ONLY if it was created by Excel numeric display
    // BUT keep original integer digits exactly
    if (s.endsWith(".0")) {
      final d = double.tryParse(s);
      if (d != null && d % 1 == 0) {
        return d.toInt().toString();
      }
    }

    return s.trim();
  }

  Future<void> _startImport() async {
    setState(() {
      _running = true;
      _written = 0;
      _skipped = 0;
      _log = "";
    });

    try {
      final pick = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
        withData: true,
      );

      if (pick == null || pick.files.isEmpty) return;

      final file = pick.files.single;
      final bytes = file.bytes!;
      final ext = file.extension!.toLowerCase();

      if (ext == 'csv') {
        await _importCsv(bytes);
      } else {
        await _importXlsx(bytes);
      }
    } catch (e) {
      _logMsg("ERROR: $e");
    } finally {
      setState(() => _running = false);
    }
  }

  // ================= CSV =================
  Future<void> _importCsv(Uint8List bytes) async {
    final csvStr = utf8.decode(bytes);
    final rows = const CsvToListConverter(eol: '\n').convert(csvStr);

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    _validateHeaders(headers);

    int h(String n) => headers.indexOf(n);

    final col = FirebaseFirestore.instance
        .collection(ROOT_COLLECTION)
        .doc(ROOT_DOCUMENT)
        .collection(SUB_COLLECTION);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    int ops = 0;
    int count = 0;

    for (int r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.every((e) => e.toString().trim().isEmpty)) continue;

      count++;
      final data = {
        "AUSTRC_ID": row[h("ID")].toString().trim(),
        "Name": row[h("Name")].toString().trim(),
        "AUST_ID": row[h("Student ID")].toString().trim(),
        "Department": row[h("Department")].toString().trim(),
        "Edu_Mail": row[h("Email")].toString().trim(),
      };

      batch.set(col.doc("Member_$count"), data);
      ops++;
      _written++;

      if (ops == 450) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        ops = 0;
      }
    }
    if (ops > 0) await batch.commit();
    _logMsg("CSV import complete: $_written records");
  }

  // ================= XLSX =================
  Future<void> _importXlsx(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first!;
    final headers = sheet.rows.first.map((c) => c!.value.toString().trim()).toList();
    _validateHeaders(headers);

    int h(String n) => headers.indexOf(n);

    final col = FirebaseFirestore.instance
        .collection(ROOT_COLLECTION)
        .doc(ROOT_DOCUMENT)
        .collection(SUB_COLLECTION);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    int ops = 0;
    int count = 0;

    for (int r = 1; r < sheet.rows.length; r++) {
      final row = sheet.rows[r];
      if (row.every((c) => _cellAsText(c?.value).isEmpty)) continue;

      count++;
      final data = {
        "AUSTRC_ID": _cellAsText(row[h("ID")]?.value),
        "Name": _cellAsText(row[h("Name")]?.value),
        "AUST_ID": _cellAsText(row[h("Student ID")]?.value),
        "Department": _cellAsText(row[h("Department")]?.value),
        "Edu_Mail": _cellAsText(row[h("Email")]?.value),
      };

      batch.set(col.doc("Member_$count"), data);
      ops++;
      _written++;

      if (ops == 450) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        ops = 0;
      }
    }
    if (ops > 0) await batch.commit();
    _logMsg("XLSX import complete: $_written records");
  }

  void _validateHeaders(List<String> headers) {
    final missing = REQUIRED_HEADERS.where((h) => !headers.contains(h)).toList();
    if (missing.isNotEmpty) {
      throw Exception("Missing columns: $missing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exact Excel → Firebase Import")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton(
            onPressed: _running ? null : _startImport,
            child: Text(_running ? "Importing..." : "Upload CSV / XLSX"),
          ),
          const SizedBox(height: 10),
          Text("Written: $_written  Skipped: $_skipped"),
          Expanded(child: SingleChildScrollView(child: Text(_log))),
        ]),
      ),
    );
  }
}
