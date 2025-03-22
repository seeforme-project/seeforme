import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../loginsignup/volunteer_signup.dart';
import '../globals/theme.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final String currentDateTime = "2025-03-01 12:46:39";
    final String userLogin = "mujtaba-io";

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: RosePineColors.base,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Floating Status Card
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: RosePineColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: RosePineColors.muted.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.solidClock,
                                color: RosePineColors.iris,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                currentDateTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: RosePineColors.iris,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: RosePineColors.muted.withOpacity(0.4),
                          ),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.solidUser,
                                color: RosePineColors.iris,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                userLogin,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: RosePineColors.iris,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Title
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            /*Text(
                              'See for Me',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: RosePineColors.iris.withOpacity(0.15),
                                shadows: [
                                  Shadow(
                                    blurRadius: 20,
                                    color: RosePineColors.iris.withOpacity(0.1),
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              textScaler: const TextScaler.linear(1.1),
                            ),*/
                            Column(
                              children: [
                                Text(
                                  'See for Me',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    color: RosePineColors.text,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: RosePineColors.iris,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: 60,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: RosePineColors.iris,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Help the blind',
                                  style: TextStyle(
                                    color: RosePineColors.rose,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),

                        // Volunteer Button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: OverflowBox(
                                    maxHeight: 58 * 1.8,
                                    child: Transform.scale(
                                      scaleY: 1.8,
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        color: RosePineColors.iris
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: RosePineColors.pine,
                                borderRadius: BorderRadius.circular(30),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VolunteerSignupScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  highlightColor:
                                      Colors.transparent.withOpacity(0.1),
                                  splashColor:
                                      RosePineColors.foam.withOpacity(0.1),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.handsHelping,
                                          size: 22,
                                          color: RosePineColors.text,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'I am Volunteer',
                                          style: TextStyle(
                                            color: RosePineColors.text,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Decorative Element
                        SizedBox(
                          width: size.width * 0.7,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: RosePineColors.muted.withOpacity(0.4),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: FaIcon(
                                  FontAwesomeIcons.solidStar,
                                  size: 14,
                                  color: RosePineColors.gold,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: RosePineColors.muted.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Voice Command Button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: Material(
                            color: RosePineColors.surface,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(30),
                              highlightColor:
                                  Colors.transparent.withOpacity(0.1),
                              splashColor: RosePineColors.foam.withOpacity(0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color:
                                        RosePineColors.muted.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          for (var height in [
                                            10,
                                            18,
                                            26,
                                            18,
                                            10
                                          ])
                                            Container(
                                              width: 3,
                                              height: height.toDouble(),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              decoration: BoxDecoration(
                                                color: RosePineColors.rose,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'say "I\'m blind"',
                                      style: TextStyle(
                                        color: RosePineColors.text,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: Text(
                      'Begin your journey',
                      style: TextStyle(
                        color: RosePineColors.subtle,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: RosePineColors.base,
      ),
    );
  }
}
