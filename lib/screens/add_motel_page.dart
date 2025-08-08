import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../models/motel_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
// THÊM: Các import cần thiết để đọc file JSON và sử dụng model tỉnh/thành
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/province_model.dart';

class AddMotelPage extends StatefulWidget {
  final MotelModel? initialMotel;
  const AddMotelPage({super.key, this.initialMotel});

  @override
  _AddMotelPageState createState() => _AddMotelPageState();
}

class _AddMotelPageState extends State<AddMotelPage> {
  // THÊM: GlobalKey cho Form để validation
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  final _picker = ImagePicker();
  bool _isEditMode = false;

  // --- CONTROLLERS VÀ BIẾN STATE ---
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _electricityCostController = TextEditingController();
  final _waterCostController = TextEditingController();
  final _parkingCostController = TextEditingController();
  final _managementFeeController = TextEditingController();
  final _wifiCostController = TextEditingController();
  final _areaController = TextEditingController();
  final _maxOccupantsController = TextEditingController();
  final _vehicleLimitController = TextEditingController();
  LatLng? _motelPosition;
  List<XFile> _images = [];
  bool _isFreeHours = true;
  bool _liveWithOwner = false;
  bool _isAvailable = true;
  final Set<String> _selectedAmenities = {};

  // THÊM: Các biến state để quản lý danh sách và lựa chọn tỉnh/phường
  List<Province> _provinces = [];
  Province? _selectedProvince;
  Ward? _selectedWard;

  final Map<String, IconData> _allAmenities = {
    'Gác': Icons.stairs_outlined, 'Cửa sổ': Icons.window_outlined, 'Tủ lạnh': Icons.kitchen_outlined,
    'Máy lạnh': Icons.ac_unit_outlined, 'Giường': Icons.king_bed_outlined, 'Nệm': Icons.king_bed,
    'Tủ quần áo': Icons.checkroom_outlined, 'Thang máy': Icons.elevator_outlined,
    'Nước nóng': Icons.hot_tub_outlined, 'Thú cưng': Icons.pets_outlined, 'Máy giặt': Icons.local_laundry_service_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadProvinces(); // Gọi hàm tải dữ liệu tỉnh thành

    if (widget.initialMotel != null) {
      _isEditMode = true;
      final motel = widget.initialMotel!;

      _addressController.text = motel.address;
      _nameController.text = motel.name;
      _descriptionController.text = motel.description;
      _monthlyPriceController.text = motel.monthlyPrice.toString();
      _electricityCostController.text = motel.electricityCost.toString();
      _waterCostController.text = motel.waterCost.toString();
      _parkingCostController.text = motel.parkingCost.toString();
      _managementFeeController.text = motel.managementFee.toString();
      _wifiCostController.text = motel.wifiCost.toString();
      _areaController.text = motel.area.toString();
      _maxOccupantsController.text = motel.maxOccupants.toString();
      _vehicleLimitController.text = motel.vehicleLimit.toString();
      _isFreeHours = motel.isFreeHours;
      _liveWithOwner = motel.liveWithOwner;
      _isAvailable = motel.isAvailable;
      _selectedAmenities.addAll(motel.amenities);

      if (motel.latitude != null && motel.longitude != null) {
        _motelPosition = LatLng(motel.latitude!, motel.longitude!);
      }
    }
  }

  // THÊM: Hàm đọc và xử lý file tree.json
  Future<void> _loadProvinces() async {
    try {
      final String response = await rootBundle.loadString('assets/data/tree.json');
      final List<dynamic> data = await json.decode(response);
      final List<Province> loadedProvinces = data.map((json) => Province.fromJson(json)).toList();

      setState(() {
        _provinces = loadedProvinces;
        // Nếu là chế độ sửa, tìm và chọn sẵn tỉnh/phường đã lưu
        if (_isEditMode && widget.initialMotel!.province.isNotEmpty) {
          try {
            _selectedProvince = _provinces.firstWhere((p) => p.name == widget.initialMotel!.province);
            if (_selectedProvince != null && widget.initialMotel!.ward.isNotEmpty) {
              _selectedWard = _selectedProvince!.wards.firstWhere((w) => w.name == widget.initialMotel!.ward);
            }
          } catch (e) {
            print('Không tìm thấy tỉnh/phường đã lưu: $e');
            _selectedProvince = null;
            _selectedWard = null;
          }
        }
      });
    } catch (e) {
      print("Lỗi tải dữ liệu tỉnh thành: $e");
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _monthlyPriceController.dispose();
    _electricityCostController.dispose();
    _waterCostController.dispose();
    _parkingCostController.dispose();
    _managementFeeController.dispose();
    _wifiCostController.dispose();
    _areaController.dispose();
    _maxOccupantsController.dispose();
    _vehicleLimitController.dispose();
    super.dispose();
  }

  void _submitMotel() async {
    // THÊM: Kiểm tra validation của Form
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final landlordId = authProvider.userModel?.uid;
    if (landlordId == null) return;

    if (!_isEditMode && _images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ít nhất 3 ảnh.")));
      return;
    }

    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    List<String> imageUrls = [];
    if (_images.isNotEmpty) {
      for (var img in _images) {
        final storageRef = FirebaseStorage.instance.ref().child('motelImages/${DateTime.now().millisecondsSinceEpoch}_${img.name}');
        await storageRef.putFile(File(img.path));
        imageUrls.add(await storageRef.getDownloadURL());
      }
    } else if (_isEditMode) {
      imageUrls = widget.initialMotel!.images;
    }

    // THÊM: tỉnh/thành và phường/xã vào motelData
    final motelData = MotelModel(
      id: _isEditMode ? widget.initialMotel!.id : null,
      landlordId: landlordId,
      name: _nameController.text,
      description: _descriptionController.text,
      monthlyPrice: int.tryParse(_monthlyPriceController.text) ?? 0,
      images: imageUrls,
      amenities: _selectedAmenities.toList(),
      latitude: _motelPosition?.latitude,
      longitude: _motelPosition?.longitude,
      createdAt: _isEditMode ? widget.initialMotel!.createdAt : Timestamp.now(),
      address: _addressController.text,
      province: _selectedProvince!.name,
      ward: _selectedWard!.name,
      electricityCost: int.tryParse(_electricityCostController.text) ?? 0,
      waterCost: int.tryParse(_waterCostController.text) ?? 0,
      parkingCost: int.tryParse(_parkingCostController.text) ?? 0,
      managementFee: int.tryParse(_managementFeeController.text) ?? 0,
      wifiCost: int.tryParse(_wifiCostController.text) ?? 0,
      area: double.tryParse(_areaController.text) ?? 0.0,
      maxOccupants: int.tryParse(_maxOccupantsController.text) ?? 1,
      vehicleLimit: int.tryParse(_vehicleLimitController.text) ?? 1,
      isFreeHours: _isFreeHours,
      liveWithOwner: _liveWithOwner,
      isAvailable: _isAvailable,
    ).toMap();

    if (_isEditMode) {
      await FirebaseFirestore.instance.collection('motels').doc(widget.initialMotel!.id).update(motelData);
    } else {
      await FirebaseFirestore.instance.collection('motels').add(motelData);
    }

    Navigator.of(context).pop();
    Navigator.of(context).pop();
    if(_isEditMode) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Chỉnh sửa nhà trọ' : 'Đăng tin nhà trọ'),backgroundColor: Colors.lightBlueAccent),
      body: Form( // Bọc Stepper trong một Form
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            final isLastStep = _currentStep == _getSteps().length - 1;
            if (isLastStep) {
              _submitMotel();
            } else {
              setState(() => _currentStep++);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: _getSteps(),
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == _getSteps().length - 1;
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? (_isEditMode ? 'LƯU THAY ĐỔI' : 'ĐĂNG TIN') : 'TIẾP TỤC'),
                    ),
                  ),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('QUAY LẠI'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Step> _getSteps() => [
    Step(
      title: const Text('Vị trí & Địa chỉ'),
      content: _buildLocationStep(),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Tên và Mô tả'),
      content: _buildNameAndDescriptionStep(),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Chi phí'),
      content: _buildCostsStep(),
      isActive: _currentStep >= 2,
    ),
    Step(
      title: const Text('Thông tin chi tiết'),
      content: _buildDetailsStep(),
      isActive: _currentStep >= 3,
    ),
    Step(
      title: const Text('Tiện ích'),
      content: _buildAmenitiesStep(),
      isActive: _currentStep >= 4,
    ),
    Step(
      title: const Text('Hình ảnh'),
      content: _buildImagePickerStep(),
      isActive: _currentStep >= 5,
    ),
  ];

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Province>(
          value: _selectedProvince,
          isExpanded: true,
          hint: const Text('Chọn Tỉnh/Thành phố'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: _provinces.map((Province province) {
            return DropdownMenuItem<Province>(
              value: province,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: (Province? newValue) {
            setState(() {
              _selectedProvince = newValue;
              _selectedWard = null;
            });
          },
          validator: (value) => value == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Ward>(
          value: _selectedWard,
          isExpanded: true,
          hint: const Text('Chọn Quận/Huyện/Phường/Xã'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: (_selectedProvince?.wards ?? []).map((Ward ward) {
            return DropdownMenuItem<Ward>(
              value: ward,
              child: Text(ward.name),
            );
          }).toList(),
          onChanged: (Ward? newValue) {
            setState(() {
              _selectedWard = newValue;
            });
          },
          validator: (value) => value == null ? 'Vui lòng chọn quận/huyện' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ chi tiết (Số nhà, tên đường)',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa chỉ chi tiết' : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Chọn vị trí chính xác trên bản đồ (tùy chọn)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _motelPosition ?? const LatLng(10.0452, 105.7469),
                  zoom: 15,
                ),
                onCameraMove: (position) {
                  setState(() {
                    _motelPosition = position.target;
                  });
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<EagerGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
            const IgnorePointer(
              child: Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameAndDescriptionStep() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên nhà trọ',
            hintText: 'VD: Phòng trọ cao cấp gần Đại học Cần Thơ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Mô tả chi tiết',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildCostsStep() {
    return Column(
      children: [
        _buildNumberField(_monthlyPriceController, 'Giá thuê/tháng (VNĐ)'),
        const SizedBox(height: 16),
        _buildNumberField(_electricityCostController, 'Giá điện/kWh'),
        const SizedBox(height: 16),
        _buildNumberField(_waterCostController, 'Giá nước/người/tháng'),
        const SizedBox(height: 16),
        _buildNumberField(_parkingCostController, 'Phí gửi xe/xe/tháng'),
        const SizedBox(height: 16),
        _buildNumberField(_wifiCostController, 'Phí Wifi/phòng/tháng'),
        const SizedBox(height: 16),
        _buildNumberField(_managementFeeController, 'Phí quản lý/phòng/tháng'),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      children: [
        _buildNumberField(_areaController, 'Diện tích (m²)'),
        const SizedBox(height: 16),
        _buildNumberField(_maxOccupantsController, 'Số người ở tối đa'),
        const SizedBox(height: 16),
        _buildNumberField(_vehicleLimitController, 'Số xe cho phép'),
        SwitchListTile(
          title: const Text('Giờ giấc tự do'),
          value: _isFreeHours,
          onChanged: (val) => setState(() => _isFreeHours = val),
          secondary: const Icon(Icons.access_time),
        ),
        SwitchListTile(
          title: const Text('Chung chủ'),
          value: _liveWithOwner,
          onChanged: (val) => setState(() => _liveWithOwner = val),
          secondary: const Icon(Icons.people_outline),
        ),
        SwitchListTile(
          title: const Text('Tình trạng phòng'),
          subtitle: Text(_isAvailable ? 'Còn phòng' : 'Hết phòng'),
          value: _isAvailable,
          onChanged: (val) => setState(() => _isAvailable = val),
          secondary: Icon(
            Icons.check_circle,
            color: _isAvailable ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesStep() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _allAmenities.keys.map((amenity) {
        return FilterChip(
          label: Text(amenity),
          selected: _selectedAmenities.contains(amenity),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          checkmarkColor: Colors.white,
          selectedColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: _selectedAmenities.contains(amenity) ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePickerStep() {
    return Column(
      children: [
        Text(_isEditMode ? 'Bạn có thể chọn ảnh mới để thay thế ảnh cũ.' : 'Vui lòng chọn ít nhất 3 ảnh, ảnh đầu tiên sẽ là ảnh bìa.'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library),
          onPressed: () async {
            final pickedFiles = await _picker.pickMultiImage();
            if (pickedFiles.isNotEmpty) {
              setState(() => _images = pickedFiles);
            }
          },
          label: const Text('Chọn ảnh từ thư viện'),
        ),
        if (_images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _images.map((file) => Image.file(File(file.path), width: 100, height: 100, fit: BoxFit.cover)).toList(),
            ),
          )
      ],
    );
  }

  TextFormField _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }
}