import 'package:flutter/material.dart';

class ParticipantListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Participant List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Event')),
                  DataColumn(label: Text('Status')),
                ],
                rows: List.generate(10, (index) {
                  return DataRow(cells: [
                    DataCell(Text('Participant ${index + 1}')),
                    DataCell(Text('Event ${index + 1}')),
                    DataCell(Text('Registered')),
                  ]);
                }),
              ),
              ElevatedButton(
                onPressed: () {
                  // Export to CSV or Excel
                },
                child: Text('Export List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
