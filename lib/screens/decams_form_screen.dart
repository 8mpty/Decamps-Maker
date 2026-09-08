import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuas_decamps_maker/models/personnel_model.dart';
import 'package:tuas_decamps_maker/models/time_data.dart';
import 'package:tuas_decamps_maker/screens/home_screen.dart';
import 'package:tuas_decamps_maker/services/calculate_service.dart';
import 'package:tuas_decamps_maker/services/storage_service.dart';
import 'package:tuas_decamps_maker/utils/form_validators.dart';
import 'package:tuas_decamps_maker/widgets/calculated_results_card.dart';
import 'package:tuas_decamps_maker/widgets/decams_form_fields.dart';
import 'package:tuas_decamps_maker/widgets/incident_details_section.dart';
import 'package:tuas_decamps_maker/widgets/remarks_section.dart';
import 'package:tuas_decamps_maker/widgets/time_section.dart';

class DecamsFormScreen extends StatefulWidget {
  const DecamsFormScreen({super.key});

  @override
  State<DecamsFormScreen> createState() => _DecamsFormScreenState();
}

class _DecamsFormScreenState extends State<DecamsFormScreen> {
  final StorageService _storageService = StorageService();
  
  String? _selectedAppliance;
  PersonnelModel? _selectedPersonnel;
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCaseOf = 'Fire - DECAMS';
  final TextEditingController _callerNameController = TextEditingController();
  final TextEditingController _incNumberController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  final TextEditingController _assignHourController = TextEditingController();
  final TextEditingController _assignMinuteController = TextEditingController();
  final TextEditingController _assignSecondController = TextEditingController();
  
  final TextEditingController _enrouteHourController = TextEditingController();
  final TextEditingController _enrouteMinuteController = TextEditingController();
  final TextEditingController _enrouteSecondController = TextEditingController();
  
  final TextEditingController _arriveHourController = TextEditingController();
  final TextEditingController _arriveMinuteController = TextEditingController();
  final TextEditingController _arriveSecondController = TextEditingController();
  
  TimeData? _assignTime;
  TimeData? _enrouteTime;
  TimeData? _arriveTime;
  
  String _activationResult = 'CC';
  String _responseResult = 'CC';
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  List<PersonnelModel> _personnelList = [];

  @override
  void initState() {
    super.initState();
    _loadPersonnelData();
  }

  Future<void> _loadPersonnelData() async {
    final personnel = await _storageService.getPersonnelList();
    if (personnel != null) {
      setState(() {
        _personnelList = personnel;
      });
    }
  }

  void _calculateTimes() {
    _activationResult = "CC";
    _responseResult = "CC";
    
    if (_assignTime != null) {
      if (_enrouteTime != null) {
        _activationResult = CalculateService.calculateActivation(_assignTime, _enrouteTime);
      }
      
      if (_arriveTime != null) {
        _responseResult = CalculateService.calculateResponse(_assignTime, _arriveTime);
      }
    }
    
    setState(() {});
  }

  void _showPreviewDialog() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _calculateTimes();

    final messageParts = <String>[
      'Appliance: ${_selectedAppliance ?? 'N/A'}',
      'SC: ${_selectedPersonnel?.rankAbbreviation ?? ''} ${_selectedPersonnel?.name ?? ''}',
      'Location: ${_locationController.text.toUpperCase()}',
      'Case of: ${_selectedCaseOf ?? 'N/A'}',
      'Caller name: ${_callerNameController.text.toUpperCase()}',
      'Assign: ${_assignTime?.formatTime() ?? 'CC'}',
      'Enroute: ${_enrouteTime?.formatTime() ?? 'CC'}',
      'Arrive: ${_arriveTime?.formatTime() ?? 'CC'}',
      'Activation: $_activationResult',
      'Response: $_responseResult',
      'Inc no.: /${_selectedDate.year}${_selectedDate.month.toString().padLeft(2, '0')}${_selectedDate.day.toString().padLeft(2, '0')}/${_incNumberController.text}',
    ];

    final remarksText = _remarksController.text.trim();
    if (remarksText.isNotEmpty) {
      messageParts.add('Remarks:\n$remarksText');
    }

    final message = messageParts.join('\n\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: SelectableText(
                  message,
                  style: const TextStyle(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message copied to clipboard')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedAppliance = null;
      _selectedPersonnel = null;
      _locationController.clear();
      _selectedCaseOf = 'Fire - DECAMS';
      _callerNameController.clear();
      _incNumberController.clear();
      _remarksController.clear();
      _selectedDate = DateTime.now();
      
      _assignHourController.clear();
      _assignMinuteController.clear();
      _assignSecondController.clear();
      _enrouteHourController.clear();
      _enrouteMinuteController.clear();
      _enrouteSecondController.clear();
      _arriveHourController.clear();
      _arriveMinuteController.clear();
      _arriveSecondController.clear();
      
      _assignTime = null;
      _enrouteTime = null;
      _arriveTime = null;
      
      _activationResult = 'CC';
      _responseResult = 'CC';
    });
  }

  void _resetApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text('This will clear all personnel data and reset the app to initial state. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _storageService.clearAllData();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DECAMS Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearForm,
            tooltip: 'Clear Form',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetApp,
            tooltip: 'Reset App',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecamsFormFields(
                selectedAppliance: _selectedAppliance,
                onApplianceChanged: (value) {
                  setState(() {
                    _selectedAppliance = value;
                  });
                },
                selectedPersonnel: _selectedPersonnel,
                onPersonnelChanged: (value) {
                  setState(() {
                    _selectedPersonnel = value;
                  });
                },
                personnelList: _personnelList,
                locationController: _locationController,
                selectedCaseOf: _selectedCaseOf,
                onCaseOfChanged: (value) {
                  setState(() {
                    _selectedCaseOf = value;
                  });
                },
                callerNameController: _callerNameController,
              ),

              TimeSection(
                title: 'Assign Time',
                hourController: _assignHourController,
                minuteController: _assignMinuteController,
                secondController: _assignSecondController,
                onTimeChanged: (time) {
                  setState(() {
                    _assignTime = time;
                    _calculateTimes();
                  });
                },
              ),
              
              const SizedBox(height: 20),
              TimeSection(
                title: 'Enroute Time',
                hourController: _enrouteHourController,
                minuteController: _enrouteMinuteController,
                secondController: _enrouteSecondController,
                onTimeChanged: (time) {
                  setState(() {
                    _enrouteTime = time;
                    _calculateTimes();
                  });
                },
              ),

              const SizedBox(height: 20),
              TimeSection(
                title: 'Arrive Time',
                hourController: _arriveHourController,
                minuteController: _arriveMinuteController,
                secondController: _arriveSecondController,
                onTimeChanged: (time) {
                  setState(() {
                    _arriveTime = time;
                    _calculateTimes();
                  });
                },
              ),

              const SizedBox(height: 24),
              CalculatedResultsCard(
                activationResult: _activationResult,
                responseResult: _responseResult,
              ),

              const SizedBox(height: 24),
              IncidentDetailsSection(
                selectedDate: _selectedDate,
                onDateSelected: _selectDate,
                incNumberController: _incNumberController,
                validator: FormValidators.validateIncidentNumber,
              ),

              const SizedBox(height: 24),
              RemarksSection(remarksController: _remarksController),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _showPreviewDialog,
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview & Generate DECAMS'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _assignHourController.dispose();
    _assignMinuteController.dispose();
    _assignSecondController.dispose();
    _enrouteHourController.dispose();
    _enrouteMinuteController.dispose();
    _enrouteSecondController.dispose();
    _arriveHourController.dispose();
    _arriveMinuteController.dispose();
    _arriveSecondController.dispose();
    _locationController.dispose();
    _callerNameController.dispose();
    _incNumberController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}