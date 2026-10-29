import 'package:flutter/material.dart';
import 'package:sini_gan/features/shared/bottom_nav.dart';

class StudentHomeScreen extends StatefulWidget {
  final UserRole role;
  const new({super.key, required this.role});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: SearchBar(
          hintText: 'Search rooms',
          elevation: const WidgetStatePropertyAll(1),
          leading: IconButton(onPressed: (){}, icon: const Icon(Icons.search_rounded)),
          trailing: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Available Rooms'),
      ),
      bottomNavigationBar: BottomNav(
        role: widget.role,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


