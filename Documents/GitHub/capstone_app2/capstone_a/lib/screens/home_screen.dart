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
        title: const Text('Organ Size Matching'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  title: const Text('Patient List'),
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
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism),
                  title: const Text('Donor List'),
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
                      ),
                    );
                  },
                ),
              ],
            ),
            // Heart Lists
            ExpansionTile(
              leading: Image.asset(
                'assets/images/heart.png',
                width: 32,
                height: 32,
              ),
              title: const Text('Heart'),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Patient List'),
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
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism),
                  title: const Text('Donor List'),
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
                      ),
                    );
                  },
                ),
              ],
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/AppIcon.png',
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
                  const SizedBox(height: 16),
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
                          title: 'Patient List',
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
                  const SizedBox(height: 24),
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
                          title: 'Patient List',
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
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Key Features',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: 'Size Matching Calculator',
                    description: 'Calculate compatibility scores based on organ measurements and patient characteristics',
                    icon: Icons.calculate_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    title: 'Patient & Donor Management',
                    description: 'Maintain separate lists for heart and lung transplant candidates and donors',
                    icon: Icons.people_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    title: 'Match Justification',
                    description: 'Document and track the reasoning behind organ size matching decisions',
                    icon: Icons.description_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              icon,
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 