import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gachafigo/models/user.dart';

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  String _selectedCurrency = 'IDR';
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'JPY'];

  // Current exchange rates (you should fetch these from an API in production)
  final Map<String, double> _exchangeRates = {
    'USD': 15000, // 1 USD = 15,000 IDR (example)
    'EUR': 18000, // 1 EUR = 18,000 IDR
    'JPY': 110, // 1 JPY = 110 IDR
    'IDR': 1, // 1 IDR = 1 IDR
  };

  final List<Map<String, dynamic>> _bundles = [
    {'credits': 300, 'usd_price': 0.5},
    {'credits': 900, 'usd_price': 2.0},
    {'credits': 3000, 'usd_price': 5.0},
    {'credits': 9000, 'usd_price': 15.0},
    {'credits': 30000, 'usd_price': 50.0},
    {'credits': 90000, 'usd_price': 100.0},
    {'credits': 300000, 'usd_price': 200.0},
    {'credits': 900000, 'usd_price': 500.0},
    {'credits': 3000000, 'usd_price': 1000.0},
    {'credits': 9000000, 'usd_price': 2000.0},
    {'credits': 30000000, 'usd_price': 5000.0},
    {'credits': 900000000, 'usd_price': 10000.0},
  ];

  final List<String> _paymentMethods = ['BCA', 'BNI', 'SeaBank', 'DANA', 'OVO'];
  String? _selectedPayment = 'BCA';

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green[800],
      textColor: Colors.white,
    );
  }

  String _formatPrice(double price) {
    if (_selectedCurrency == 'IDR') {
      return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } else {
      return '${_selectedCurrency} ${price.toStringAsFixed(2)}';
    }
  }

  double _convertPrice(double usdPrice) {
    if (_selectedCurrency == 'USD') return usdPrice;
    final usdToIdr = usdPrice * _exchangeRates['USD']!;
    return usdToIdr / _exchangeRates[_selectedCurrency]!;
  }

  void _showPurchaseDialog(Map<String, dynamic> bundle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Purchase'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bundle['credits']} Credits',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  _formatPrice(_convertPrice(bundle['usd_price'])),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedPayment,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPayment = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPayment == null
                        ? null
                        : () {
                          _processTopUp(bundle['credits']);
                          Navigator.pop(context);
                        },
                child: Text('Purchase'),
              ),
            ],
          ),
    );
  }

  Future<void> _processTopUp(int credits) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId == null) {
      _showToast('Session expired. Please login again.');
      return;
    }

    final usersBox = Hive.box<User>('users');
    final userIndex = usersBox.values.toList().indexWhere(
      (u) => u.id == currentUserId,
    );

    if (userIndex == -1) {
      _showToast('User not found');
      return;
    }

    final user = usersBox.getAt(userIndex) as User;
    final updatedUser = User(
      id: user.id,
      username: user.username,
      password: user.password,
      credit: user.credit + credits,
      collection: List.from(user.collection),
    );

    await usersBox.putAt(userIndex, updatedUser);

    _showToast('Success! $credits credits added to your account');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Up Credits'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _selectedCurrency,
              underline: Container(),
              icon: Icon(Icons.currency_exchange, color: Colors.white),
              items:
                  _currencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _bundles.length,
        itemBuilder: (context, index) {
          final bundle = _bundles[index];
          final price = _convertPrice(bundle['usd_price']);

          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => _showPurchaseDialog(bundle),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bundle['credits']} Credits',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatPrice(price),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
