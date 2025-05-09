import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_list_screen.dart';
import 'heart_calculator_screen.dart';
import 'lung_calculator_screen.dart';
import 'justification_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match4Life'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Color(0xFFF8BBD0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome,',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user?.email ?? 'User',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Lung Lists
            ExpansionTile(
              leading: Image.asset(
                'assets/images/lung.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Lung'),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Recipient List'),
                  selected: ModalRoute.of(context)?.settings.name == '/lung/recipients',
                  selectedTileColor: Colors.red.withOpacity(0.08),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(
                          organType: 'lung',
                          listType: 'patient',
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                        settings: const RouteSettings(name: '/lung/recipients'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism),
                  title: const Text('Donor List'),
                  selected: ModalRoute.of(context)?.settings.name == '/lung/donors',
                  selectedTileColor: Colors.red.withOpacity(0.08),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(
                          organType: 'lung',
                          listType: 'donor',
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                        settings: const RouteSettings(name: '/lung/donors'),
                      ),
                    );
                  },
                ),
              ],
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              collapsedIconColor: Colors.red,
              iconColor: Colors.red,
              maintainState: true,
            ),
            // Heart Lists
            ExpansionTile(
              leading: Image.asset(
                'assets/images/heart.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Heart'),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Recipient List'),
                  selected: ModalRoute.of(context)?.settings.name == '/heart/recipients',
                  selectedTileColor: Colors.red.withOpacity(0.08),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(
                          organType: 'heart',
                          listType: 'patient',
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                        settings: const RouteSettings(name: '/heart/recipients'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism),
                  title: const Text('Donor List'),
                  selected: ModalRoute.of(context)?.settings.name == '/heart/donors',
                  selectedTileColor: Colors.red.withOpacity(0.08),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(
                          organType: 'heart',
                          listType: 'donor',
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                        settings: const RouteSettings(name: '/heart/donors'),
                      ),
                    );
                  },
                ),
              ],
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              collapsedIconColor: Colors.red,
              iconColor: Colors.red,
              maintainState: true,
            ),
            const Divider(),
            // Calculators
            ExpansionTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Calculators'),
              children: [
                ListTile(
                  leading: Image.asset(
                    'assets/images/heart.png',
                    width: 24,
                    height: 24,
                  ),
                  title: const Text('Heart Calculator'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HeartCalculatorScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/images/lung.png',
                    width: 24,
                    height: 24,
                  ),
                  title: const Text('Lung Calculator'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LungCalculatorScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            // Justification
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Justification'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JustificationScreen(),
                  ),
                );
              },
            ),
            // Settings
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // Sign Out
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 500)), // Simulate loading
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // If you want to show an empty state, you can check for empty lists here
          // For demonstration, we'll show the main content as before
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/Icon.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Organ Size Matching Assistant',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Streamline your organ size matching process for heart and lung transplantations',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Lung Transplantation',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              title: 'Recipient List',
                              icon: const Icon(Icons.person_outline, size: 32),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientListScreen(
                                      organType: 'lung',
                                      listType: 'patient',
                                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              title: 'Donor List',
                              icon: const Icon(Icons.volunteer_activism, size: 32),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientListScreen(
                                      organType: 'lung',
                                      listType: 'donor',
                                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Heart Transplantation',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              title: 'Recipient List',
                              icon: const Icon(Icons.person_outline, size: 32),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientListScreen(
                                      organType: 'heart',
                                      listType: 'patient',
                                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              title: 'Donor List',
                              icon: const Icon(Icons.volunteer_activism, size: 32),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientListScreen(
                                      organType: 'heart',
                                      listType: 'donor',
                                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Tools',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              title: 'Heart Calculator',
                              icon: Image.asset(
                                'assets/images/heart.png',
                                width: 40,
                                height: 40,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HeartCalculatorScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              title: 'Lung Calculator',
                              icon: Image.asset(
                                'assets/images/lung.png',
                                width: 40,
                                height: 40,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LungCalculatorScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.star_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Key Features',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Column(
                                children: [
                                  _buildFeatureItem(
                                    context,
                                    icon: Icons.calculate_outlined,
                                    title: 'Size Matching Calculator',
                                    description: 'Calculate compatibility scores based on organ measurements and recipient characteristics',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFeatureItem(
                                    context,
                                    icon: Icons.people_outline,
                                    title: 'Recipient & Donor Management',
                                    description: 'Maintain separate lists for heart and lung transplant candidates and donors',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFeatureItem(
                                    context,
                                    icon: Icons.description_outlined,
                                    title: 'Match Justification',
                                    description: 'Document and track the reasoning behind organ size matching decisions',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: Center(child: icon),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 