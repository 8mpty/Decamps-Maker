import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuas_decamps_maker/models/personnel_model.dart';
import 'package:tuas_decamps_maker/models/time_data.dart';
import 'package:tuas_decamps_maker/screens/home_screen.dart';
import 'package:tuas_decamps_maker/services/calculate_service.dart';
import 'package:tuas_decamps_maker/services/storage_service.dart';
import 'package:tuas_decamps_maker/utils/form_validators.dart';
import 'package:tuas_decamps_maker/utils/incident_number.dart';
import 'package:tuas_decamps_maker/widgets/calculated_results_card.dart';
import 'package:tuas_decamps_maker/widgets/decams_form_fields.dart';
import 'package:tuas_decamps_maker/widgets/incident_details_section.dart';
import 'package:tuas_decamps_maker/widgets/remarks_section.dart';
import 'package:tuas_decamps_maker/widgets/time_section.dart';

const _monthNames = [
  'JANUARY',
  'FEBRUARY',
  'MARCH',
  'APRIL',
  'MAY',
  'JUNE',
  'JULY',
  'AUGUST',
  'SEPTEMBER',
  'OCTOBER',
  'NOVEMBER',
  'DECEMBER',
];

class DecamsFormScreen extends StatefulWidget {
  const DecamsFormScreen({super.key});

  @override
  State<DecamsFormScreen> createState() => _DecamsFormScreenState();
}

class _DecamsFormScreenState extends State<DecamsFormScreen> {
  final StorageService _storageService = StorageService();

  String? _selectedAppliance;
  PersonnelModel? _selectedPersonnel;
  String? _selectedCaseOf = 'Fire - DECAMS';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _callerNameController = TextEditingController();
  final TextEditingController _incNumberController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

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
  PersonnelFile? _personnelFile;
  List<String> _rotaOptions = [];
  String? _selectedRota;

  bool _hideIncDateFormat = false;
  bool _hideSc = false;

  @override
  void initState() {
    super.initState();
    _loadPersonnelData();
    _loadHideIncDateFormat();
    _loadHideSc();
  }

  Future<void> _loadHideIncDateFormat() async {
    final hide = await _storageService.getHideDateFormat();
    if (!mounted || hide == _hideIncDateFormat) return;

    setState(() {
      _hideIncDateFormat = hide;
    });
  }

  Future<void> _onHideIncDateFormatChanged(bool hide) async {
    setState(() {
      _hideIncDateFormat = hide;
    });
    await _storageService.saveHideDateFormat(hide);
  }

  Future<void> _loadHideSc() async {
    final hideSc = await _storageService.getHideSc();
    if (!mounted || hideSc == _hideSc) return;

    setState(() {
      _hideSc = hideSc;
    });
  }

  Future<void> _onHideScChanged(bool hideSc) async {
    setState(() {
      _hideSc = hideSc;
    });
    await _storageService.saveHideSc(hideSc);
  }

  Future<void> _loadPersonnelData() async {
    final file = await _storageService.getPersonnelFile();
    if (file == null) return;

    final rotas = file.getRotas();
    final saved = await _storageService.getSelectedRota();
    final selected = rotas.contains(saved)
        ? saved
        : (rotas.isNotEmpty ? rotas.first : null);
    if (selected != null && selected != saved) {
      await _storageService.saveSelectedRota(selected);
    }

    if (!mounted) return;
    setState(() {
      _personnelFile = file;
      _rotaOptions = rotas;
      _selectedRota = selected;
      _personnelList = file.getPersonnelList(rota: selected);
    });
  }

  Future<void> _onRotaChanged(String? rota) async {
    final file = _personnelFile;
    if (rota == null || file == null) return;

    final visible = file.getPersonnelList(rota: rota);
    final selected = _selectedPersonnel;

    setState(() {
      _selectedRota = rota;
      _personnelList = visible;
      _selectedPersonnel = selected == null
          ? null
          : _findVisiblePersonnel(visible, selected);
    });

    await _storageService.saveSelectedRota(rota);
  }

  static PersonnelModel? _findVisiblePersonnel(
    List<PersonnelModel> personnel,
    PersonnelModel selected,
  ) {
    for (final person in personnel) {
      if (person.name == selected.name &&
          person.rankAbbreviation == selected.rankAbbreviation &&
          person.category == selected.category) {
        return person;
      }
    }
    return null;
  }

  void _calculateTimes() {
    _activationResult = "CC";
    _responseResult = "CC";

    if (_assignTime != null) {
      if (_enrouteTime != null) {
        _activationResult = CalculateService.calculateActivation(
          _assignTime,
          _enrouteTime,
        );
      }

      if (_arriveTime != null) {
        _responseResult = CalculateService.calculateResponse(
          _assignTime,
          _arriveTime,
        );
      }
    }

    setState(() {});
  }

  void _showPreviewDialog() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _calculateTimes();

    final incNumber = formatIncidentNumber(
      number: _incNumberController.text,
      date: _selectedDate,
      hideDateFormat: _hideIncDateFormat,
    );

    final messageParts = <String>[
      '*_${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}_*',
      'Appliance: ${_selectedAppliance ?? 'N/A'}',
      if (!_hideSc)
        'SC: ${_selectedPersonnel?.rankAbbreviation ?? ''} ${_selectedPersonnel?.name ?? ''}',
      'Location: ${_locationController.text.toUpperCase()}',
      'Case of: ${_selectedCaseOf ?? 'N/A'}',
      'Caller name: ${_callerNameController.text.toUpperCase()}',
      'Assign: ${_assignTime?.formatTime() ?? 'CC'}',
      'Enroute: ${_enrouteTime?.formatTime() ?? 'CC'}',
      'Arrive: ${_arriveTime?.formatTime() ?? 'CC'}',
      'Activation: $_activationResult',
      'Response: $_responseResult',
      'Inc no.: $incNumber',
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
                child: SelectableText(message, style: const TextStyle()),
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
        content: const Text(
          'This will clear all personnel data and reset the app to initial state. Are you sure?',
        ),
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
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DECAMS Form'),
        actions: [
          if (_rotaOptions.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'Switch rota',
              initialValue: _selectedRota,
              position: PopupMenuPosition.under,
              onSelected: _onRotaChanged,
              itemBuilder: (context) => _rotaOptions
                  .map((rota) => PopupMenuItem(value: rota, child: Text(rota)))
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedRota ?? 'Rota',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ],
                ),
              ),
            ),
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
                hideIncDateFormat: _hideIncDateFormat,
                onHideIncDateFormatChanged: _onHideIncDateFormatChanged,
                hideSc: _hideSc,
                onHideScChanged: _onHideScChanged,
              ),

              const SizedBox(height: 24),
              RemarksSection(remarksController: _remarksController),

              const SizedBox(height: 24),
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
