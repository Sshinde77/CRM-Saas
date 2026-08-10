import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../models/plan_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ApiService _apiService;
  late final PageController _pageController;
  late Future<_PlansPageData> _plansFuture;

  bool _isMonthly = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _pageController = PageController(viewportFraction: 0.9);
    _plansFuture = _loadPlansPageData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _apiService.close();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<_PlansPageData> _loadPlansPageData() async {
    final results = await Future.wait([
      _apiService.fetchPlans(),
      _apiService.fetchAuthMeDetails(),
    ]);

    return _PlansPageData(
      plans: results[0] as List<PlanModel>,
      authMe: results[1] as AuthMeResponse,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Plans'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Plans',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: FutureBuilder<_PlansPageData>(
                future: _plansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final data = snapshot.data;
                  final plans = data?.plans ?? const <PlanModel>[];
                  if (plans.isEmpty) {
                    return _buildEmptyState();
                  }

                  final currentPlan = _resolveCurrentPlan(plans, data?.authMe);
                  final orderedPlans = _sortPlans(plans);
                  if (_currentPage >= orderedPlans.length) {
                    _currentPage = 0;
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                    child: Column(
                      children: [
                        _buildHeroSection(
                          selectedPlan: orderedPlans[_currentPage],
                          topPlan: orderedPlans.first,
                        ),
                        const SizedBox(height: 12),
                        _buildCurrentPlanCard(currentPlan, data?.authMe),
                        const SizedBox(height: 24),
                        _buildBillingToggle(),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 360,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: orderedPlans.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final plan = orderedPlans[index];
                              final isCurrent = currentPlan.id == plan.id;
                              final isTopPlan = index == 0;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == orderedPlans.length - 1
                                      ? 0
                                      : 10,
                                ),
                                child: _buildSliderCard(
                                  plan,
                                  isCurrent: isCurrent,
                                  isTopPlan: isTopPlan,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDots(orderedPlans.length),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final selectedPlan = orderedPlans[_currentPage];
                              _showMessage(
                                'Upgrade to ${selectedPlan.name} clicked',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Upgrade Plan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  PlanModel _resolveCurrentPlan(List<PlanModel> plans, AuthMeResponse? authMe) {
    final organization = authMe?.organization;
    final currentPlanId = organization?.planId?.trim();
    if (currentPlanId != null && currentPlanId.isNotEmpty) {
      for (final plan in plans) {
        if (plan.id == currentPlanId) {
          return plan;
        }
      }
      final apiPlan = organization?.plan;
      if (apiPlan != null && apiPlan.id.trim().isNotEmpty) {
        return apiPlan;
      }
    }

    if (organization?.plan != null) {
      final apiPlan = organization!.plan!;
      for (final plan in plans) {
        if (plan.id == apiPlan.id) {
          return plan;
        }
      }
      return apiPlan;
    }

    for (final plan in plans) {
      if (plan.isDefault) {
        return plan;
      }
    }
    for (final plan in plans) {
      if (plan.isActive) {
        return plan;
      }
    }
    return plans.first;
  }

  List<PlanModel> _sortPlans(List<PlanModel> plans) {
    final sorted = List<PlanModel>.from(plans);
    sorted.sort((a, b) {
      final freeA = _isFreePlan(a);
      final freeB = _isFreePlan(b);
      if (freeA != freeB) {
        return freeA ? -1 : 1;
      }

      final priceA = _selectedPrice(a);
      final priceB = _selectedPrice(b);
      final compared = priceB.compareTo(priceA);
      if (compared != 0) {
        return compared;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  num _selectedPrice(PlanModel plan) {
    return _isMonthly ? plan.priceMonthly : plan.priceYearly;
  }

  bool _isFreePlan(PlanModel plan) {
    final planName = plan.name.trim().toLowerCase();
    return planName == 'free' ||
        planName.startsWith('free ') ||
        planName.endsWith(' free') ||
        planName.contains('free plan');
  }

  Widget _buildHeroSection({
    required PlanModel selectedPlan,
    required PlanModel topPlan,
  }) {
    final isTopPlanSelected = selectedPlan.id == topPlan.id;
    final title = isTopPlanSelected ? 'Upgrade Your Plan' : 'Choose Your Plan';
    final subtitle = isTopPlanSelected
        ? 'Unlock more capacity, more control, and the strongest plan for growing teams.'
        : 'Pick the plan that gives your team the room to grow without hitting limits.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF4FBF1), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 0,
            height: 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.activeMenuBg.withValues(alpha: 0.65),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 0,
              color: AppColors.green.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.statusActiveText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(PlanModel currentPlan, AuthMeResponse? authMe) {
    final organization = authMe?.organization;
    final subtitle = _currentPlanSubtitle(currentPlan, organization);
    final statusLabel = _currentPlanStatusLabel(organization);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFEFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.activeMenuBg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.activeMenuBg.withValues(alpha: 0.34),
                  AppColors.surface,
                ],
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      currentPlan.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 7,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: _formatCyclePrice(currentPlan),
                        style: const TextStyle(
                          color: AppColors.statusActiveText,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(text: '  $subtitle'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _currentPlanSubtitle(
    PlanModel currentPlan,
    AuthMeOrganization? organization,
  ) {
    if (organization?.status == 'trial') {
      final trialDaysLeft = organization?.trialDaysLeft;
      if (trialDaysLeft != null) {
        return trialDaysLeft <= 0
            ? 'Your trial has expired. Upgrade to continue.'
            : 'Trial active with $trialDaysLeft days left.';
      }
      return 'Trial active for this organization.';
    }

    if (currentPlan.isDefault) {
      return 'Current default plan';
    }
    return 'Currently selected subscription';
  }

  String _currentPlanStatusLabel(AuthMeOrganization? organization) {
    if (organization?.status == 'trial') {
      final trialDaysLeft = organization?.trialDaysLeft;
      if (trialDaysLeft != null && trialDaysLeft <= 0) {
        return 'Trial expired';
      }
      return 'Trial active';
    }
    return 'Current plan';
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(
            label: 'Monthly',
            isActive: _isMonthly,
            onTap: () {
              setState(() {
                _isMonthly = true;
                _currentPage = 0;
              });
              _pageController.jumpToPage(0);
            },
          ),
          _toggleButton(
            label: 'Yearly',
            isActive: !_isMonthly,
            onTap: () {
              setState(() {
                _isMonthly = false;
                _currentPage = 0;
              });
              _pageController.jumpToPage(0);
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard(
    PlanModel plan, {
    required bool isCurrent,
    required bool isTopPlan,
  }) {
    final savings = _savingsPercentage(plan);
    final price = _selectedPrice(plan);
    final originalPrice = _isMonthly
        ? plan.originalPriceMonthly
        : plan.originalPriceYearly;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrent
              ? AppColors.activeMenuBg
              : AppColors.borderLight.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusActiveBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isCurrent
                    ? 'Current Plan'
                    : (isTopPlan ? 'Upgrade Your Plan' : plan.name),
                style: const TextStyle(
                  color: AppColors.statusActiveText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            plan.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _planSubtitle(plan),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildFeatureRows(plan),
          const Spacer(),
          Divider(
            height: 1,
            color: AppColors.borderStrong.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            runSpacing: 6,
            children: [
              Text(
                _formatPrice(price),
                style: const TextStyle(
                  color: AppColors.statusActiveText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _isMonthly ? '/month' : '/year',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (originalPrice != null && originalPrice > price)
                Text(
                  _formatPrice(originalPrice),
                  style: const TextStyle(
                    color: AppColors.textLightMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (savings != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sell_outlined,
                      size: 16,
                      color: AppColors.statusActiveIcon,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Save $savings%',
                      style: const TextStyle(
                        color: AppColors.statusActiveText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Text(
                isTopPlan
                    ? 'Best value across available plans'
                    : 'Flexible upgrade option',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureRows(PlanModel plan) {
    final rows = <Widget>[];
    final accentIcons = <IconData>[
      Icons.view_list_rounded,
      Icons.all_inclusive_rounded,
      Icons.block_rounded,
      Icons.people_alt_outlined,
      Icons.shopping_bag_outlined,
    ];

    if (plan.maxUsers != null) {
      rows.add(
        _featureRow(Icons.people_alt_outlined, '${plan.maxUsers} users'),
      );
    }
    if (plan.maxOrders != null) {
      rows.add(
        _featureRow(Icons.inventory_2_outlined, '${plan.maxOrders} orders'),
      );
    }

    for (var i = 0; i < plan.features.length; i++) {
      rows.add(
        _featureRow(accentIcons[i % accentIcons.length], plan.features[i]),
      );
    }

    if (rows.isEmpty) {
      rows.add(_featureRow(Icons.verified_outlined, 'Access included'));
    }

    return rows
        .map(
          (row) =>
              Padding(padding: const EdgeInsets.only(bottom: 10), child: row),
        )
        .toList();
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.statusActiveIcon),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.borderStrong,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.textSecondary,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load plans',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _plansFuture = _loadPlansPageData();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No plans available right now.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
    );
  }

  String _planSubtitle(PlanModel plan) {
    if (plan.isDefault) {
      return 'Best starting option for new organizations.';
    }
    if (plan.isActive) {
      return 'This plan is active and ready for use.';
    }
    return 'Unlock more capacity and features with this tier.';
  }

  String _formatCyclePrice(PlanModel plan) {
    final price = _selectedPrice(plan);
    return '${_formatPrice(price)} ${_isMonthly ? '/month' : '/year'}';
  }

  String _formatPrice(num value) {
    return 'Rs. ${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
  }

  String? _savingsPercentage(PlanModel plan) {
    final original = _isMonthly
        ? plan.originalPriceMonthly
        : plan.originalPriceYearly;
    final current = _selectedPrice(plan);
    if (original == null || original <= current || original <= 0) {
      return null;
    }

    final savings = (((original - current) / original) * 100).round();
    if (savings <= 0) {
      return null;
    }
    return '$savings';
  }
}

class _PlansPageData {
  final List<PlanModel> plans;
  final AuthMeResponse authMe;

  const _PlansPageData({required this.plans, required this.authMe});
}
