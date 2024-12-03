import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ProfileView extends StatefulWidget {
  final String displayName;
  final String userEmail;
  final String photoUrl;

  const ProfileView({
    super.key,
    required this.displayName,
    required this.userEmail,
    required this.photoUrl,
  });

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isProfileExpanded = false;
  bool isHowItWorksExpanded = false;
  bool isFeedbackExpanded = false;
  bool isPrivacyPolicyExpanded = false;
  String feedbackText = '';

  final Color col0xFF0C356A = const Color(0xFF0C356A);
  final Color col0xFF979797 = const Color(0xFF979797);
  final Color col0xFF49454F = const Color(0xFF49454F);

  final TextStyle textStyle14Black = TextStyle(
    fontFamily: 'League Spartan',
    fontSize: 14.sp,
    color: Colors.black,
  );

  // Controller to manage feedback input
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController
        .dispose(); // Dispose the controller when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C356A)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: col0xFF0C356A,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // User Profile Section
                  _buildUserProfileSection(),
                  SizedBox(height: 20.h),

                  // Divider
                  Divider(color: col0xFF979797, thickness: 1.h),

                  // Options Section
                  Text(
                    "Options",
                    style: TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: col0xFF0C356A,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Option: How Andlet Works
                  _buildExpandableSection(
                    title: "How Andlet works?",
                    isExpanded: isHowItWorksExpanded,
                    onToggle: () => setState(() {
                      isHowItWorksExpanded = !isHowItWorksExpanded;
                    }),
                    content: Text(
                      "Andlet connects students and landlords through a secure, user-friendly platform that simplifies housing searches near Los Andes University. Students create profiles, set preferences, and explore verified listings using advanced filters, while landlords manage and update properties seamlessly.",
                      style: textStyle14Black,
                    ),
                  ),

                  Divider(color: col0xFF979797, thickness: 1.h),

                  // Option: Feedback
                  _buildExpandableSection(
                    title: "Report a bug",
                    isExpanded: isFeedbackExpanded,
                    onToggle: () => setState(() {
                      isFeedbackExpanded = !isFeedbackExpanded;
                    }),
                    content: _buildFeedbackSection(),
                  ),

                  Divider(color: col0xFF979797, thickness: 1.h),

                  // Option: Privacy Policy
                  _buildExpandableSection(
                    title: "Privacy policy",
                    isExpanded: isPrivacyPolicyExpanded,
                    onToggle: () => setState(() {
                      isPrivacyPolicyExpanded = !isPrivacyPolicyExpanded;
                    }),
                    content: Text(
                      "Andlet ('we,' 'our,' or 'us') is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our app. By using Andlet, you agree to the terms outlined below.\n\n"
                      "1. Information We Collect\n"
                      "We may collect the following types of information:\n\n"
                      "• Personal Information: Name, email address, profile photo, and university affiliation, provided during registration.\n"
                      "• Location Data: Your location, if you grant permission, to provide location-based features.\n"
                      "• Usage Data: Information about how you interact with the app, including search preferences, saved listings, and communication with landlords.\n\n"
                      "2. How We Use Your Information\n"
                      "We use your information to:\n\n"
                      "• Provide, personalize, and improve the app experience.\n"
                      "• Match you with housing options tailored to your preferences.\n"
                      "• Facilitate communication between students and landlords.\n"
                      "• Send notifications about updates, new listings, or app features.\n"
                      "• Ensure trust and security by verifying user profiles and listings.\n\n"
                      "3. Sharing Your Information\n"
                      "We do not sell your personal information. However, we may share your information:\n\n"
                      "• With landlords: When you interact with a listing, landlords may see limited details like your name and contact information.\n"
                      "• With service providers: Trusted third-party services that help us operate the app (e.g., hosting, analytics).\n"
                      "• As required by law: To comply with legal obligations or enforce our policies.\n\n"
                      "4. Data Security\n"
                      "We take appropriate technical and organizational measures to protect your data against unauthorized access, loss, or misuse. However, no system is completely secure, and we cannot guarantee the absolute security of your data.\n\n"
                      "5. Your Rights\n"
                      "You have the right to:\n\n"
                      "• Access and update your personal information.\n"
                      "• Request the deletion of your account and associated data.\n"
                      "• Control your privacy settings, such as location-sharing permissions.\n"
                      "• Opt out of non-essential communications.\n\n"
                      "To exercise these rights, please contact us at support-andlet@gmail.com.\n\n"
                      "6. Third-Party Links\n"
                      "Andlet may contain links to third-party websites or services. We are not responsible for their privacy practices or content. Please review their privacy policies before sharing any information.\n\n"
                      "7. Changes to This Privacy Policy\n"
                      "We may update this Privacy Policy from time to time. Any changes will be posted in the app, and your continued use of Andlet constitutes acceptance of the updated policy.\n\n"
                      "8. Contact Us\n"
                      "If you have any questions or concerns about this Privacy Policy, please contact us at support-andlet@gmail.com.",
                      style: textStyle14Black,
                    ),
                  ),

                  Divider(color: col0xFF979797, thickness: 1.h),
                ],
              ),
            ),
          ),
          // Logout Button
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
    String firstName = widget.displayName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.photoUrl.isNotEmpty
                  ? NetworkImage(widget.photoUrl)
                  : const AssetImage('lib/assets/personaicono.png'),
              radius: 25.r,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName,
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 20.sp,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isProfileExpanded = !isProfileExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        "Show profile",
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 14.sp,
                          color: col0xFF49454F,
                        ),
                      ),
                      Icon(
                        isProfileExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: col0xFF49454F,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isProfileExpanded) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProfileDetail("Legal Name", widget.displayName),
              _buildProfileDetail("Email", widget.userEmail),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProfileDetail(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 16.sp,
            color: col0xFF49454F,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF49454F),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 15.sp,
                    color: const Color(0xFF49454F),
                  ),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: const Color(0xFF49454F),
              ),
            ],
          ),
        ),
        if (isExpanded)
          Padding(padding: EdgeInsets.only(top: 8.h), child: content),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    Future<bool> isConnected() async {
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    Future<void> submitFeedback() async {
      try {
        // Get reference to the feedback document for the user
        final userFeedbackDoc = FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(widget.userEmail);

        final docSnapshot = await userFeedbackDoc.get();
        int nextId = 1;

        if (docSnapshot.exists) {
          // Parse keys to find the highest numeric ID
          final data = docSnapshot.data()!;
          final keys = data.keys.map((key) => int.tryParse(key) ?? 0).toList();
          if (keys.isNotEmpty) {
            nextId = keys.reduce((a, b) => a > b ? a : b) + 1;
          }
        }

        // Prepare feedback data
        final feedbackData = {
          'date': Timestamp.now(), // Store date as Firestore Timestamp
          'description': feedbackText.trim(), // Trim spaces and newlines
        };

        // Submit feedback
        await userFeedbackDoc.set({
          nextId.toString(): feedbackData,
        }, SetOptions(merge: true));

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting report: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    void showConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Submission"),
            content: const Text("Are you sure you want to submit this report?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Close dialog
                child: const Text("No",
                    style: TextStyle(color: Color(0xFF0C356A))),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await submitFeedback();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C356A),
                ),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          maxLength: 200,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Awesome report",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              feedbackText = value;
            });
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              // Check if feedback is empty or contains only spaces/newlines
              if (feedbackText.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Report cannot be empty."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Check internet connectivity
              final connected = await isConnected();
              if (!connected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("No internet connection. Please try again later."),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              showConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C356A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              "Submit",
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(LogoutRequested());

          // Navigate to login page after logging out
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        },
        icon: const Icon(Icons.logout, color: Color(0xFF49454F)),
        label: Text(
          "Log out",
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 15.sp,
            color: col0xFF49454F,
          ),
        ),
      ),
    );
  }
}
