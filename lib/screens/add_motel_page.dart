import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddMotelPage extends StatefulWidget {
  @override
  _AddMotelPageState createState() => _AddMotelPageState();
}

class _AddMotelPageState extends State<AddMotelPage> {
  int currentStep = 0;
  LatLng? motelPosition;
  String motelName = '';
  String motelDescription = '';
  int monthlyPrice = 0;
  List<XFile> images = [];
  List<String> amenities = [];

  final amenitiesList = ["Bể Bơi", "Wi-Fi", "Bãi đỗ xe", "Spa", "Không hút thuốc"];

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Nhà Trọ')),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 4) {
            setState(() => currentStep++);
          } else {
            submitMotel();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) setState(() => currentStep--);
        },
        steps: [
          Step(title: Text('Vị trí'), content: locationPicker()),
          Step(title: Text('Tên và Mô tả'), content: nameDescription()),
          Step(title: Text('Giá thuê'), content: priceInput()),
          Step(title: Text('Hình ảnh'), content: imagePicker()),
          Step(title: Text('Tiện ích'), content: amenitiesPicker()),
        ],
      ),
    );
  }

  Widget locationPicker() => Container(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(10.762622, 106.660172), zoom: 14),
        onTap: (position) => setState(() => motelPosition = position),
        markers: motelPosition != null
            ? {Marker(markerId: MarkerId('selected'), position: motelPosition!)}
            : {},
      ));

  Widget nameDescription() => Column(
    children: [
      TextField(
        onChanged: (val) => motelName = val,
        decoration: InputDecoration(labelText: 'Tên nhà trọ'),
      ),
      TextField(
        onChanged: (val) => motelDescription = val,
        decoration: InputDecoration(labelText: 'Mô tả nhà trọ'),
      ),
    ],
  );

  Widget priceInput() => TextField(
    keyboardType: TextInputType.number,
    onChanged: (val) => monthlyPrice = int.tryParse(val) ?? 0,
    decoration: InputDecoration(labelText: 'Giá thuê/tháng (VNĐ)'),
  );

  Widget imagePicker() => ElevatedButton(
    onPressed: () async {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.length >= 3) setState(() => images = pickedFiles);
    },
    child: Text('Chọn ít nhất 3 ảnh'),
  );

  Widget amenitiesPicker() => Wrap(
    spacing: 8,
    children: amenitiesList
        .map((item) => ChoiceChip(
      label: Text(item),
      selected: amenities.contains(item),
      onSelected: (selected) => setState(() =>
      selected ? amenities.add(item) : amenities.remove(item)),
    ))
        .toList(),
  );

  void submitMotel() async {
    List<String> imageUrls = [];
    for (var img in images) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('motelImages/${DateTime.now().millisecondsSinceEpoch}_${img.name}');
      await storageRef.putData(await img.readAsBytes());
      final url = await storageRef.getDownloadURL();
      imageUrls.add(url);
    }

    await FirebaseFirestore.instance.collection('motels').add({
      'position': GeoPoint(motelPosition!.latitude, motelPosition!.longitude),
      'name': motelName,
      'description': motelDescription,
      'monthlyPrice': monthlyPrice,
      'images': imageUrls,
      'amenities': amenities,
      'createdAt': Timestamp.now(),
    });

    Navigator.of(context).pop();
  }
}
