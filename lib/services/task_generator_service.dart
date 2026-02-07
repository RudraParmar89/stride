import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/task.dart';

class TaskGeneratorService {

  static List<Task> generateDailyQuests(UserProfile user, {int userLevel = 1}) {
    List<Task> tasks = [];
    final uuid = const Uuid();
    final now = DateTime.now();

    // Difficulty Scaling
    double difficultyMult = 1.0 + (userLevel * 0.05);

    // Base tasks from identity data
    tasks.addAll(_generateIdentityBasedTasks(user, now, difficultyMult, userLevel));

    // Ensure 9-11 tasks
    while (tasks.length < 9) {
      tasks.add(_generateRandomTask(now));
    }
    if (tasks.length > 11) {
      tasks = tasks.sublist(0, 11);
    }

    return tasks;
  }

  static List<Task> _generateIdentityBasedTasks(UserProfile user, DateTime now, double difficultyMult, int userLevel) {
    List<Task> tasks = [];
    final uuid = const Uuid();

    // 1. Hydration based on weight
    int waterLiters = (user.weight * 0.035).round().clamp(2, 4);
    tasks.add(Task(
      id: uuid.v4(),
      title: "Drink Water ($waterLiters L)",
      category: "Vitality",
      description: "Stay hydrated throughout the day for better performance.",
      xpReward: 25,
      date: now,
    ));

    // 2. Study task based on goal hours with gradual increase
    if (user.expectedGrindHours > 0) {
      double studyHours = _calculateGradualStudyHours(user, now);
      int studyMinutes = (studyHours * 60).toInt();
      tasks.add(Task(
        id: uuid.v4(),
        title: "Study Session (${studyHours.toStringAsFixed(1)}h)",
        category: "Intellect",
        description: "Focused study time. No distractions. Track progress.",
        xpReward: 80,
        embersReward: 5,
        hasAntiChit: true,
        durationMinutes: studyMinutes,
        date: now,
      ));
    }

    // 3. Exercise based on body type and level
    String physique = user.targetPhysique ?? "Balanced";
    final exerciseTask = _getExerciseTaskForLevel(userLevel, physique, difficultyMult);
    
    // Extract duration from title (e.g., "Lower Body Workout (17 min)" -> 17)
    int exerciseDuration = _extractDurationFromTitle(exerciseTask['title']!);
    
    tasks.add(Task(
      id: uuid.v4(),
      title: exerciseTask['title']!,
      category: "Strength",
      description: exerciseTask['desc']!,
      xpReward: 50,
      embersReward: 3,
      hasAntiChit: true,
      durationMinutes: exerciseDuration,
      date: now,
    ));

    // 4. Running/Cardio
    tasks.add(Task(
      id: uuid.v4(),
      title: "Cardio Run (30 min)",
      category: "Cardio",
      description: "Outdoor or treadmill run. Track distance and time.",
      xpReward: 60,
      embersReward: 4,
      hasAntiChit: true,
      date: now,
    ));

    // 5. Meditation
    tasks.add(Task(
      id: uuid.v4(),
      title: "Meditation (20 min)",
      category: "Spirit",
      description: "Guided or silent meditation. Focus on breath.",
      xpReward: 40,
      embersReward: 2,
      hasAntiChit: true,
      date: now,
    ));

    // 5b. Daily Spiritual Task (Neutral for all religions)
    final spiritualTask = _getDailySpiritualTask(now.weekday);
    tasks.add(Task(
      id: uuid.v4(),
      title: spiritualTask['title']!,
      category: "Spirit",
      description: spiritualTask['desc']!,
      xpReward: 35,
      date: now,
    ));

    // 6. Daily Planning
    tasks.add(Task(
      id: uuid.v4(),
      title: "Daily Planning",
      category: "Order",
      description: "Review goals. Schedule time-blocks. Visualize the win.",
      xpReward: 25,
      date: now,
    ));

    // 7. Healthy Eating
    tasks.add(Task(
      id: uuid.v4(),
      title: "Healthy Eating",
      category: "Vitality",
      description: "Eat clean, high-protein meals. Avoid processed sugar.",
      xpReward: 25,
      date: now,
      isCompleted: true,
    ));

    // 8. Skill Development
    final growthTask = _getDailyGrowthTask(now.weekday);
    tasks.add(Task(
      id: uuid.v4(),
      title: growthTask['title']!,
      category: "Growth",
      description: growthTask['desc']!,
      xpReward: 40,
      date: now,
    ));

    // 9. Organization
    final orderTask = _getDailyOrderTask(now.weekday);
    tasks.add(Task(
      id: uuid.v4(),
      title: orderTask['title']!,
      category: "Order",
      description: orderTask['desc']!,
      xpReward: 25,
      date: now,
    ));

    return tasks;
  }

  static Map<String, String> _getExerciseTaskForLevel(int userLevel, String physique, double mult) {
    // Calculate total days since epoch to alternate upper/lower DAILY
    int daysSinceEpoch = DateTime.now().difference(DateTime(1970)).inDays;
    bool isUpperBodyDay = (daysSinceEpoch % 2 == 0); // Even days = Upper, Odd days = Lower

    // First 2 weeks (Levels 1-7): Alternate Upper/Lower Body Workouts
    if (userLevel <= 7) {
      if (isUpperBodyDay) {
        // Upper Body Days
        int reps = (10 + (userLevel * 2)).round(); // Start easy, increase with level
        return {
          'title': "Upper Body Workout ($reps reps)",
          'desc': "Push-ups, planks, and arm exercises. Focus on proper form."
        };
      } else {
        // Lower Body Days
        int duration = (15 + (userLevel * 2)).round(); // Start with 15-20 min
        return {
          'title': "Lower Body Workout ($duration min)",
          'desc': "Squats, lunges, and calf raises. Build leg strength gradually."
        };
      }
    }

    // After 2 weeks (Level 8+): Specific Muscle Group Focus
    return _getAdvancedMuscleGroupWorkout(userLevel, physique, mult);
  }

  static Map<String, String> _getAdvancedMuscleGroupWorkout(int userLevel, String physique, double mult) {
    int weekday = DateTime.now().weekday;
    bool isBulky = physique.contains("Bulky") || physique.contains("Power");
    int baseReps = 15 + (userLevel - 7) * 3; // Increase reps as level grows
    int reps = (baseReps * mult).round();
    int duration = (20 + (userLevel - 7) * 2).round(); // Increase duration

    switch (weekday) {
      case DateTime.monday: // CHEST FOCUS
        return isBulky
            ? {
          'title': "Chest Builder ($reps reps)",
          'desc': "Push-ups, chest press, flyes. Progressive overload for chest development."
        }
            : {
          'title': "Chest Endurance ($duration min)",
          'desc': "High-rep chest exercises. Build muscular endurance."
        };

      case DateTime.tuesday: // BACK FOCUS
        return isBulky
            ? {
          'title': "Back Builder ($reps reps)",
          'desc': "Pull-ups, rows, deadlifts. Strengthen your posterior chain."
        }
            : {
          'title': "Back Mobility ($duration min)",
          'desc': "Yoga flows and stretches for back flexibility."
        };

      case DateTime.wednesday: // LEGS FOCUS
        return isBulky
            ? {
          'title': "Leg Builder ($reps reps)",
          'desc': "Squats, lunges, calf raises. Build powerful legs."
        }
            : {
          'title': "Leg Endurance ($duration min)",
          'desc': "High-intensity leg circuits. Improve cardiovascular fitness."
        };

      case DateTime.thursday: // ARMS FOCUS
        return isBulky
            ? {
          'title': "Arm Builder ($reps reps)",
          'desc': "Bicep curls, tricep extensions, shoulder press. Sculpt your arms."
        }
            : {
          'title': "Arm Toning ($duration min)",
          'desc': "Light weights and high reps for arm definition."
        };

      case DateTime.friday: // FULL BODY
        return {
          'title': "Full Body Circuit ($duration min)",
          'desc': "Compound movements hitting all major muscle groups."
        };

      case DateTime.saturday: // CORE & CARDIO
        return {
          'title': "Core & Cardio ($duration min)",
          'desc': "Ab exercises combined with cardio intervals."
        };

      case DateTime.sunday: // RECOVERY
        return {
          'title': "Active Recovery (20 min)",
          'desc': "Light stretching and mobility work. Rest and recover."
        };

      default:
        return {
          'title': "Bodyweight Circuit ($duration min)",
          'desc': "High-intensity bodyweight exercises. Build endurance."
        };
    }
  }

  static Task _generateRandomTask(DateTime now) {
    final uuid = const Uuid();
    final randomTasks = [
      {'title': "Read 20 pages", 'category': "Growth", 'xp': 30},
      {'title': "Write in journal", 'category': "Identity", 'xp': 25},
      {'title': "Learn new skill", 'category': "Growth", 'xp': 40},
      {'title': "Organize workspace", 'category': "Order", 'xp': 20},
    ];
    final random = randomTasks[DateTime.now().millisecondsSinceEpoch % randomTasks.length];
    return Task(
      id: uuid.v4(),
      title: random['title'] as String,
      category: random['category'] as String,
      description: "Additional task for comprehensive development.",
      xpReward: random['xp'] as int,
      date: now,
    );
  }

  // --- 🏋️ MUSCLE GROUP SPLIT GENERATOR ---
  static List<Map<String, String>> _getDailyMuscleTasks(int weekday, String physique, double mult) {
    bool isBulky = physique.contains("Bulky") || physique.contains("Power");
    int reps = (15 * mult).round();       // For Bulky (Strength)
    int duration = (10 * mult).round();   // For Lean (Time based)

    switch (weekday) {
      case DateTime.monday: // CHEST (Push)
        return isBulky
            ? [
          {'title': "Chest: Wide Pushups", 'desc': "3 Sets of $reps reps. Focus on deep stretch."},
          {'title': "Chest: Diamond Pushups", 'desc': "3 Sets of ${reps - 5} reps. Focus on triceps lockout."}
        ]
            : [
          {'title': "Chest: Plyo Pushups", 'desc': "3 Sets of 10. Explosive movement off the ground."},
          {'title': "Cardio: Burpees", 'desc': "$duration mins continuous. Keep heart rate high."}
        ];

      case DateTime.tuesday: // BACK (Pull)
        return isBulky
            ? [
          {'title': "Back: Pull-Up Negatives", 'desc': "5 Sets of 5 slow descents (5 seconds down)."},
          {'title': "Back: Door Frame Rows", 'desc': "3 Sets of $reps. Squeeze shoulder blades together."}
        ]
            : [
          {'title': "Back: Superman Holds", 'desc': "3 Sets of 45 seconds. Squeeze glutes and back."},
          {'title': "Cardio: Jumping Jacks", 'desc': "$duration mins continuous pace."}
        ];

      case DateTime.wednesday: // LEGS (Quads/Hamstrings)
        return isBulky
            ? [
          {'title': "Legs: Bulgarian Split Squats", 'desc': "3 Sets of 10 per leg. Slow eccentric."},
          {'title': "Legs: Glute Bridges", 'desc': "3 Sets of 20. Hold top for 2 seconds."}
        ]
            : [
          {'title': "Legs: Jump Squats", 'desc': "3 Sets of 15. Land softly."},
          {'title': "Legs: High Knees", 'desc': "$duration mins high intensity interval."}
        ];

      case DateTime.thursday: // SHOULDERS
        return isBulky
            ? [
          {'title': "Delts: Pike Pushups", 'desc': "3 Sets of 10. Simulate overhead press."},
          {'title': "Delts: Lateral Raises", 'desc': "3 Sets of 20 (Use water bottles/books). Control the drop."}
        ]
            : [
          {'title': "Delts: Bear Crawls", 'desc': "3 Rounds of 1 minute. Keep core tight."},
          {'title': "Cardio: Mountain Climbers", 'desc': "$duration mins fast pace."}
        ];

      case DateTime.friday: // ARMS (Biceps/Triceps)
        return isBulky
            ? [
          {'title': "Triceps: Chair Dips", 'desc': "3 Sets to Failure. Keep elbows tucked."},
          {'title': "Biceps: Door Curl Isometrics", 'desc': "3 Sets of 30 sec holds per arm against resistance."}
        ]
            : [
          {'title': "Arms: Shadow Boxing", 'desc': "$duration mins. Weighted hands if possible."},
          {'title': "Arms: Plank Up-Downs", 'desc': "3 Sets of 12. Forearm to hand transition."}
        ];

      case DateTime.saturday: // CORE
        return isBulky
            ? [
          {'title': "Core: Leg Raises", 'desc': "3 Sets of 12. Don't let heels touch ground."},
          {'title': "Core: Hollow Body Hold", 'desc': "3 Sets of 45 seconds."}
        ]
            : [
          {'title': "Core: Bicycle Crunches", 'desc': "3 Sets of 30. Elbow to opposite knee."},
          {'title': "Core: Russian Twists", 'desc': "3 Sets of 30. Feet off ground."}
        ];

      case DateTime.sunday: // RECOVERY
        return [
          {'title': "Recovery: Spine Decompression", 'desc': "Dead hangs or Child's Pose (2 mins)."},
          {'title': "Recovery: Hip Mobility", 'desc': "Pigeon pose & 90/90 stretch (5 mins)."}
        ];

      default:
        return [
          {'title': "Movement A", 'desc': "Move body."},
          {'title': "Movement B", 'desc': "Sweat."}
        ];
    }
  }

  // --- ⭐ NORTH STAR PROTOCOL ---
  static Map<String, String> _getDailyNorthStarTask(int weekday, UserProfile user) {
    if (weekday == DateTime.sunday) {
      return {'title': "Business Blueprint (Strategy)", 'desc': "Decide new business plan. Pivot, refine, or validate. Don't execute—PLAN."};
    } else {
      double studyGoal = user.expectedGrindHours > 0 ? user.expectedGrindHours : 2.0;
      return {'title': "North Star Protocol (${studyGoal.toStringAsFixed(1)}h)", 'desc': "Deep Work. No distractions. Move the needle on your #1 Goal."};
    }
  }

  // --- 🧠 MENTAL FOUNDATION ---
  static Map<String, String> _getDailyMentalTask(int weekday, double mult) {
    switch (weekday) {
      case DateTime.monday: return {'title': "Mental Clarity", 'desc': "Brain dump journaling. Empty the mind."};
      case DateTime.tuesday: return {'title': "Presence Practice", 'desc': "Breath-focused meditation. Count breaths."};
      case DateTime.wednesday: return {'title': "Honest Self-Talk", 'desc': "Write: 'What am I avoiding?'"};
      case DateTime.thursday: return {'title': "Awareness Check", 'desc': "3 mindful check-ins. 'What am I feeling?'"};
      case DateTime.friday: return {'title': "Gratitude Triad", 'desc': "List 3 specific gratitudes. No generics."};
      case DateTime.saturday: return {'title': "Deep Reflection", 'desc': "What gave me energy this week?"};
      case DateTime.sunday:
        int min = (10 * mult).round();
        return {'title': "Stillness ($min min)", 'desc': "Sit quietly. No fixing. Just being."};
      default: return {'title': "Mindfulness", 'desc': "Center your thoughts."};
    }
  }

  // --- 🌱 SKILL DEVELOPMENT ---
  static Map<String, String> _getDailyGrowthTask(int weekday) {
    switch (weekday) {
      case DateTime.monday: return {'title': "Learn New Skill", 'desc': "Spend time learning something new. Quality over quantity."};
      case DateTime.tuesday: return {'title': "Practice Weakness", 'desc': "Work on your weak areas. Face your challenges."};
      case DateTime.thursday: return {'title': "Challenge Belief", 'desc': "Question one limiting belief you hold."};
      case DateTime.friday: return {'title': "Review Progress", 'desc': "Analyze what worked and what didn't this week."};
      case DateTime.saturday: return {'title': "Create Something", 'desc': "Build or make something with your skills."};
      case DateTime.wednesday: return {'title': "Try Something New", 'desc': "Step outside your comfort zone today."};
      case DateTime.sunday: return {'title': "Reflect & Plan", 'desc': "What did you learn? How will you apply it?"};
      default: return {'title': "Personal Growth", 'desc': "Focus on becoming a better version of yourself."};
    }
  }

  // --- 🗓️ ORGANIZATION ---
  static Map<String, String> _getDailyOrderTask(int weekday) {
    switch (weekday) {
      case DateTime.monday: return {'title': "Set Priorities", 'desc': "List your top 3 tasks for the day."};
      case DateTime.tuesday: return {'title': "Clean Workspace", 'desc': "Organize your desk and digital files."};
      case DateTime.wednesday: return {'title': "Clear Notifications", 'desc': "Deal with pending emails and messages."};
      case DateTime.thursday: return {'title': "Plan Tomorrow", 'desc': "Prepare your schedule for the next day."};
      case DateTime.friday: return {'title': "Handle Admin", 'desc': "Complete paperwork and administrative tasks."};
      case DateTime.saturday: return {'title': "Weekly Review", 'desc': "Assess your progress and adjust plans."};
      case DateTime.sunday: return {'title': "Reset Routine", 'desc': "Laundry, meal prep, and home organization."};
      default: return {'title': "Stay Organized", 'desc': "Keep your life in order."};
    }
  }

  // --- 🌈 JOY PROTOCOL ---
  static Map<String, String> _getDailyJoyTask(int weekday) {
    switch (weekday) {
      case DateTime.monday: return {'title': "Identity Reset", 'desc': "Define your traits."};
      case DateTime.tuesday: return {'title': "Creative Spark", 'desc': "Create something small."};
      case DateTime.wednesday: return {'title': "Play Protocol", 'desc': "Fun for 20 mins."};
      case DateTime.thursday: return {'title': "Social Uplink", 'desc': "Connect meaningfully."};
      case DateTime.friday: return {'title': "Raw Expression", 'desc': "Journal freely."};
      case DateTime.saturday: return {'title': "Novelty Injection", 'desc': "Do something new."};
      case DateTime.sunday: return {'title': "Deep Reflection", 'desc': "Identity solidifies in silence."};
      default: return {'title': "Identity Maintenance", 'desc': "Reconnect."};
    }
  }

  // --- 🙏 SPIRITUAL FOUNDATION (Neutral for all religions) ---
  static Map<String, String> _getDailySpiritualTask(int weekday) {
    switch (weekday) {
      case DateTime.monday: return {'title': "Purpose Reflection", 'desc': "Why do you do what you do? Connect with your deeper purpose."};
      case DateTime.tuesday: return {'title': "Gratitude Practice", 'desc': "Express gratitude for 3 things you often take for granted."};
      case DateTime.wednesday: return {'title': "Mindful Walk", 'desc': "Take a slow walk and observe nature without judgment."};
      case DateTime.thursday: return {'title': "Inner Peace", 'desc': "Sit in silence for 10 mins. Notice your thoughts without reaction."};
      case DateTime.friday: return {'title': "Compassion Meditation", 'desc': "Cultivate kindness toward yourself and others."};
      case DateTime.saturday: return {'title': "Values Alignment", 'desc': "Review your actions. Did they align with your values this week?"};
      case DateTime.sunday: return {'title': "Connection & Stillness", 'desc': "Connect with something greater than yourself—however you define it."};
      default: return {'title': "Inner Awareness", 'desc': "Cultivate presence and connection with your inner self."};
    }
  }

  // ================= HELPER: EXTRACT DURATION FROM TITLE =================
  static int _extractDurationFromTitle(String title) {
    // Extract "X min" from "Lower Body Workout (17 min)"
    final regex = RegExp(r'(\d+)\s*min');
    final match = regex.firstMatch(title);
    return match != null ? int.parse(match.group(1)!) : 30; // Default 30 min
  }

  // ================= GRADUAL STUDY HOURS CALCULATION =================
  static double _calculateGradualStudyHours(UserProfile user, DateTime now) {
    if (user.startDate == null) return user.currentStudyHours;

    final daysPassed = now.difference(user.startDate!).inDays;
    final current = user.currentStudyHours;
    final goal = user.expectedGrindHours;

    if (daysPassed <= 0) return current;
    if (current >= goal) return goal;

    // Gradual increase: add 0.5h per day until goal
    final target = current + (daysPassed * 0.5);
    return target.clamp(current, goal);
  }
}
