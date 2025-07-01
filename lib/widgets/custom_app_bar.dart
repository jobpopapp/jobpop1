import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String? userEmail;
  final String? userPhone;
  final String? profilePhotoUrl;
  final List<Widget>? actions;
  final Color backgroundColor;

  const CustomAppBar({
    Key? key,
    required this.username,
    this.userEmail,
    this.userPhone,
    this.profilePhotoUrl,
    this.actions,
    this.backgroundColor = const Color(0xFFFFD23F),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      backgroundColor: backgroundColor,
      elevation: 0,
      title: Row(
        children: [
          if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(profilePhotoUrl!),
                backgroundColor: Colors.grey[200],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isNotEmpty ? username : 'User',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (userEmail != null && userEmail!.isNotEmpty)
                  Text(
                    userEmail!,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Color.fromARGB(255, 122, 0, 0),
                    ),
                  ),
                if (userPhone != null && userPhone!.isNotEmpty)
                  Text(
                    userPhone!,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Color.fromARGB(255, 105, 0, 0),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
