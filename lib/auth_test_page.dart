// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:thirikkale_rider/core/providers/auth_provider.dart';
// import 'package:thirikkale_rider/features/authenctication/screens/signup_flow_demo.dart';
// import 'package:thirikkale_rider/widgets/network_test_widget.dart';

// /// Quick test page to demonstrate the new auth flow
// /// Add this to your main.dart for testing
// class AuthTestPage extends StatelessWidget {
//   const AuthTestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Auth Integration Test'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Network Test Section
//             const NetworkTestWidget(),

//             // Auth Test Section
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.phone_android, size: 80, color: Colors.blue),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Thirikkale Rider Auth Test',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Test the complete signup and login flow',
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const SignupFlowDemo(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 16,
//                       ),
//                     ),
//                     child: const Text(
//                       'Test Auth Flow',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       return Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               'Current Auth State:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               authProvider.authState.name.toUpperCase(),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             if (authProvider.currentUser != null) ...[
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Logged in as: ${authProvider.currentUser!.fullName}',
//                                 style: const TextStyle(color: Colors.green),
//                               ),
//                             ],
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 32),
//                   _buildDebugSection(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Add this to your main.dart to test:
// /*
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:thirikkale_rider/core/providers/auth_provider.dart';
// import 'package:thirikkale_rider/auth_test_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Thirikkale Rider',
//         home: const AuthTestPage(),
//       ),
//     );
//   }
// }
// */

// class DebugParametersWidget extends StatelessWidget {
//   const DebugParametersWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         border: Border.all(color: Colors.green),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.code, color: Colors.green),
//               const SizedBox(width: 8),
//               const Text(
//                 'Debug: Parameters Sent to Backend',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             '✅ PARAMETERS BEING SENT (Check Flutter console for real-time logs):',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'LOGIN Request Parameters:',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           const Text(
//             '• phoneNumber: "+91XXXXXXXXXX"\n'
//             '• firebaseUid: "firebase_generated_uid"\n'
//             '• Authorization: "Bearer firebase_id_token"',
//             style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'REGISTRATION Request Parameters:',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           const Text(
//             '• phoneNumber: "+91XXXXXXXXXX"\n'
//             '• firstName: "User entered name"\n'
//             '• lastName: "User entered last name" (optional)\n'
//             '• email: "user@example.com" (optional)\n'
//             '• dateOfBirth: "2000-01-01T00:00:00.000Z" (optional)\n'
//             '• emergencyContactName: "Emergency contact" (optional)\n'
//             '• emergencyContactPhone: "Emergency contact phone" (optional)\n'
//             '• gender: "male" or "female" (optional)\n'
//             '• womenOnlyAccess: true or false (optional)',
//             style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget _buildDebugSection() {
//   return Container(
//     margin: const EdgeInsets.all(16),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.green[50],
//       border: Border.all(color: Colors.green),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.bug_report, color: Colors.green),
//             const SizedBox(width: 8),
//             const Text(
//               'Backend Parameter Debug',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           '✅ FIXED: Updated to match your Spring Boot backend',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//         ),
//         const SizedBox(height: 12),
//         _buildEndpointInfo('Registration', 'POST /api/v1/riders/register', [
//           '📋 Request Body: RiderRegistrationRequest',
//           '  • phoneNumber: String (from Firebase)',
//           '  • firstName: String (required)',
//           '  • lastName: String (optional)',
//           '  • email: String (optional)',
//           '  • dateOfBirth: String (ISO format, optional)',
//           '  • emergencyContactName: String (optional)',
//           '  • emergencyContactPhone: String (optional)',
//           '  • gender: String (optional)',
//           '  • womenOnlyAccess: boolean (optional)',
//           '',
//           '🔑 URL Parameter: firebaseIdToken',
//           '❌ NO UUID fields sent (auto-generated by backend)',
//         ]),
//         const SizedBox(height: 16),
//         _buildEndpointInfo('Login', 'POST /api/v1/riders/login', [
//           '🔑 URL Parameter: firebaseIdToken',
//           '📋 Request Body: EMPTY',
//           '❌ NO other parameters needed',
//           '📱 Phone number extracted from Firebase token',
//         ]),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue[50],
//             border: Border.all(color: Colors.blue),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '🔧 Backend Controller Fix:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Make sure your RiderController route order is:\n'
//                 '1. @PostMapping("/register") // SPECIFIC\n'
//                 '2. @PostMapping("/login")    // SPECIFIC\n'
//                 '3. @GetMapping("/{riderId}") // WILDCARD LAST',
//                 style: TextStyle(fontFamily: 'monospace', fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildEndpointInfo(String title, String endpoint, List<String> details) {
//   return Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       border: Border.all(color: Colors.grey[300]!),
//       borderRadius: BorderRadius.circular(6),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           endpoint,
//           style: const TextStyle(
//             fontFamily: 'monospace',
//             color: Colors.blue,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ...details.map(
//           (detail) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 1),
//             child: Text(detail, style: const TextStyle(fontSize: 12)),
//           ),
//         ),
//       ],
//     ),
//   );
// }
