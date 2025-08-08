import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/province_model.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Biến state để lưu các giá trị lọc
  Province? _selectedProvince;
  Ward? _selectedWard;
  // Mặc định sắp xếp theo "Mới nhất" để tránh lỗi khi không có bộ lọc nào được chọn
  String _selectedSort = 'Mới nhất';

  // Dữ liệu
  List<Province> _provinces = [];
  final List<String> _sortOptions = ['Gần tôi nhất','Mới nhất', 'Giá: cao tới thấp', 'Giá: thấp tới cao'];

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final String response = await rootBundle.loadString('assets/data/tree.json');
    final List<dynamic> data = await json.decode(response);
    // Thêm mục "Tất cả" vào đầu danh sách tỉnh
    final List<Province> loadedProvinces = data.map((json) => Province.fromJson(json)).toList();

    setState(() {
      _provinces = loadedProvinces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LỌC TÌM PHÒNG'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Dropdown Tỉnh/Thành phố
          _buildDropdown<Province>(
            label: 'Tỉnh/Thành phố',
            hint: 'Tất cả tỉnh thành', // Hiển thị khi chưa chọn
            value: _selectedProvince,
            items: _provinces,
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _selectedWard = null; // Reset quận/huyện khi chọn tỉnh mới
              });
            },
            itemToString: (province) => province.name,
          ),
          const SizedBox(height: 16),

          // Dropdown Quận/Huyện
          _buildDropdown<Ward>(
            label: 'Quận/Huyện',
            hint: 'Tất cả quận/huyện', // Hiển thị khi chưa chọn
            value: _selectedWard,
            items: _selectedProvince?.wards ?? [],
            onChanged: (value) => setState(() => _selectedWard = value),
            itemToString: (ward) => ward.name,
          ),
          const SizedBox(height: 16),

          // Dropdown Sắp xếp
          _buildDropdown<String>(
            label: 'Sắp xếp',
            hint: '',
            value: _selectedSort,
            items: _sortOptions,
            onChanged: (value) => setState(() => _selectedSort = value!),
            itemToString: (sort) => sort,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Tạo Map chứa các lựa chọn lọc
            final filters = {
              'province': _selectedProvince?.name,
              'ward': _selectedWard?.name,
              'sort': _selectedSort,
            };
            // Gửi dữ liệu về trang trước
            Navigator.of(context).pop(filters);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('ÁP DỤNG', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // Widget helper để vẽ các dropdown
  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemToString,
  }) {
    // Nếu danh sách rỗng (ví dụ: chưa chọn tỉnh nên chưa có quận/huyện), vô hiệu hóa dropdown
    final bool isEmpty = items.isEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label, style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
          ),
          DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            // Vô hiệu hóa nút nếu danh sách rỗng
            onChanged: isEmpty ? null : onChanged,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemToString(item)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}