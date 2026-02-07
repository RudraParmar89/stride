# TODO: Fix Theme Change Delay

## Problem
Widgets are creating new instances of ThemeManager() instead of using the shared Provider instance, causing theme changes to be delayed until app restart.

## Solution
Replace direct ThemeManager() instantiations with context.watch<ThemeManager>() or Consumer<ThemeManager>.

## Files to Update
- [ ] lib/profile/profile_screen.dart
- [x] lib/home/home_dashboard_page.dart
- [x] lib/home/dashboard/widgets/task_card.dart
- [ ] lib/home/legacy/dashboard_task_tile.dart
- [x] lib/home/dashboard/modals/add_task_sheet.dart
- [ ] lib/home/dashboard/sections/progress_section.dart
- [ ] lib/home/dashboard/sections/quest_tile.dart
- [ ] lib/home/dashboard/sections/hunter_bento_section.dart
- [ ] lib/home/dashboard/sections/header_section.dart
- [ ] lib/home/dashboard/sections/daily_quest_section.dart
- [ ] lib/home/dashboard/modals/add_project_sheet.dart
- [ ] lib/home/dashboard/sections/quick_actions_section.dart
- [ ] lib/home/dashboard/sections/side_quest_section.dart
- [ ] lib/home/dashboard/dashboard_page.dart
- [ ] lib/home/analytics/analytics_page.dart
- [ ] lib/clock/clock_screen.dart
- [ ] lib/calendar/calendar_screen.dart

## Plan
For each file:
1. Change `ListenableBuilder(listenable: ThemeManager(), builder: (context, child) { final theme = ThemeManager(); ...` to `Consumer<ThemeManager>(builder: (context, theme, child) { ...`
2. Ensure no new ThemeManager() instances are created.
