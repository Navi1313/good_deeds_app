import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/selector/locale/bloc/locale_bloc.dart';

/// A drop down menu to select a new [Locale]
///
/// Requires a [LocaleBloc] to be provided in the widget tree
/// (usually above [MaterialApp])
class LocaleSelector extends StatelessWidget {
  const LocaleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleBloc>().state;

    return DropdownButton(
      key: const Key('language'),
      onChanged: (locale) =>
          context.read<LocaleBloc>().add(LocaleChanged(locale)),
      value: locale,
      items: const [
        DropdownMenuItem(
          value: Locale('en', 'US'),
          child: Text(
            'English',
            key: Key('localeSelector_en_dropdownMenuItem'),
          ),
        ),
        DropdownMenuItem(
          value: Locale('ru', 'RU'),
          child: Text(
            'Hindi',
            key: Key('localeSelector_ru_dropdownMenuItem'),
          ),
        ),
      ],
    );
  }
}

class LocaleModalOption extends StatelessWidget {
  const LocaleModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: LocaleSelector(),
      title: Text('Language'),
    );
  }
}
