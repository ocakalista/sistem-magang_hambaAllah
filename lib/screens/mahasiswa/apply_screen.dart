import 'package:flutter/material.dart';

import '../../models/application_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import 'application_status_screen.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key, required this.internship});

  final Internship internship;

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController(
    text: 'Ahmad Ramadhan',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+62 812-3456-7890',
  );
  final TextEditingController _semesterController = TextEditingController(
    text: 'Semester 6',
  );
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  int _currentStep = 0;
  String? _cvFileName;
  double _cvUploadProgress = 0;
  String? _portfolioSelection;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _semesterController.addListener(() => setState(() {}));
    _portfolioController.addListener(() => setState(() {}));
    _motivationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    _portfolioController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  bool get _uploadsReady {
    return _cvFileName != null &&
        (_portfolioSelection != null ||
            _portfolioController.text.trim().isNotEmpty) &&
        _motivationController.text.trim().length >= 120;
  }

  bool get _canSubmit {
    final detailsValid =
        _fullNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _semesterController.text.trim().isNotEmpty;
    return detailsValid && _uploadsReady;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Nexus',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply for Internship',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.internship.position} at ${widget.internship.company}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StepIndicator(currentStep: _currentStep),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() => _currentStep = value),
              children: [
                _buildDetailsStep(),
                _buildUploadsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft saved locally for later review.'),
                    ),
                  );
                },
                child: const Text('Save Draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        _currentStep == 2 && _canSubmit
                            ? const [AppColors.primary, AppColors.secondary]
                            : [
                              AppColors.primary.withValues(alpha: 0.5),
                              AppColors.secondary.withValues(alpha: 0.5),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ElevatedButton.icon(
                  onPressed:
                      _currentStep == 2 && _canSubmit
                          ? () => _submitApplication(context)
                          : (_currentStep < 2
                              ? () {
                                if (_currentStep == 0 &&
                                    !(_detailsFormKey.currentState
                                            ?.validate() ??
                                        false)) {
                                  return;
                                }
                                if (_currentStep == 1 && !_uploadsReady) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please complete your CV, portfolio, and motivation letter before continuing.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                );
                              }
                              : null),
                  icon: Icon(
                    _currentStep == 2
                        ? Icons.send_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _currentStep == 2 ? 'Submit Application' : 'Continue',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle('Personal Details'),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter your full name'
                          : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter your phone number'
                          : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _semesterController,
              decoration: const InputDecoration(
                labelText: 'University Semester',
              ),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter your semester'
                          : null,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Snapshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SnapshotRow(
                    label: 'Position',
                    value: widget.internship.position,
                  ),
                  _SnapshotRow(
                    label: 'Company',
                    value: widget.internship.company,
                  ),
                  _SnapshotRow(
                    label: 'Location',
                    value: widget.internship.location,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Documents'),
          const SizedBox(height: 14),
          _UploadCard(
            title: 'Upload CV / Resume',
            subtitle: 'PDF, Max 5MB',
            icon: Icons.description_outlined,
            actionLabel: _cvFileName == null ? 'Upload' : 'Replace',
            onAction: _pickCvFile,
            fileName: _cvFileName,
            progress: _cvUploadProgress,
          ),
          const SizedBox(height: 14),
          _PortfolioDropZone(
            selection: _portfolioSelection,
            controller: _portfolioController,
            onTap: _pickPortfolio,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Motivation Letter',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_motivationController.text.length} / 1000 characters',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _motivationController,
                  maxLines: 7,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    hintText:
                        'Tell the team why this internship matters to you and how your design or product experience can contribute.',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: keep it specific. Mention a portfolio project, a product insight, or a design challenge you solved.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Review Application'),
          const SizedBox(height: 14),
          _ReviewCard(
            title: 'Personal Details',
            onEdit:
                () => _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                ),
            children: [
              _SnapshotRow(label: 'Full Name', value: _fullNameController.text),
              _SnapshotRow(label: 'Phone', value: _phoneController.text),
              _SnapshotRow(label: 'Semester', value: _semesterController.text),
            ],
          ),
          const SizedBox(height: 14),
          _ReviewCard(
            title: 'Uploads',
            onEdit:
                () => _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                ),
            children: [
              _SnapshotRow(label: 'CV', value: _cvFileName ?? 'Not uploaded'),
              _SnapshotRow(
                label: 'Portfolio',
                value: _portfolioSelection ?? _portfolioController.text,
              ),
              _SnapshotRow(
                label: 'Letter',
                value:
                    '${_motivationController.text.length} characters written',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ReviewCard(
            title: 'Position Applied',
            onEdit: () {},
            children: [
              _SnapshotRow(
                label: 'Position',
                value: widget.internship.position,
              ),
              _SnapshotRow(label: 'Company', value: widget.internship.company),
              _SnapshotRow(
                label: 'Location',
                value: widget.internship.location,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _canSubmit
                ? 'Your application is ready to submit.'
                : 'Complete the uploads and motivation letter to unlock submission.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _canSubmit ? AppColors.primary : AppColors.neutral,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _pickCvFile() {
    setState(() {
      _cvFileName = 'Ahmad_Ramadhan_CV.pdf';
      _cvUploadProgress = 1;
    });
  }

  void _pickPortfolio() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.link_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Use portfolio link'),
                subtitle: const Text('behance.net/ahmad-ramadhan'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _portfolioSelection = 'behance.net/ahmad-ramadhan';
                    _portfolioController.text = _portfolioSelection!;
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Attach portfolio PDF'),
                subtitle: const Text('Ahmad_Portfolio_TechNova.pdf'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _portfolioSelection = 'Ahmad_Portfolio_TechNova.pdf';
                    _portfolioController.text = _portfolioSelection!;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _submitApplication(BuildContext context) {
    final state = NexusScope.of(context);
    final application = Application(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      internship: widget.internship,
      status: ApplicationStatus.submitted,
      appliedDate: DateTime.now(),
    );
    state.submitApplication(application);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted successfully.')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationStatusScreen(application: application),
      ),
    );
  }

  Widget _cardTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = ['Details', 'Uploads', 'Review'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineStep = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color:
                  lineStep < currentStep
                      ? AppColors.primary
                      : const Color(0xFFE3DFEB),
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        return Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                    isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isCompleted || isCurrent
                          ? AppColors.primary
                          : const Color(0xFFD9D4E4),
                ),
              ),
              child: Center(
                child:
                    isCompleted
                        ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                        : Text(
                          '${stepIndex + 1}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: isCurrent ? Colors.white : AppColors.neutral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.neutral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.neutral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.fileName,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final String? fileName;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAction,
                icon: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (fileName != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                fileName!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: const Color(0xFFE7E1F4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}

class _PortfolioDropZone extends StatelessWidget {
  const _PortfolioDropZone({
    required this.selection,
    required this.controller,
    required this.onTap,
  });

  final String? selection;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Work Portfolio',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Link or PDF Document',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selection ?? 'Tap to attach portfolio',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selection == null
                        ? 'Drag-and-drop style placeholder area'
                        : 'Selected portfolio will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Portfolio Link or File Name',
              hintText: 'behance.net/your-profile or .pdf file',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.children,
    required this.onEdit,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
