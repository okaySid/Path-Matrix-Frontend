import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/shared_widgets.dart';

class NewAnalysisModal extends StatefulWidget {
  const NewAnalysisModal({super.key});

  @override
  State<NewAnalysisModal> createState() => _NewAnalysisModalState();
}

class _NewAnalysisModalState extends State<NewAnalysisModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isGenerating = true);

    try {
      final message = await context.read<AppState>().addProject(
        _nameController.text.trim(),
        _urlController.text.trim(),
        _tokenController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        // Green snackbar with Spring Boot's success message
        ScaffoldMessenger.of(context).showSnackBar(greenSnackbar(message));
          // SnackBar(
          //   content: Row(
          //     children: [
          //       const Icon(Icons.check_circle_outline,
          //           color: Colors.white, size: 16),
          //       const SizedBox(width: 8),
          //       Expanded(child: Text(message)),
          //     ],
          //   ),
          //   backgroundColor: AppTheme.success,
          //   behavior: SnackBarBehavior.floating,
          //   width: 360,
          //   duration: const Duration(seconds: 6),
          // ),
        
      }
    } catch (e) {
      // Red snackbar with Spring Boot's error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(redSnackbar(e.toString().replaceAll('Exception: ', '')));
          // SnackBar(
          //   content: Row(
          //     children: [
          //       const Icon(Icons.error_outline,
          //           color: Colors.white, size: 16),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(e.toString().replaceAll('Exception: ', '')),
          //       ),
          //     ],
          //   ),
          //   backgroundColor: Colors.red.shade700,
          //   behavior: SnackBarBehavior.floating,
          //   width: 360,
          //   duration: const Duration(seconds: 6),
          // ),
        // );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxWidth: 520),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(28),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ModalHeader(),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Project Name',
                        hint: 'e.g. Onboarding Flow',
                        controller: _nameController,
                        autofillHints: const [AutofillHints.organizationName],
                        prefix: const Icon(Icons.folder_outlined,
                            size: 18, color: AppTheme.textTertiary),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Project name is required';
                          if (v.trim().length < 3)
                            return 'Name must be at least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Figma File URL',
                        hint: 'https://www.figma.com/file/...',
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        autofillHints: const [AutofillHints.url],
                        prefix: const Icon(Icons.link,
                            size: 18, color: AppTheme.textTertiary),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Figma URL is required';
                          if (!v.contains('figma.com'))
                            return 'Must be a valid Figma URL';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Figma API Token',
                        hint: 'figd_xxxxxxxxxxxxxxxxxxxxxxxx',
                        controller: _tokenController,
                        obscureText: true,
                        autofillHints: const [],
                        prefix: const Icon(Icons.key_outlined,
                            size: 18, color: AppTheme.textTertiary),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'API token is required';
                          if (v.trim().length < 10)
                            return 'Invalid token format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      const _TokenHelpText(),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _isGenerating
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              side: const BorderSide(color: AppTheme.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed:
                                _isGenerating ? null : _handleGenerate,
                            icon: _isGenerating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_fix_high, size: 16),
                            label: Text(_isGenerating
                                ? 'Generating...'
                                : 'Generate Analysis'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isGenerating)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const LoadingOverlay(
                      message: 'Analyzing Figma flows...'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add_chart,
              color: AppTheme.primaryLight, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Analysis',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text('Enter your Figma file details to begin',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close,
              size: 18, color: AppTheme.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _TokenHelpText extends StatelessWidget {
  const _TokenHelpText();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.help_outline, size: 13, color: AppTheme.textTertiary),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Generate your token at figma.com → Account Settings → Personal Access Tokens',
            style: TextStyle(
                fontSize: 11, color: AppTheme.textTertiary, height: 1.4),
          ),
        ),
      ],
    );
  }
}
