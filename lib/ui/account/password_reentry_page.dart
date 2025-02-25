// @dart=2.9

import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/core/errors.dart';
import 'package:ente_auth/models/key_attributes.dart';
import 'package:ente_auth/ui/account/recovery_page.dart';
import 'package:ente_auth/ui/common/dialogs.dart';
import 'package:ente_auth/ui/common/dynamic_fab.dart';
import 'package:ente_auth/ui/home_page.dart';
import 'package:ente_auth/utils/dialog_util.dart';
import 'package:ente_auth/utils/email_util.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PasswordReentryPage extends StatefulWidget {
  const PasswordReentryPage({Key key}) : super(key: key);

  @override
  State<PasswordReentryPage> createState() => _PasswordReentryPageState();
}

class _PasswordReentryPageState extends State<PasswordReentryPage> {
  final _logger = Logger((_PasswordReentryPageState).toString());
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  String email;
  bool _passwordInFocus = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    email = Configuration.instance.getEmail();
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordInFocus = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeypadOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    FloatingActionButtonLocation fabLocation() {
      if (isKeypadOpen) {
        return null;
      } else {
        return FloatingActionButtonLocation.centerFloat;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: isKeypadOpen,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _getBody(),
      floatingActionButton: DynamicFAB(
        isKeypadOpen: isKeypadOpen,
        isFormValid: _passwordController.text.isNotEmpty,
        buttonText: 'Verify password',
        onPressedFunction: () async {
          FocusScope.of(context).unfocus();
          final dialog = createProgressDialog(context, "Please wait...");
          await dialog.show();
          try {
            await Configuration.instance.decryptAndSaveSecrets(
              _passwordController.text,
              Configuration.instance.getKeyAttributes(),
            );
          } on KeyDerivationError catch (e, s) {
            _logger.severe("Password verification failed", e, s);
            await dialog.hide();
            final dialogUserChoice = await showChoiceDialog(
              context,
              "Recreate password",
              "The current device is not powerful enough to verify your "
                  "password, so we need to regenerate it once in a way that "
                  "works with all devices. \n\nPlease login using your "
                  "recovery key and regenerate your password (you can use the same one again if you wish).",
              firstAction: "Cancel",
              firstActionColor: Theme.of(context).colorScheme.primary,
              secondAction: "Use recovery key",
              secondActionColor: Theme.of(context).colorScheme.primary,
            );
            if (dialogUserChoice == DialogUserChoice.secondChoice) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const RecoveryPage();
                  },
                ),
              );
            }
            return;
          } catch (e, s) {
            _logger.severe("Password verification failed", e, s);
            await dialog.hide();

            final dialogUserChoice = await showChoiceDialog(
              context,
              "Incorrect password",
              "Please try again",
              firstAction: "Contact Support",
              firstActionColor: Theme.of(context).colorScheme.primary,
              secondAction: "Ok",
              secondActionColor: Theme.of(context).colorScheme.primary,
            );
            if (dialogUserChoice == DialogUserChoice.firstChoice) {
              await sendLogs(
                context,
                "Contact support",
                "support@ente.io",
                postShare: () {},
              );
            }
            return;
          }
          await dialog.hide();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const HomePage();
              },
            ),
            (route) => false,
          );
        },
      ),
      floatingActionButtonLocation: fabLocation(),
      floatingActionButtonAnimator: NoScalingAnimation(),
    );
  }

  Widget _getBody() {
    return Column(
      children: [
        Expanded(
          child: AutofillGroup(
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                Visibility(
                  // hidden textForm for suggesting auto-fill service for saving
                  // password
                  visible: false,
                  child: TextFormField(
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: email,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: TextFormField(
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      filled: true,
                      contentPadding: const EdgeInsets.all(20),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      suffixIcon: _passwordInFocus
                          ? IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).iconTheme.color,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: _passwordController,
                    autofocus: true,
                    autocorrect: false,
                    obscureText: !_passwordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _passwordFocusNode,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const RecoveryPage();
                              },
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            "Forgot password",
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final dialog =
                              createProgressDialog(context, "Please wait...");
                          await dialog.show();
                          await Configuration.instance.logout();
                          await dialog.hide();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: Center(
                          child: Text(
                            "Change email",
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void validatePreVerificationState(KeyAttributes keyAttributes) {
    if (keyAttributes == null) {
      throw Exception("Key Attributes can not be null");
    }
  }
}
