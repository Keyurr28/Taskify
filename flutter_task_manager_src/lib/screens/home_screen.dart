import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_form_dialog.dart';
import '../theme/app_theme.dart';
import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _showTaskForm(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const TaskFormDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isMobile = constraints.maxWidth < 600;
        
        return Scaffold(
          body: Row(
            children: [
              if (isDesktop) _buildSidebar(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.backgroundDark, Color(0xFF141E30)],
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      );
                    },
                    child: _selectedIndex == 0 
                      ? _buildDashboard(context, constraints, isMobile, isDesktop)
                      : const SettingsView(key: ValueKey('settings')),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: !isDesktop ? _buildBottomNav() : null,
          floatingActionButton: (isDesktop || _selectedIndex != 0) 
              ? const SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () => _showTaskForm(context),
                  backgroundColor: AppTheme.primaryAccent,
                  child: const Icon(Icons.add, color: Colors.white),
                  elevation: 8,
                ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: AppTheme.surfaceDark,
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryAccent,
        unselectedItemColor: AppTheme.textSecondary,
        elevation: 16,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, BoxConstraints constraints, bool isMobile, bool isDesktop) {
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    
    return Column(
      key: const ValueKey('dashboard'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, isDesktop, isMobile, horizontalPadding),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
          child: isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SingleChildScrollView(scrollDirection: Axis.horizontal, child: FilterBar()),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: _buildSortDropdown(context)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FilterBar(),
                  _buildSortDropdown(context),
                ],
              ),
        ),
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              if (provider.tasks.isEmpty) {
                return const EmptyState();
              }
              if (constraints.maxWidth > 1100) {
                return _buildGrid(provider, 3, horizontalPadding);
              } else if (constraints.maxWidth > 700) {
                return _buildGrid(provider, 2, horizontalPadding);
              } else {
                return _buildList(provider, horizontalPadding);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskSort>(
              value: provider.currentSort,
              icon: const Icon(Icons.sort, color: AppTheme.textSecondary, size: 20),
              dropdownColor: AppTheme.surfaceDark,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              items: TaskSort.values.map((sort) {
                String label;
                switch (sort) {
                  case TaskSort.newest: label = 'Newest'; break;
                  case TaskSort.dueDate: label = 'Due Date'; break;
                  case TaskSort.priority: label = 'Priority'; break;
                }
                return DropdownMenuItem(
                  value: sort,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(label),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) provider.setSort(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.task_alt, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('Taskify', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSidebarItem(context, Icons.dashboard_rounded, 'Dashboard', 0),
          _buildSidebarItem(context, Icons.settings_rounded, 'Settings', 1),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () => _showTaskForm(context),
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppTheme.primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryAccent.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary),
        title: Text(title, style: TextStyle(color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop, bool isMobile, double padding) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, isMobile ? 16 : 32, padding, 16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary, fontSize: isMobile ? 14 : 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Let\'s get things done',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: isMobile ? 22 : 28),
                ),
              ],
            ),
            Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final progress = provider.allTasksCount == 0 ? 0.0 : provider.completedTasksCount / provider.allTasksCount;
                return Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: isMobile ? 32 : 40,
                        height: isMobile ? 32 : 40,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              color: AppTheme.secondaryAccent,
                              strokeWidth: isMobile ? 4 : 6,
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 9 : 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Today\'s Progress', style: Theme.of(context).textTheme.bodyMedium),
                            Text('${provider.completedTasksCount} of ${provider.allTasksCount} tasks', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(TaskProvider provider, double padding) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16).copyWith(bottom: 80),
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TaskCard(task: provider.tasks[index], key: ValueKey(provider.tasks[index].id)),
        );
      },
    );
  }

  Widget _buildGrid(TaskProvider provider, int crossAxisCount, double padding) {
    return GridView.builder(
      padding: EdgeInsets.all(padding).copyWith(bottom: 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(task: provider.tasks[index], key: ValueKey(provider.tasks[index].id));
      },
    );
  }
}
