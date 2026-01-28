import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../theme/theme_manager.dart'; // Adjust path
import '../../../controllers/xp_controller.dart'; // Adjust path

// Data Model
class Coupon {
  final String brandName;
  final String category;
  final String discount;
  final int embersRequired;
  final Color accentColor;
  final String code;
  final String imagePath;

  Coupon({
    required this.brandName,
    required this.category,
    required this.discount,
    required this.embersRequired,
    required this.accentColor,
    required this.code,
    required this.imagePath,
  });
}

class TacticalRedeemPage extends StatefulWidget {
  const TacticalRedeemPage({super.key});

  @override
  State<TacticalRedeemPage> createState() => _TacticalRedeemPageState();
}

class _TacticalRedeemPageState extends State<TacticalRedeemPage> {
  final List<Coupon> coupons = [
    Coupon(
      brandName: "ETLE FASHION",
      category: "PREMIUM APPAREL",
      discount: "20% OFF",
      embersRequired: 500,
      accentColor: const Color(0xFFD4AF37),
      code: "ETLE-20-STRIDE",
      imagePath: "assets/images/etle_logo.png",
    ),
    // ... Add more coupons
  ];

  @override
  Widget build(BuildContext context) {
    final xpController = context.watch<XpController>();
    final theme = context.watch<ThemeManager>(); // Watch theme directly

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        title: Text("SUPPLY DEPOT", style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.accentColor.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.1), blurRadius: 15)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("AVAILABLE EMBERS:", style: TextStyle(color: theme.subText, fontSize: 12, letterSpacing: 1)),
                Text("${xpController.embers} EMBERS", style: TextStyle(color: theme.accentColor, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: GestureDetector(
                    onTap: () => _showEnlargedTicket(context, coupon, theme, xpController),
                    child: ClipPath(
                      clipper: TicketClipper(),
                      child: Container(
                        height: 110,
                        color: theme.cardColor,
                        child: Row(
                          children: [
                            Container(width: 8, color: coupon.accentColor),
                            const SizedBox(width: 15),

                            Hero(
                              tag: coupon.code,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]
                                ),
                                child: _buildLogoImage(coupon.imagePath, 45),
                              ),
                            ),
                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(coupon.brandName, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(coupon.category, style: TextStyle(color: theme.subText, fontSize: 10, letterSpacing: 1.5)),
                                ],
                              ),
                            ),

                            Container(height: 60, width: 1, color: theme.subText.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 10)),
                            SizedBox(width: 90, child: Center(child: Text(coupon.discount, textAlign: TextAlign.center, style: TextStyle(color: coupon.accentColor, fontWeight: FontWeight.w900, fontSize: 14)))),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage(String path, double size) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: size, height: size, fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey, size: size),
      );
    } else {
      return Image.asset(
        path,
        width: size, height: size, fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey, size: size),
      );
    }
  }

  void _showEnlargedTicket(BuildContext context, Coupon coupon, ThemeManager theme, XpController xp) {
    // ... (Keep existing implementation logic)
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double r = 15;
    path.lineTo(0, size.height / 2 - r);
    path.arcToPoint(Offset(0, size.height / 2 + r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height / 2 + r);
    path.arcToPoint(Offset(size.width, size.height / 2 - r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> old) => false;
}