import 'package:animate_do/animate_do.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/onboarding/on_boarding_provider.dart';
import 'package:good_deeds_app/auth/auth.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_repository/user_repository.dart';

import 'donor_status_provider.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  bool onLastPage = false;
  final controller = PageController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    // final widthScreen = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => SignUpCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(bottom: heightScreen * 0.1),
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() => onLastPage = index == 2);
            },
            children: <Widget>[
              FadeInRight(
                child: const OnboardingContent(
                  image: 'packages/app_ui/assets/images/handsTogether.png',
                  heading: 'Welcome to the Good Deed',
                  description:
                      'This is the way we are connecting donors with the needed ',
                  onLastPage: false,
                ),
              ),
              FadeInRight(
                child: const OnboardingContent(
                  image: 'packages/app_ui/assets/images/boys.jpg',
                  heading: 'Get Started with one helping hand',
                  description:
                      // ignore: lines_longer_than_80_chars
                      'This is the way we are connecting donors with the needed ',
                  onLastPage: false,
                ),
              ),
              FadeInRight(
                child: const OnboardingContent(
                  image: 'packages/app_ui/assets/images/childerns.jpg',
                  heading: 'Confirm Your Role ? ',
                  description:
                      // ignore: lines_longer_than_80_chars
                      'If you are belonging to NGO then click on Ngo Login else Login as Donor ',
                  onLastPage: true,
                ),
              ),
            ],
          ),
        ),
        // Bottom Sheet to fill with container :->
        bottomSheet: onLastPage
            ? Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Connecting Hands Together',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: FontFamily.montserrat,
                      color: AppColors.ourColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: heightScreen * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => controller.jumpToPage(2),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.ourColor,
                        ),
                      ),
                    ),
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: 3,
                        effect: const WormEffect(
                          spacing: 16,
                          activeDotColor: AppColors.ourColor,
                        ),
                        onDotClicked: (index) => controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.nextPage(
                        duration: const Duration(
                          microseconds: 6,
                        ),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text(
                        'Next',
                        style:
                            TextStyle(fontSize: 24, color: AppColors.ourColor),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class OnboardingContent extends ConsumerWidget {
  const OnboardingContent({
    required this.image,
    required this.heading,
    required this.description,
    required this.onLastPage,
    super.key,
  });

  final String image;
  final String heading;
  final String description;
  final bool onLastPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heightScreen = MediaQuery.of(context).size.height;
    final widthScreen = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Add minimal top padding
            SizedBox(height: paddingTop + 10),

            // Larger image container
            Container(
              width: widthScreen,
              height: heightScreen * 0.45, // Increased height ratio
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: heightScreen * 0.03),

            // Heading with adjusted spacing
            Text(
              heading,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: heightScreen * 0.02),

            // Description with adjusted spacing
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: heightScreen * 0.03),

            // Compact buttons for the last page
            if (onLastPage) ...[
              const Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: NgoModalOption(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: DonorModalOption(),
                    ),
                  ),
                ],
              ),
            ],
            // Minimal bottom padding
            SizedBox(height: heightScreen * 0.01),
          ],
        ),
      ),
    );
  }
}

class NgoModalOption extends ConsumerWidget {
  const NgoModalOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<SignUpCubit, SignupState>(
      builder: (context, state) {
        return Tappable.faded(
          onTap: () => context.confirmAction(
            fn: () async {
              context.read<SignUpCubit>().toggleIsDonor(false);
              await ref.read(donorStatusProvider.notifier)
              .setDonorStatus(false); // Set as NGO (false)
              await ref
                  .read(onboardingNotifierProvider.notifier)
                  .completeOnboarding();
              context.go('/auth');
            },
            title: 'Read Carefully',
            content: 'Are you sure you want to Login as NGO?',
            noText: 'Cancel',
            yesText: 'Confirm',
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(249, 25, 127, 1),
                  AppColors.ourColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'NGO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Slightly smaller font
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DonorModalOption extends ConsumerWidget {
  const DonorModalOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<SignUpCubit, SignupState>(
      builder: (context, state) {
        return Tappable.faded(
          onTap: () => context.confirmAction(
            fn: () async {
              context.read<SignUpCubit>().toggleIsDonor(true);
              await ref.read(donorStatusProvider.notifier)
              .setDonorStatus(true); // Set as NGO (false)
              await ref
                  .read(onboardingNotifierProvider.notifier)
                  .completeOnboarding();
              context.go('/auth');
            },
            title: 'Read Carefully',
            content: 'Are you sure you want to Login as Donor?',
            noText: 'Cancel',
            yesText: 'Confirm',
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(249, 25, 127, 1),
                  AppColors.ourColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0), // Reduced padding
              child: Text(
                'DONOR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Slightly smaller font
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
