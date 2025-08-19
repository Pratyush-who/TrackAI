import 'package:trackai/features/onboarding/onboarding_data.dart';

void main() {
  print('Testing OnboardingData conversion...\n');

  // Test 1: Create OnboardingData and convert to map
  var testData = OnboardingData(
    gender: 'male',
    otherApps: 'none',
    workoutFrequency: 'intermediate',
    heightFeet: 5,
    heightInches: 8,
    weightLbs: 160.0,
    isMetric: false,
    goal: 'lose_weight',
    accomplishment: 'completed_marathon',
    desiredWeight: 150.0,
    goalPace: 'moderate',
    dietPreference: 'balanced',
  );

  print('Test 1 - Original OnboardingData:');
  print('Height: ${testData.heightFeet}\'${testData.heightInches}" (${testData.heightCm.toStringAsFixed(1)} cm)');
  print('Weight: ${testData.weightLbs} lbs (${testData.weightKg.toStringAsFixed(1)} kg)');
  print('BMI: ${testData.calculateBMI().toStringAsFixed(1)}');
  print('Is Metric: ${testData.isMetric}\n');

  // Test 2: Convert to map
  var mapData = testData.toMap();
  print('Test 2 - Converted to Map:');
  print('Map data: $mapData\n');

  // Test 3: Convert back from map
  var reconstructedData = OnboardingData.fromMap(mapData);
  print('Test 3 - Reconstructed from Map:');
  print('Height: ${reconstructedData.heightFeet}\'${reconstructedData.heightInches}" (${reconstructedData.heightCm.toStringAsFixed(1)} cm)');
  print('Weight: ${reconstructedData.weightLbs} lbs (${reconstructedData.weightKg.toStringAsFixed(1)} kg)');
  print('BMI: ${reconstructedData.calculateBMI().toStringAsFixed(1)}');
  print('Is Metric: ${reconstructedData.isMetric}\n');

  // Test 4: Test with DateTime fields
  var testDataWithDates = OnboardingData(
    gender: 'female',
    heightFeet: 5,
    heightInches: 6,
    weightLbs: 130.0,
    dateOfBirth: DateTime(1990, 5, 15),
    completedAt: DateTime.now(),
  );

  print('Test 4 - Data with DateTime fields:');
  print('Date of Birth: ${testDataWithDates.dateOfBirth}');
  print('Completed At: ${testDataWithDates.completedAt}\n');

  var mapDataWithDates = testDataWithDates.toMap();
  print('Test 4 - Map with DateTime fields:');
  print('dateOfBirth type: ${mapDataWithDates['dateOfBirth'].runtimeType}');
  print('completedAt type: ${mapDataWithDates['completedAt'].runtimeType}\n');

  var reconstructedDataWithDates = OnboardingData.fromMap(mapDataWithDates);
  print('Test 4 - Reconstructed with DateTime fields:');
  print('Date of Birth: ${reconstructedDataWithDates.dateOfBirth}');
  print('Completed At: ${reconstructedDataWithDates.completedAt}\n');

  print('All tests completed successfully!');
}
