// ignore: file_names
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:good_deeds_app/app/bloc/app_bloc.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

class UserPage extends StatelessWidget {
  const UserPage({
    required this.userId,
    super.key,
  });
  final String userId;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userId: userId,
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      )..add(const UserProfileSubscriptionRequested()),
      child: const UserView(),
    );
  }
}

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileBloc bloc) => bloc.state.user);
    final isOwner = context.select((ProfileBloc bloc) => bloc.isOwner);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture, Name, and Job Title
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      user.avatarUrl ?? '',
                    ), // Use your profile image link
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ' ${user.fullName} ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${user.email}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics (Campaigns, Donated, Generated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('2', 'Events'),
                  _buildStatCard('100', 'Trust Score'),
                  _buildStatCard('11', 'Your Trusts'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Edit Profile, My Campaigns, History, Achievements options
            _buildOption(context, Icons.edit, 'Edit Profile', () {}),
            _buildOption(context, Icons.campaign, 'My Campaigns', () {}),
            _buildOption(context, Icons.history, 'History', () {}),
            _buildOption(context, Icons.emoji_events, 'Achievement', () {}),
            if (isOwner) ...[
              _buildOption(context, Icons.settings, 'Settings', () {}),
            ],

            _buildOption(
            
              context,
              Icons.logout,
              'Log Out',
              () {
                context.confirmAction(
                  fn: () {
                    context.pop();
                    context.read<AppBloc>().add(const AppLogoutRequested());
                  },
                  title: 'Log Out',
                  content: 'Are you sure you want to Log Out?',
                  noText: 'Cancel',
                  yesText: 'Log Out',
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // Bottom Navigation Bar
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.ourColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.ourColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () {},
      child: Icon(Icons.adaptive.more_outlined, size: AppSize.iconSize),
    );
  }
}

class UserProfileSettingsButton extends StatelessWidget {
  const UserProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () {},
      child: Assets.icons.setting.svg(
        height: AppSize.iconSize,
        width: AppSize.iconSize,
        colorFilter: ColorFilter.mode(
          context.adaptiveColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () {},
      child: const Icon(
        Icons.add_box_outlined,
        size: AppSize.iconSize,
      ),
    );
  }
}
