// @dart=2.9

import 'package:ente_auth/services/user_service.dart';
import 'package:ente_auth/utils/dialog_util.dart';
import 'package:ente_auth/utils/email_util.dart';
import 'package:flutter/material.dart';

class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({Key key}) : super(key: key);

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  String _email;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter your email address"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: Colors.white30,
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              initialValue: _email,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.redAccent,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text(
            "Verify",
            style: TextStyle(
              color: Colors.purple,
            ),
          ),
          onPressed: () {
            if (!isValidEmail(_email)) {
              showErrorDialog(
                context,
                "Invalid email address",
                "Please enter a valid email address.",
              );
              return;
            }
            UserService.instance.sendOtt(context, _email, isChangeEmail: true);
          },
        ),
      ],
    );
  }
}
