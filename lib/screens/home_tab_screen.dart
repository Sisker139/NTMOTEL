import 'package:flutter/material.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:ntmotel/screens/add_motel_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/models/motel_model.dart';
import 'package:intl/intl.dart';
import 'package:ntmotel/screens/motel_detail_screen.dart';
import 'filter_screen.dart';
// THÊM: Các import cần thiết cho chức năng vị trí
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'search_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  Map<String, dynamic> _filters = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Hàm lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    // Kiểm tra và xin quyền truy cập vị trí
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    // Nếu người dùng cấp quyền, lấy tọa độ
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      } catch (e) {
        print("Lỗi khi lấy vị trí: $e");
        // Có thể hiển thị thông báo cho người dùng ở đây
      }
    }
  }

  void _updateFilters(Map<String, dynamic> newFilters) {
    setState(() {
      _filters = newFilters;
    });
  }

  Stream<QuerySnapshot> _buildStream(AuthProvider authProvider) {
    Query query = FirebaseFirestore.instance.collection('motels');
    final bool isLandlord = authProvider.userModel?.role == 'landlord';

    if (isLandlord) {
      query = query.where('landlordId', isEqualTo: authProvider.userModel!.uid);
    } else {
      query = query.where('isAvailable', isEqualTo: true);
    }

    if (_filters['province'] != null && _filters['province'] != 'Tất cả') {
      query = query.where('province', isEqualTo: _filters['province']);
    }
    if (_filters['ward'] != null) {
      query = query.where('ward', isEqualTo: _filters['ward']);
    }

    // Nếu người dùng sắp xếp theo "Gần nhất", chúng ta không sắp xếp trên Firestore
    // vì việc này sẽ được xử lý sau khi có dữ liệu.
    if (_filters['sort'] == 'Giá: thấp tới cao') {
      query = query.orderBy('monthlyPrice', descending: false);
    } else if (_filters['sort'] == 'Giá: cao tới thấp') {
      query = query.orderBy('monthlyPrice', descending: true);
    } else if (_filters['sort'] != 'Gần nhất') {
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLandlord = authProvider.userModel?.role == 'landlord';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                height: 50,
                child: Image.asset('assets/logo2.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  // SỬA: GestureDetector phải bọc bên ngoài Container
                  child: GestureDetector(
                    onTap: () {
                      // Điều hướng đến màn hình tìm kiếm
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                    },
                    // Container chứa giao diện của thanh tìm kiếm
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text("Tìm kiếm", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Map<String, dynamic>>(
                      MaterialPageRoute(builder: (context) => const FilterScreen()),
                    );
                    if (result != null && mounted) { // Thêm 'mounted' check
                      _updateFilters(result);
                    }
                  },
                ),
                const SizedBox(width: 15),
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (isLandlord) _buildPostRoomBanner(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildStream(authProvider),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}. Vui lòng kiểm tra lại chỉ mục Firestore.'));
                }

                var docs = snapshot.data?.docs ?? [];

                // Xử lý sắp xếp theo "Gần nhất" sau khi có dữ liệu
                if (_filters['sort'] == 'Gần tôi nhất' && _currentPosition != null) {
                  docs.sort((a, b) {
                    final motelA = MotelModel.fromMap(a.data() as Map<String, dynamic>, a.id);
                    final motelB = MotelModel.fromMap(b.data() as Map<String, dynamic>, b.id);

                    if (motelA.latitude == null || motelA.longitude == null) return 1;
                    if (motelB.latitude == null || motelB.longitude == null) return -1;

                    final distanceA = Geolocator.distanceBetween(
                      _currentPosition!.latitude, _currentPosition!.longitude,
                      motelA.latitude!, motelA.longitude!,
                    );
                    final distanceB = Geolocator.distanceBetween(
                      _currentPosition!.latitude, _currentPosition!.longitude,
                      motelB.latitude!, motelB.longitude!,
                    );
                    return distanceA.compareTo(distanceB);
                  });
                }

                if (docs.isEmpty) {
                  return Center(child: Text(isLandlord ? 'Bạn chưa đăng phòng trọ nào!' : 'Không tìm thấy phòng trọ phù hợp.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final motel = MotelModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                      docs[index].id,
                    );
                    return buildMotelCard(context, motel);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostRoomBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddMotelPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00A680),
        ),
        child: Row(
          children: const [
            Icon(Icons.add_home_work_outlined, color: Colors.white, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Đăng nhà trọ trên\nNT Motel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TÁCH HÀM NÀY RA NGOÀI ĐỂ DÙNG CHUNG
Widget buildMotelCard(BuildContext context, MotelModel motel) {
  final formattedPrice = NumberFormat.decimalPattern('vi_VN').format(motel.monthlyPrice);

  return Consumer<AuthProvider>(
    builder: (context, authProvider, child) {
      final bool isSaved = authProvider.userModel?.savedMotelIds.contains(motel.id) ?? false;
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MotelDetailScreen(motel: motel)),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (motel.images.isNotEmpty)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        motel.images.first,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (!motel.isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Chip(
                        label: Text(
                          motel.isAvailable ? 'Còn phòng' : 'Hết phòng',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: motel.isAvailable ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            motel.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () {
                            authProvider.toggleFavoriteStatus(motel.id!);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.grey.shade600, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            motel.address,
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 20, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          '$formattedPrice VND/tháng',
                          style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      motel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    if(motel.amenities.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: motel.amenities
                            .map((e) => Chip(
                          label: Text(e, style: const TextStyle(fontSize: 12)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          backgroundColor: Colors.grey.shade200,
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}