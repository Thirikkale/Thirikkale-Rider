  // void _showCancelConfirmation(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Cancel Ride?'),
  //       content: const Text(
  //         'Are you sure you want to cancel this ride? You may be charged a cancellation fee.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Keep Ride'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _cancelRide();
  //           },
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: const Text('Cancel Ride'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _cancelRide() async {
  //   try {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //     final rideBookingProvider = Provider.of<RideBookingProvider>(context, listen: false);
  //     final token = await authProvider.getCurrentToken();
  //     final rideId = rideBookingProvider.rideId;

  //     if (token != null && rideId.isNotEmpty) {
  //       await RideStatusService.cancelRide(
  //         rideId: rideId,
  //         token: token,
  //         reason: 'User requested cancellation',
  //       );
        
  //       if (mounted) {
  //         Navigator.pop(context);
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to cancel ride: $e')),
  //       );
  //     }
  //   }
  // }

  // Widget _buildDriverOnWayContent() {
  //   return Container(
  //     height: 350,
  //     padding: const EdgeInsets.all(20),
  //     decoration: const BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Driver is on the way',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
          
  //         // Driver info card
  //         if (driverName != null) _buildDriverInfoCard(),
          
  //         const SizedBox(height: 16),
  //         _buildTripDetailsCard(),
          
  //         const Spacer(),
          
  //         // Contact driver button
  //         if (driverPhone != null)
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton.icon(
  //               onPressed: () {
  //                 // Add call functionality
  //               },
  //               icon: const Icon(Icons.phone),
  //               label: const Text('Call Driver'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.green,
  //                 foregroundColor: Colors.white,
  //                 padding: const EdgeInsets.symmetric(vertical: 16),
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDriverArrivedContent() {
  //   return Container(
  //     height: 350,
  //     padding: const EdgeInsets.all(20),
  //     decoration: const BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Driver has arrived!',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.green,
  //           ),
  //         ),
  //         const Text(
  //           'Your driver is waiting for you',
  //           style: TextStyle(fontSize: 14, color: Colors.grey),
  //         ),
  //         const SizedBox(height: 16),
          
  //         if (driverName != null) _buildDriverInfoCard(),
          
  //         const SizedBox(height: 16),
  //         _buildTripDetailsCard(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildInProgressContent() {
  //   return Container(
  //     height: 350,
  //     padding: const EdgeInsets.all(20),
  //     decoration: const BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Trip in progress',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const Text(
  //           'Enjoy your ride!',
  //           style: TextStyle(fontSize: 14, color: Colors.grey),
  //         ),
  //         const SizedBox(height: 16),
          
  //         if (driverName != null) _buildDriverInfoCard(),
          
  //         const SizedBox(height: 16),
  //         _buildTripDetailsCard(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCompletedContent() {
  //   return Container(
  //     height: 350,
  //     padding: const EdgeInsets.all(20),
  //     decoration: const BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       children: [
  //         const Icon(Icons.check_circle, color: Colors.green, size: 48),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Trip Completed!',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
          
  //         _buildTripDetailsCard(),
          
  //         const SizedBox(height: 16),
          
  //         // Rate ride button
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             onPressed: () => _showRatingDialog(),
  //             child: const Text('Rate Your Trip'),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCancelledContent() {
  //   return Container(
  //     height: 350,
  //     padding: const EdgeInsets.all(20),
  //     decoration: const BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       children: [
  //         const Icon(Icons.cancel, color: Colors.red, size: 48),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Ride Cancelled',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.red,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
          
  //         const Text(
  //           'Your ride has been cancelled',
  //           style: TextStyle(fontSize: 14, color: Colors.grey),
  //         ),
          
  //         const SizedBox(height: 30),
          
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Back to Home'),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDriverInfoCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[100],
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       children: [
  //         CircleAvatar(
  //           radius: 24,
  //           backgroundColor: Colors.blue,
  //           child: Text(
  //             driverName?.substring(0, 1).toUpperCase() ?? 'D',
  //             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 driverName ?? 'Driver',
  //                 style: const TextStyle(fontWeight: FontWeight.w600),
  //               ),
  //               if (vehicleDetails != null)
  //                 Text(
  //                   vehicleDetails!,
  //                   style: const TextStyle(color: Colors.grey, fontSize: 12),
  //                 ),
  //             ],
  //           ),
  //         ),
  //         if (driverPhone != null)
  //           IconButton(
  //             onPressed: () {
  //               // Add call functionality
  //             },
  //             icon: const Icon(Icons.phone, color: Colors.green),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // void _showRatingDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Rate Your Trip'),
  //       content: const Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text('How was your ride?'),
  //           SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               Icon(Icons.star_border, size: 32),
  //               Icon(Icons.star_border, size: 32),
  //               Icon(Icons.star_border, size: 32),
  //               Icon(Icons.star_border, size: 32),
  //               Icon(Icons.star_border, size: 32),
  //             ],
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Skip'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             Navigator.pop(context); // Go back to home
  //           },
  //           child: const Text('Submit'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
