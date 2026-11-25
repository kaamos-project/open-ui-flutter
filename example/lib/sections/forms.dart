import 'package:flutter/widgets.dart';
import 'package:kaamos_project_ui/kaamos_project_ui.dart';

import 'section.dart';

class FormSection extends StatefulWidget {
  const FormSection({super.key});

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  bool _newsletter = true;
  bool? _all;
  double _volume = 0.4;
  String? _lingua;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Form',
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              const GalleryLabel('Text field'),
              const KaamosTextField(
                placeholder: 'tu@esempio.org',
                semanticLabel: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
              ),
              const KaamosTextField(placeholder: 'Password', obscureText: true),
              KaamosTextField(
                controller: TextEditingController(text: 'non-una-email'),
                invalid: true,
              ),
              const KaamosTextField(
                  placeholder: 'Disabilitato', enabled: false),
              const GalleryLabel('Search bar'),
              KaamosSearchBar(
                placeholder: 'Search...',
                semanticLabel: 'Cerca estensioni',
                onChanged: (q) => setState(() => _query = q),
                trailing: const KaamosKeycap('/'),
              ),
              if (_query.isNotEmpty) Text('Stai cercando: $_query'),
              const GalleryLabel('Select'),
              KaamosSelect<String>(
                value: _lingua,
                placeholder: 'Scegli una lingua',
                semanticLabel: 'Lingua',
                onChanged: (v) => setState(() => _lingua = v),
                options: const [
                  KaamosSelectOption(
                      value: 'fi', label: 'Suomi', group: 'Paesi nordici'),
                  KaamosSelectOption(
                      value: 'sv', label: 'Svenska', group: 'Paesi nordici'),
                  KaamosSelectOption(
                      value: 'no', label: 'Norsk', group: 'Paesi nordici'),
                  KaamosSelectOption(
                      value: 'is',
                      label: 'Íslenska',
                      group: 'Paesi nordici',
                      enabled: false),
                  KaamosSelectOption(
                      value: 'it', label: 'Italiano', group: 'Altre'),
                  KaamosSelectOption(
                      value: 'en', label: 'English', group: 'Altre'),
                ],
              ),
              const GalleryLabel('Checkbox'),
              KaamosCheckbox(
                value: _newsletter,
                onChanged: (v) => setState(() => _newsletter = v!),
                label: const Text('Iscrivimi alla newsletter'),
              ),
              KaamosCheckbox(
                value: _all,
                tristate: true,
                onChanged: (v) => setState(() => _all = v),
                label: const Text('Tutti i file (tristate)'),
              ),
              const KaamosCheckbox(
                  value: true, onChanged: null, label: Text('Disabilitata')),
              const GalleryLabel('Slider'),
              KaamosSlider(
                value: _volume,
                semanticLabel: 'Volume',
                onChanged: (v) => setState(() => _volume = v),
              ),
              Text('Volume: ${(_volume * 100).round()}%'),
            ],
          ),
        ),
      ],
    );
  }
}
