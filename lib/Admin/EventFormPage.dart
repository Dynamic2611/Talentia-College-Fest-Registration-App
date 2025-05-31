import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventFormPage extends StatefulWidget {
  final DocumentSnapshot? eventData;

  EventFormPage({this.eventData});

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String? _eventName, _description, _category, _venue, _contactInfo, _isGroupEvent;
  double? _registrationFee;
  int? _maxParticipants;
  DateTime? _eventDate;
  TimeOfDay? _startTime;

  List<String> categories = ['Performing Arts', 'Literary Arts', 'Fine Arts', 'Preludes Events'];
  List<String> groupTypes = ['Solo', 'Duet', 'Group'];

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      final data = widget.eventData!.data() as Map<String, dynamic>;
      _eventName = data['name'];
      _description = data['description'];
      _category = data['category'];
      _venue = data['venue'];
      _registrationFee = (data['registrationFee'] as num).toDouble();
      _contactInfo = data['contactInfo'];
      _isGroupEvent = data['isGroupEvent'];
      _maxParticipants = data['maxParticipants'];
      _eventDate = DateTime.parse(data['eventDate']);
      final timeParts = data['startTime'].split(':');
      _startTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],  // Light grey background
      appBar: AppBar(
        title: Text(widget.eventData == null ? 'Add Event' : 'Update Event'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCard(
                  children: [
                    buildTextField('Event Name', _eventName, (value) => _eventName = value),
                    buildTextField('Description', _description, (value) => _description = value, maxLines: 3),
                    buildDropdown('Category', _category, categories, (value) => _category = value),
                    buildTextField('Venue', _venue, (value) => _venue = value),
                  ],
                ),
                buildCard(
                  children: [
                    buildTextField('Registration Fee', _registrationFee?.toString(), (value) => _registrationFee = double.parse(value!), keyboardType: TextInputType.number),
                    SizedBox(height: 10,),
                    buildDatePicker('Event Date', _eventDate, (pickedDate) => _eventDate = pickedDate),
                    SizedBox(height: 10,),
                    buildTimePicker('Start Time', _startTime, (pickedTime) => _startTime = pickedTime),
                    SizedBox(height: 10,),
                    buildTextField('Contact Information', _contactInfo, (value) => _contactInfo = value),
                  ],
                ),
                buildCard(
                  children: [
                    buildDropdown('Is Group Event?', _isGroupEvent, groupTypes, (value) => setState(() => _isGroupEvent = value)),
                    if (_isGroupEvent != null && _isGroupEvent != 'Solo')
                      buildTextField('Maximum Participants', _maxParticipants?.toString(), (value) => _maxParticipants = int.parse(value!), keyboardType: TextInputType.number),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                    child: Text(widget.eventData == null ? 'Add Event' : 'Update Event', style: TextStyle(fontSize: 18, color: Colors.white)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await addOrUpdateEvent();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard({required List<Widget> children}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: children),
      ),
    );
  }

  Widget buildTextField(String label, String? initialValue, Function(String?) onSaved, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'Required' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        validator: (value) => value == null ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildDatePicker(String label, DateTime? value, Function(DateTime) onPicked) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(value == null ? label : DateFormat.yMMMd().format(value)),
      trailing: Icon(Icons.calendar_today, color: Colors.deepOrangeAccent),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() => onPicked(pickedDate));
        }
      },
    );
  }

  Widget buildTimePicker(String label, TimeOfDay? value, Function(TimeOfDay) onPicked) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(value == null ? label : value.format(context)),
      trailing: Icon(Icons.access_time, color: Colors.deepOrangeAccent),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() => onPicked(pickedTime));
        }
      },
    );
  }

  Future<void> addOrUpdateEvent() async {
    DateTime eventDateTime = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    Map<String, dynamic> eventData = {
      'name': _eventName,
      'description': _description,
      'category': _category,
      'venue': _venue,
      'eventDate': eventDateTime.toIso8601String(),
      'startTime': '${_startTime!.hour}:${_startTime!.minute}',
      'registrationFee': _registrationFee,
      'contactInfo': _contactInfo,
      'isGroupEvent': _isGroupEvent,
      'maxParticipants': _isGroupEvent == 'Solo' ? 1 : _maxParticipants,
      'createdAt': FieldValue.serverTimestamp(),
      'totalAmount':0
    };

    widget.eventData == null ? await _firestore.collection('events').add(eventData) : await _firestore.collection('events').doc(widget.eventData!.id).update(eventData);
  }
}
