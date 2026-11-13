import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MahajanTractorApp());
}

class MahajanTractorApp extends StatefulWidget {
  const MahajanTractorApp({super.key});

  @override
  State<MahajanTractorApp> createState() => _MahajanTractorAppState();
}

class _MahajanTractorAppState extends State<MahajanTractorApp> {
  // Marathi is enabled by default
  bool isMarathi = true;

  void toggleLanguage() {
    setState(() {
      isMarathi = !isMarathi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahajan Tractor Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest Green
          primary: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        isMarathi: isMarathi,
        onToggleLanguage: toggleLanguage,
      ),
    );
  }
}

// ---------------- GLOBAL DATA REPOSITORY ----------------
class BookingRecord {
  final String id;
  final String farmerName;
  final String village;
  final String phone;
  final String service;
  final int acres;
  final double gunthas;
  final double totalAcres;
  final double rate;
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final DateTime date;

  BookingRecord({
    required this.id,
    required this.farmerName,
    required this.village,
    required this.phone,
    required this.service,
    required this.acres,
    required this.gunthas,
    required this.totalAcres,
    required this.rate,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.date,
  });
}

class FarmerRecord {
  final String name;
  final String village;
  final String phone;
  double pendingBalance;

  FarmerRecord({
    required this.name,
    required this.village,
    required this.phone,
    required this.pendingBalance,
  });
}

// ---------------- MAIN HOME SCREEN WITH TABS ----------------
class HomeScreen extends StatefulWidget {
  final bool isMarathi;
  final VoidCallback onToggleLanguage;

  const HomeScreen({
    super.key,
    required this.isMarathi,
    required this.onToggleLanguage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Initial Sample Data
  final List<FarmerRecord> farmers = [
    FarmerRecord(name: 'रामराव पाटील', village: 'नांदगाव', phone: '9876543210', pendingBalance: 2000),
    FarmerRecord(name: 'बाळासाहेब देशमुख', village: 'वडगाव', phone: '9822334455', pendingBalance: 0),
    FarmerRecord(name: 'ज्ञानेश्वर शिंदे', village: 'पिंपळगाव', phone: '9890123456', pendingBalance: 3600),
  ];

  final List<BookingRecord> bookings = [
    BookingRecord(
      id: 'BK-101',
      farmerName: 'रामराव पाटील',
      village: 'नांदगाव',
      phone: '9876543210',
      service: 'रोटावेटर (Rotavator)',
      acres: 3,
      gunthas: 0,
      totalAcres: 3.0,
      rate: 1200,
      totalAmount: 3600,
      paidAmount: 1600,
      balanceAmount: 2000,
      date: DateTime.now(),
    ),
  ];

  void addBooking(BookingRecord record) {
    setState(() {
      bookings.insert(0, record);
      // Update farmer pending balance
      final idx = farmers.indexWhere((f) => f.phone == record.phone);
      if (idx != -1) {
        farmers[idx].pendingBalance += record.balanceAmount;
      } else {
        farmers.add(FarmerRecord(
          name: record.farmerName,
          village: record.village,
          phone: record.phone,
          pendingBalance: record.balanceAmount,
        ));
      }
    });
  }

  void addFarmer(FarmerRecord farmer) {
    setState(() {
      farmers.add(farmer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool mr = widget.isMarathi;

    final screens = [
      DashboardTab(
        isMarathi: mr,
        bookings: bookings,
        farmers: farmers,
        onNewBookingClick: () => setState(() => _currentIndex = 1),
      ),
      BookingTab(
        isMarathi: mr,
        onBookingAdded: (rec) {
          addBooking(rec);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mr ? 'नोंद यशस्वीरित्या जतन केली!' : 'Booking saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
      FarmersTab(
        isMarathi: mr,
        farmers: farmers,
        onAddFarmer: addFarmer,
      ),
      TractorFleetTab(isMarathi: mr),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        title: Text(
          mr ? 'महाजन ट्रॅक्टर मॅनेजर' : 'Mahajan Tractor Manager',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.g_translate, size: 18),
            label: Text(mr ? 'English' : 'मराठी', style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: widget.onToggleLanguage,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: mr ? 'डॅशबोर्ड' : 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.note_add_outlined),
            selectedIcon: const Icon(Icons.note_add),
            label: mr ? 'नवीन नोंद' : 'Bookings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: mr ? 'शेतकरी' : 'Farmers',
          ),
          NavigationDestination(
            icon: const Icon(Icons.agriculture_outlined),
            selectedIcon: const Icon(Icons.agriculture),
            label: mr ? 'ट्रॅक्टर्स' : 'Fleet',
          ),
        ],
      ),
    );
  }
}

// ---------------- TAB 1: DASHBOARD ----------------
class DashboardTab extends StatelessWidget {
  final bool isMarathi;
  final List<BookingRecord> bookings;
  final List<FarmerRecord> farmers;
  final VoidCallback onNewBookingClick;

  const DashboardTab({
    super.key,
    required this.isMarathi,
    required this.bookings,
    required this.farmers,
    required this.onNewBookingClick,
  });

  @override
  Widget build(BuildContext context) {
    double totalAcres = 0;
    double totalIncome = 0;
    double totalPending = 0;

    for (var b in bookings) {
      totalAcres += b.totalAcres;
      totalIncome += b.paidAmount;
    }

    for (var f in farmers) {
      totalPending += f.pendingBalance;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMarathi ? 'कामाचा व पैशांचा ताळेबंद' : 'Business Summary',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              _metricCard(
                isMarathi ? 'एकूण काम' : 'Total Work',
                '${totalAcres.toStringAsFixed(1)} ${isMarathi ? "एकर" : "Acres"}',
                Icons.landscape,
                Colors.blue.shade700,
              ),
              _metricCard(
                isMarathi ? 'जमा रक्कम' : 'Received Amount',
                '₹${totalIncome.toStringAsFixed(0)}',
                Icons.currency_rupee,
                Colors.green.shade700,
              ),
              _metricCard(
                isMarathi ? 'एकूण बाकी' : 'Total Pending',
                '₹${totalPending.toStringAsFixed(0)}',
                Icons.pending_actions,
                Colors.red.shade700,
              ),
              _metricCard(
                isMarathi ? 'नोंदणीकृत शेतकरी' : 'Total Farmers',
                '${farmers.length}',
                Icons.people,
                Colors.purple.shade700,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green, size: 36),
              title: Text(
                isMarathi ? 'नवीन काम / भाडे नोंदणी करा' : 'Create New Booking',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isMarathi ? 'क्षेत्रफळ मोजा आणि व्हॉट्सॲपवर बिल पाठवा' : 'Calculate area and send WhatsApp bill'),
              onTap: onNewBookingClick,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isMarathi ? 'अलीकडील नोंदी (Recent Work)' : 'Recent Work History',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (bookings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(isMarathi ? 'कोणतीही नोंद नाही' : 'No records yet'),
              ),
            )
          else
            ...bookings.take(5).map((b) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.agriculture, color: Colors.green),
                    ),
                    title: Text('${b.farmerName} (${b.village})'),
                    subtitle: Text('${b.service} • ${b.totalAcres.toStringAsFixed(2)} Acre'),
                    trailing: Text(
                      '₹${b.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ---------------- TAB 2: BOOKING & ACRE/GUNTHA CALCULATOR ----------------
class BookingTab extends StatefulWidget {
  final bool isMarathi;
  final Function(BookingRecord) onBookingAdded;

  const BookingTab({super.key, required this.isMarathi, required this.onBookingAdded});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _acresController = TextEditingController(text: '1');
  final _gunthasController = TextEditingController(text: '0');
  final _rateController = TextEditingController(text: '1200');
  final _paidController = TextEditingController(text: '0');

  String _selectedService = 'रोटावेटर (Rotavator)';

  final List<String> _services = [
    'रोटावेटर (Rotavator)',
    'नांगरणी (Ploughing)',
    'वखरणी (Cultivation)',
    'पेरणी यंत्र (Seeder)',
    'कुळवणी (Harrowing)',
    'जमीन सपाटीकरण (Leveling)',
    'ऊस सरी पाडणे (Sugarcane Ridges)',
    'इतर काम (Other)',
  ];

  // 1 Acre = 40 Gunthas exact conversion
  double get _totalDecAcres {
    final acres = int.tryParse(_acresController.text) ?? 0;
    final gunthas = double.tryParse(_gunthasController.text) ?? 0.0;
    return acres + (gunthas / 40.0);
  }

  double get _totalBill {
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    return _totalDecAcres * rate;
  }

  double get _balanceDue {
    final paid = double.tryParse(_paidController.text) ?? 0.0;
    return _totalBill - paid;
  }

  Future<void> _shareOnWhatsApp() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isMarathi ? 'कृपया नाव आणि फोन नंबर टाका!' : 'Please enter Name and Phone!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final billText = '''
🌾 *महाजन ट्रॅक्टर भाडे सेवा* 🌾
*MAHAJAN TRACTOR RENTAL SERVICE*
--------------------------------
शेतकऱ्याचे नाव: $name
गाव: ${_villageController.text}
तपशील: $_selectedService
क्षेत्र: ${_acresController.text} एकर ${_gunthasController.text} गुंठे (${_totalDecAcres.toStringAsFixed(2)} Acre)
दर: ₹${_rateController.text} प्रति एकर
--------------------------------
*एकूण बिल: ₹${_totalBill.toStringAsFixed(0)}*
जमा रक्कम: ₹${_paidController.text}
*बाकी रक्कम: ₹${_balanceDue.toStringAsFixed(0)}*
--------------------------------
धन्यवाद! महाजन ट्रॅक्टर भाडे सेवा.
''';

    final uri = Uri.parse("https://wa.me/91$phone?text=${Uri.encodeComponent(billText)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _saveBooking() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isMarathi ? 'नाव व फोन नंबर आवश्यक आहे.' : 'Name & Phone required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newRecord = BookingRecord(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      farmerName: _nameController.text.trim(),
      village: _villageController.text.trim(),
      phone: _phoneController.text.trim(),
      service: _selectedService,
      acres: int.tryParse(_acresController.text) ?? 0,
      gunthas: double.tryParse(_gunthasController.text) ?? 0.0,
      totalAcres: _totalDecAcres,
      rate: double.tryParse(_rateController.text) ?? 0.0,
      totalAmount: _totalBill,
      paidAmount: double.tryParse(_paidController.text) ?? 0.0,
      balanceAmount: _balanceDue,
      date: DateTime.now(),
    );

    widget.onBookingAdded(newRecord);
  }

  @override
  Widget build(BuildContext context) {
    final bool mr = widget.isMarathi;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mr ? 'नवीन भाडे नोंदणी आणि बिल' : 'New Tractor Work & Bill',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: mr ? 'शेतकऱ्याचे नाव' : 'Farmer Name',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: mr ? 'मोबाईल नंबर' : 'Phone (WhatsApp)',
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _villageController,
                  decoration: InputDecoration(
                    labelText: mr ? 'गाव' : 'Village',
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedService,
            decoration: InputDecoration(
              labelText: mr ? 'कामाचा प्रकार' : 'Service Type',
              border: const OutlineInputBorder(),
            ),
            items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (val) => setState(() => _selectedService = val!),
          ),
          const SizedBox(height: 12),
          // Area in Acres & Gunthas
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _acresController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: mr ? 'एकर (Acres)' : 'Acres',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _gunthasController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: mr ? 'गुंठे (Gunthas: 0-39)' : 'Gunthas (0-39)',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: mr ? 'दर प्रति एकर (₹)' : 'Rate / Acre (₹)',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _paidController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: mr ? 'जमा रक्कम (₹)' : 'Paid (₹)',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Real-time calculation card
          Card(
  
