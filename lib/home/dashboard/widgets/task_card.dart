import 'package:flutter/material.dart';
import 'package:stride/features/active_session/focus_session_page.dart';
import 'package:stride/features/active_session/run_tracker_page.dart';
import 'package:stride/features/active_session/ml_exercise_page.dart';
import 'package:stride/features/active_session/meditation_session_page.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String tag;
  final int xp;
  final int embers;
  final Color color;
  final bool isCompleted;
  final bool hasAntiChit;
  final bool isUserCreated;
  final String description;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int? durationMinutes;

  const TaskCard({
    super.key,
    required this.title,
    required this.tag,
    required this.xp,
    this.embers = 0,
    required this.color,
    this.isCompleted = false,
    this.hasAntiChit = false,
    this.isUserCreated = false,
    this.description = "",
    this.onTap,
    this.onDelete,
    this.durationMinutes,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  void _handleTap() async {
    await _scaleController.reverse();
    await _scaleController.forward();
    _handleTaskTap(context);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTaskTap(BuildContext context) async {
    if (widget.isCompleted) return;

    if (!widget.hasAntiChit) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: widget.color),
              const SizedBox(width: 10),
              Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 16))),
            ],
          ),
          content: Text(
            "Mark as complete?\n\n+${widget.xp} XP",
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Complete", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true && widget.onTap != null) {
        widget.onTap!();
      }
      return;
    }

    Widget nextScreen;
    final String category = widget.tag.toLowerCase();
    final String name = widget.title.toLowerCase();
    int durationMinutes = widget.durationMinutes ?? _extractDurationFromTitle(widget.title);

    if (category.contains('run') || category.contains('cardio') || name.contains('run')) {
      nextScreen = RunTrackerPage(taskName: widget.title);
    } else if (category.contains('workout') || name.contains('pushup') || name.contains('squat')) {
      nextScreen = MLExercisePage(taskName: widget.title);
    } else if (category.contains('spirit') || name.contains('meditation') || name.contains('mindfulness')) {
      nextScreen = MeditationSessionPage(taskName: widget.title, durationMinutes: durationMinutes);
    } else {
      nextScreen = FocusSessionPage(taskName: widget.title, durationMinutes: durationMinutes);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );

    if (result == true && widget.onTap != null) {
      widget.onTap!();
    }
  }

  int _extractDurationFromTitle(String title) {
    final RegExp regExp = RegExp(r'\((\d+)\s*min\)');
    final match = regExp.firstMatch(title);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '10') ?? 10;
    }
    if (widget.xp > 60) return 30;
    if (widget.xp > 40) return 20;
    return 10;
  }

  void _showEnhancedTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Colors.grey.shade900],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    colors: [widget.color.withOpacity(0.3), widget.color.withOpacity(0.1)],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withOpacity(0.2),
                        border: Border.all(color: widget.color, width: 2),
                      ),
                      child: Center(
                        child: widget.isCompleted
                            ? Icon(Icons.check_circle, color: widget.color, size: 28)
                            : Icon(Icons.assignment, color: widget.color, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tag.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.color,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // REWARDS SECTION
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: widget.color.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "REWARDS",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: widget.color.withOpacity(0.15),
                                      border: Border.all(
                                        color: widget.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "+${widget.xp}",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: widget.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "EXPERIENCE",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (widget.embers > 0) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color(0xFFFF6B6B).withOpacity(0.15),
                                        border: Border.all(
                                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "🔥",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "+${widget.embers}",
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFFF6B6B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "EMBERS",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        "STATUS",
                        widget.isCompleted ? "✅ Completed" : "⏳ Pending",
                        widget.isCompleted ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        "DIFFICULTY",
                        widget.xp > 60 ? "★★★ Hard" : widget.xp > 40 ? "★★ Medium" : "★ Easy",
                        widget.xp > 60 ? Colors.redAccent : widget.xp > 40 ? Colors.orange : Colors.greenAccent,
                      ),
                      const SizedBox(height: 12),
                      if (widget.hasAntiChit) ...[
                        _buildDetailSection(
                          "PROTOCOL",
                          "🛡️ Active Verification Required",
                          Colors.cyan,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (widget.isUserCreated)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDetailSection(
                            "TYPE",
                            "👤 Custom Task",
                            Colors.blue,
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BRIEF",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.description.isNotEmpty
                                  ? widget.description
                                  : "Complete this protocol to maintain discipline and progress.",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.isUserCreated)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            if (widget.onDelete != null) widget.onDelete!();
                          },
                        ),
                      ),
                    if (widget.isUserCreated) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Close"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    if (!widget.isCompleted) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text("Start"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _handleTaskTap(context);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: valueColor.withOpacity(0.15),
            border: Border.all(
              color: valueColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.isCompleted;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleController,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isCompleted ? widget.color.withOpacity(0.15) : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? widget.color.withOpacity(0.6) : Colors.grey.shade800,
                width: isCompleted ? 1.5 : 1,
              ),
              boxShadow: isCompleted
                  ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // CHECKBOX
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted ? widget.color : widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                      : Icon(Icons.circle_outlined, color: widget.color, size: 20),
                ),
                const SizedBox(width: 14),

                // TEXT INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isCompleted ? Colors.grey : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: widget.color,
                        ),
                        child: Text(widget.title),
                      ),
                      const SizedBox(height: 4),
                      // CATEGORY LABEL
                      Text(
                        widget.tag.toUpperCase(),
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // XP REWARD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "+${widget.xp} XP",
                    style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),

                const SizedBox(width: 8),

                // 3-DOT MENU
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 'details') {
                      _showEnhancedTaskDetails(context);
                    } else if (v == 'delete' && widget.onDelete != null) {
                      widget.onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue),
                          SizedBox(width: 10),
                          Text('Details', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    if (widget.isUserCreated && !widget.isCompleted)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
