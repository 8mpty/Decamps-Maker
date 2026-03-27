class FormValidators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  static String? validateIncidentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Incident number is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Incident number must contain only digits';
    }
    return null;
  }

  static String? Function(String?) createRequiredValidator(String fieldName) {
    return (String? value) => validateRequired(value, fieldName);
  }
}