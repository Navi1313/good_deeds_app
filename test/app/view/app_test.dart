import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_deeds_app/app/view/app.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUser extends Mock implements User {}

class MockPostRepository extends Mock implements PostsRepository {}

void main() {
  group('App', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(
        App(
          postsRepository: MockPostRepository(),
          user: MockUser(),
          userRepository: MockUserRepository(),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
