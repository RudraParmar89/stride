import 'package:flutter/material.dart';

class CurvedNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<IconData> items;

  const CurvedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CurvedNavigationBar> createState() => _CurvedNavigationBarState();
}

class _CurvedNavigationBarState extends State<CurvedNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _oldIndex;

  @override
  void initState() {
    super.initState();
    _oldIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Faster, snappier animation
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack), // Bouncy effect
    );
  }

  @override
  void didUpdateWidget(covariant CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _oldIndex = oldWidget.currentIndex;
      _controller.reset();
      _animation = Tween<double>(
        begin: _oldIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double itemWidth = size.width / widget.items.length;

    return SizedBox(
      height: 75, // <--- SHORTER HEIGHT (Was 95)
      child: Stack(
        clipBehavior: Clip.none, // Allows the button to float above
        children: [
          // 1. THE LIQUID CURVE BACKGROUND
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _NavCurvePainter(
                  position: _animation.value,
                  itemCount: widget.items.length,
                  color: const Color(0xFF1A1A1A), // Dark Bar Color
                ),
                size: Size(size.width, 75),
              );
            },
          ),

          // 2. THE FLOATING ACTION BUTTON (Green Circle)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double currentPos = _animation.value;
              return Positioned(
                left: (currentPos * itemWidth) + (itemWidth / 2) - 28, // Perfectly Centered X
                top: -25, // <--- MOVED UP (Floats above the bar)
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2.5), // Crisp White Border
                  ),
                  child: Icon(
                    widget.items[widget.currentIndex],
                    color: Colors.black,
                    size: 26,
                  ),
                ),
              );
            },
          ),

          // 3. THE ICONS ROW
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.items.asMap().entries.map((entry) {
                int index = entry.key;
                IconData icon = entry.value;
                bool isSelected = index == widget.currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 75,
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 0.0 : 0.5, // Hide icon if selected
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CURVE PAINTER LOGIC ---
class _NavCurvePainter extends CustomPainter {
  final double position;
  final int itemCount;
  final Color color;

  _NavCurvePainter({required this.position, required this.itemCount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Optional: Add a top border for visibility
    Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path path = Path();

    double itemWidth = size.width / itemCount;
    double loc = (position * itemWidth) + (itemWidth / 2);

    // ADJUST THESE FOR CURVE SHAPE
    double notchWidth = 60; // Tighter width
    double notchDepth = 35; // Shallower depth for shorter bar

    path.moveTo(0, 0);

    // Draw line to start of notch
    path.lineTo(loc - notchWidth, 0);

    // The Curve (Smooth "U" shape)
    path.cubicTo(
      loc - (notchWidth * 0.5), 0,      // Control Point 1
      loc - (notchWidth * 0.5), notchDepth, // Control Point 2
      loc, notchDepth,                  // Bottom Center
    );

    path.cubicTo(
      loc + (notchWidth * 0.5), notchDepth, // Control Point 3
      loc + (notchWidth * 0.5), 0,      // Control Point 4
      loc + notchWidth, 0,              // End of Notch
    );

    // Finish the rectangle
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw Shadow
    canvas.drawShadow(path, Colors.black, 8, true);

    // Draw Main Shape
    canvas.drawPath(path, paint);

    // Draw Border (Optional, remove if you want cleaner look)
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_NavCurvePainter oldDelegate) {
    return oldDelegate.position != position;
  }
}