import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportAndShareExcel(
    Map<String, dynamic> event, List<Map<String, dynamic>> participants) async {
  // Request permission (for Android)
  if (Platform.isAndroid) {
    if (!await Permission.manageExternalStorage.request().isGranted &&
        !await Permission.storage.request().isGranted) {
      print("❌ Storage permission denied");
      return;
    }
  }

  // Create Excel file
  var excel = Excel.createExcel();

  // ===== Sheet 1: Event Details =====
  Sheet sheet = excel['Event Details'];
  int rowIndex = 0;
  event.forEach((key, value) {
    sheet
      ..cell(CellIndex.indexByString("A${rowIndex + 1}")).value =
          TextCellValue(key.toString())
      ..cell(CellIndex.indexByString("B${rowIndex + 1}")).value =
          TextCellValue(value.toString());
    rowIndex++;
  });

  // ===== Sheet 2: Participants =====
  Sheet participantSheet = excel['Participants'];
  participantSheet
    ..cell(CellIndex.indexByString("A1")).value = TextCellValue("Type")
    ..cell(CellIndex.indexByString("B1")).value = TextCellValue("Name/Team Name")
    ..cell(CellIndex.indexByString("C1")).value = TextCellValue("Student ID")
    ..cell(CellIndex.indexByString("D1")).value = TextCellValue("Class");

  int pRow = 1;

  for (var p in participants) {
    if (p['type'] == 'Solo') {
      participantSheet
        ..cell(CellIndex.indexByString("A${pRow + 1}")).value =
            TextCellValue("Solo")
        ..cell(CellIndex.indexByString("B${pRow + 1}")).value =
            TextCellValue(p['name'].toString())
        ..cell(CellIndex.indexByString("C${pRow + 1}")).value =
            TextCellValue(p['studentID'].toString())
        ..cell(CellIndex.indexByString("D${pRow + 1}")).value =
            TextCellValue(p['class'].toString());
      pRow++;
    } else if (p['type'] == 'Team') {
      String teamName = p['teamName'];
      bool isFirst = true;

      for (var member in p['members']) {
        participantSheet
          ..cell(CellIndex.indexByString("A${pRow + 1}")).value =
              TextCellValue(isFirst ? "Team ($teamName)" : "")
          ..cell(CellIndex.indexByString("B${pRow + 1}")).value =
              TextCellValue(member['name'].toString())
          ..cell(CellIndex.indexByString("C${pRow + 1}")).value =
              TextCellValue(member['studentID'].toString())
          ..cell(CellIndex.indexByString("D${pRow + 1}")).value =
              TextCellValue(member['class'].toString());

        // Optional: bold and shaded header row for team
        if (isFirst) {
          CellStyle teamHeaderStyle = CellStyle(
            bold: true, // light yellow
          );

          for (int col = 0; col < 4; col++) {
            participantSheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: pRow))
                .cellStyle = teamHeaderStyle;
          }
        }

        isFirst = false;
        pRow++;
      }
    }
  }

  // ===== Save file =====
  final directory = await getTemporaryDirectory(); // use temporary for sharing
  String fileName = 'event_${event['name']}.xlsx';
  String filePath = '${directory.path}/$fileName';

  final File file = File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);

  print("✅ Excel file saved at: $filePath");

  // ===== Share the file =====
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Here is the Excel file for ${event['name']}',
  );
}
