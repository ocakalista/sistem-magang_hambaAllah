import 'package:flutter/material.dart';

import '../../models/application_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'internship_detail_screen.dart';

class AllInternshipsScreen extends StatefulWidget {
  static const routeName = '/lowongan';

  const AllInternshipsScreen({super.key});

  @override
  State<AllInternshipsScreen> createState() => _AllInternshipsScreenState();
}

class _AllInternshipsScreenState extends State<AllInternshipsScreen> {
  final _searchController = TextEditingController();
  List<Internship> _internships = const [];
  String? _selectedCategory;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiService.fetchLowonganMahasiswa(null);
      if (!mounted) return;
      setState(() {
        _internships = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Internship> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    return _internships.where((internship) {
      final matchesSearch =
          query.isEmpty ||
          internship.position.toLowerCase().contains(query) ||
          internship.company.toLowerCase().contains(query) ||
          internship.location.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null ||
          internship.tags.any(
            (tag) => tag.toLowerCase() == _selectedCategory!.toLowerCase(),
          );
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _internships.expand((item) => item.tags).toSet().toList()..sort();
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Semua Lowongan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari posisi, perusahaan, atau lokasi...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon:
                        _searchController.text.isEmpty
                            ? null
                            : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                  ),
                ),
              ),
            ),
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 54,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      ChoiceChip(
                        label: const Text('Semua'),
                        selected: _selectedCategory == null,
                        labelStyle: TextStyle(
                          color:
                              _selectedCategory == null
                                  ? Colors.white
                                  : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color:
                              _selectedCategory == null
                                  ? AppColors.primary
                                  : const Color(0xFFE3D9F7),
                        ),
                        onSelected:
                            (_) => setState(() => _selectedCategory = null),
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            labelStyle: TextStyle(
                              color:
                                  _selectedCategory == category
                                      ? Colors.white
                                      : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            side: BorderSide(
                              color:
                                  _selectedCategory == category
                                      ? AppColors.primary
                                      : const Color(0xFFE3D9F7),
                            ),
                            onSelected:
                                (_) => setState(
                                  () => _selectedCategory = category,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: _ErrorState(message: _error!, onRetry: _load),
              )
            else if (filtered.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Lowongan tidak ditemukan.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final internship = filtered[index];
                    return _InternshipListCard(
                      internship: internship,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => InternshipDetailScreen(
                                    internship: internship,
                                  ),
                            ),
                          ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InternshipListCard extends StatelessWidget {
  const _InternshipListCard({required this.internship, required this.onTap});

  final Internship internship;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      internship.position,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (internship.company.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        internship.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            internship.location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (internship.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            internship.tags
                                .map(
                                  (tag) => Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(tag),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
