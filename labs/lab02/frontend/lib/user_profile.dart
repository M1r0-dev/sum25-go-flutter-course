// user_profile.dart
import 'package:flutter/material.dart';
import 'user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _name, _email;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.userService.fetchUser().then((data) {
      setState(() {
        _name = data['name'];
        _email = data['email'];
        _loading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = 'error: ${e.toString()}';
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_name!),
        Text(_email!),
      ],
    );
  }
}
