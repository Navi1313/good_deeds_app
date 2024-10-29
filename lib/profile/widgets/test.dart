import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/app/view/app.dart';
import 'package:good_deeds_app/profile/bloc/profile_bloc.dart';
import 'package:good_deeds_app/profile/widgets/user_profile_create_post.dart';
import 'package:good_deeds_block_ui/good_deeds_blockui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_ui/app_ui.dart'; // For SnackbarMessage and colors
import 'package:posts_repository/posts_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repository/user_repository.dart'; // Ensure this is correctly installed and initialized

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      ),
      child: const AddPost(),
    );
  }
}

// Function to pick image from gallery or camera
Future<Uint8List?> pickImage(ImageSource img) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: img);

  if (file != null) {
    return await file.readAsBytes();
  }
  print('No Image Selected');
  return null;
}

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  Uint8List? _file;
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  // Function to select image
  Future<void> _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a Photo'),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? file = await pickImage(ImageSource.camera);
                if (file != null) {
                  setState(() => _file = file);
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose From Gallery'),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? file = await pickImage(ImageSource.gallery);
                if (file != null) {
                  setState(() => _file = file);
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // Clear selected image
  void clearImage() {
    setState(() => _file = null);
  }

Future<void> _postToDatabase() async {
  setState(() => isLoading = true);

  try {
    final user = Supabase.instance.client.auth.currentUser?.id;
    if (user == null) {
      throw Exception("User not authenticated.");
    }

    final path = '$user/posts/${DateTime.now().toIso8601String()}';

    // Ensure _file is not null
    if (_file == null) {
      throw Exception("No image selected.");
    }

    // Upload image to Supabase storage
    await Supabase.instance.client.storage
        .from('posts')
        .uploadBinary(path, _file!);

    // Generate the public URL for the image
    final imageUrl =
        Supabase.instance.client.storage.from('posts').getPublicUrl(path);

    // Insert post data (description and image URL) into Supabase database
    final response = await Supabase.instance.client.from('posts').insert({
      'user_id': user,
      'caption': descriptionController.text,
      'media': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Check if there was an error in the response
    if (response.error == null && response.data != null) {
      setState(() => isLoading = false);
      clearImage();
      openSnackBar(
        const SnackbarMessage.success(title: 'Posted!'),
      );
    } else {
      setState(() => isLoading = false);
      openSnackBar(
        const SnackbarMessage.error(title: 'Failed to create post!'),
      );
      if (response.error != null) {
        print('Error posting to database: ${response.error!.message}');
      }
    }
  } catch (ex) {
    setState(() => isLoading = false);
    openSnackBar(
      const SnackbarMessage.error(title: 'Failed! Please try again.'),
    );
    print('Error posting to database: $ex');
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final profile = context.select((ProfileBloc bloc) => bloc.state.user);

    return _file == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.upload, size: 60),
                  onPressed: () => _selectImage(context),
                ),
                InkWell(
                  onTap: () => _selectImage(context),
                  child: const Text(
                    'Click here to post the Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: clearImage,
                icon: const Icon(Icons.arrow_back, size: 30),
              ),
              title: const Text(
                'Post to',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ourColor,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _postToDatabase,
                  child: const Text(
                    'Post',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                if (isLoading) const LinearProgressIndicator(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfileAvatar(
                      avatarUrl: profile.avatarUrl,
                      radius: 30,
                    ),
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                        ),
                        maxLines: 10,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_file!),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ],
            ),
          );
  }
}
