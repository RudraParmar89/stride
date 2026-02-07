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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.accentColor.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.1), blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AVAILABLE EMBERS:", style: TextStyle(color: theme.subText, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text("${xpController.embers} 🔥", style: TextStyle(color: theme.accentColor, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.accentColor.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.info_outline, color: theme.accentColor, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, color: theme.accentColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Exchange Embers for coupons and gear. Tap a coupon to redeem.",
                          style: TextStyle(color: theme.subText, fontSize: 11, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: coupons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard, color: theme.subText.withOpacity(0.5), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          "No Coupons Available",
                          style: TextStyle(color: theme.subText, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Check back soon for new deals!",
                          style: TextStyle(color: theme.subText.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      final canRedeem = xpController.embers >= coupon.embersRequired;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: GestureDetector(
                          onTap: canRedeem ? () => _showEnlargedTicket(context, coupon, theme, xpController) : null,
                          child: Opacity(
                            opacity: canRedeem ? 1 : 0.6,
                            child: ClipPath(
                              clipper: TicketClipper(),
                              child: Container(
                                height: 110,
                                color: theme.cardColor,
                                child: Row(
                                  children: [
                                    Container(width: 8, color: canRedeem ? coupon.accentColor : Colors.grey),
                                    const SizedBox(width: 15),

                                    Hero(
                                      tag: coupon.code,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
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
                                    
                                    SizedBox(
                                      width: 90,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            coupon.discount,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: canRedeem ? coupon.accentColor : Colors.grey,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "🔥 ${coupon.embersRequired}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: canRedeem ? theme.accentColor : Colors.grey,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
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