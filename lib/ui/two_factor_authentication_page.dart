// @dart=2.9

import 'package:ente_auth/services/user_service.dart';
import 'package:ente_auth/ui/lifecycle_event_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';

class TwoFactorAuthenticationPage extends StatefulWidget {
  final String sessionID;

  const TwoFactorAuthenticationPage(this.sessionID, {Key key})
      : super(key: key);

  @override
  State<TwoFactorAuthenticationPage> createState() =>
      _TwoFactorAuthenticationPageState();
}

class _TwoFactorAuthenticationPageState
    extends State<TwoFactorAuthenticationPage> {
  final _pinController = TextEditingController();
  String _code = "";
  LifecycleEventHandler _lifecycleEventHandler;

  @override
  void initState() {
    _lifecycleEventHandler = LifecycleEventHandler(
      resumeCallBack: () async {
        if (mounted) {
          final data = await Clipboard.getData(Clipboard.kTextPlain);
          if (data != null && data.text != null && data.text.length == 6) {
            _pinController.text = data.text;
          }
        }
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleEventHandler);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleEventHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Two-factor authentication",
        ),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    final pinPutDecoration = BoxDecoration(
      border: Border.all(
        color: Theme.of(context)
            .inputDecorationTheme
            .focusedBorder
            .borderSide
            .color,
      ),
      borderRadius: BorderRadius.circular(15.0),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          "Enter the 6-digit code from\nyour authenticator app",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.all(32)),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: PinPut(
            fieldsCount: 6,
            onSubmit: (String code) {
              _verifyTwoFactorCode(code);
            },
            onChanged: (String pin) {
              setState(() {
                _code = pin;
              });
            },
            controller: _pinController,
            submittedFieldDecoration: pinPutDecoration.copyWith(
              borderRadius: BorderRadius.circular(20.0),
            ),
            selectedFieldDecoration: pinPutDecoration,
            followingFieldDecoration: pinPutDecoration.copyWith(
              borderRadius: BorderRadius.circular(5.0),
            ),
            inputDecoration: const InputDecoration(
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              counterText: '',
            ),
            autofocus: true,
          ),
        ),
        const Padding(padding: EdgeInsets.all(24)),
        Container(
          padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
          width: double.infinity,
          height: 64,
          child: OutlinedButton(
            onPressed: _code.length == 6
                ? () async {
                    _verifyTwoFactorCode(_code);
                  }
                : null,
            child: const Text("Verify"),
          ),
        ),
        const Padding(padding: EdgeInsets.all(30)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            UserService.instance.recoverTwoFactor(context, widget.sessionID);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Center(
              child: Text(
                "Lost device?",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _verifyTwoFactorCode(String code) async {
    await UserService.instance.verifyTwoFactor(context, widget.sessionID, code);
  }
}
