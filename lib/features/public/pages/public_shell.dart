import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/public_header.dart';
import '../widgets/public_sections.dart';
import '../widgets/blood_request_dialog.dart';

/// The public marketing site served at `/`. A sticky [PublicHeader] sits above
/// a single scroll view of themed sections; header nav items anchor-scroll to
/// their section. All data is static placeholder content in this slice —
/// action CTAs route to `/login`.
class PublicShell extends ConsumerStatefulWidget {
  const PublicShell({super.key});

  @override
  ConsumerState<PublicShell> createState() => _PublicShellState();
}

class _PublicShellState extends ConsumerState<PublicShell> {
  final _scrollController = ScrollController();
  String _activeId = 'home';

  // Anchor keys for each nav target.
  final _keys = <String, GlobalKey>{
    'home': GlobalKey(),
    'vitals': GlobalKey(),
    'queue': GlobalKey(),
    'blood': GlobalKey(),
    'blog': GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(String id) {
    setState(() => _activeId = id);
    final key = _keys[id];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.02,
      );
    }
  }

  void _goLogin() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);

    return Scaffold(
      backgroundColor: t.bgMain,
      body: Column(
        children: [
          PublicHeader(
            activeId: _activeId,
            onNavTap: _scrollTo,
            onLogin: _goLogin,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  KeyedSubtree(
                    key: _keys['home'],
                    child: WebHero(
                      onRunVitals: () => _scrollTo('vitals'),
                      onSearchDoctor: () => _scrollTo('queue'),
                    ),
                  ),
                  const StatRow(),
                  KeyedSubtree(key: _keys['vitals'], child: const VitalsChecker()),
                  KeyedSubtree(
                    key: _keys['queue'],
                    child: DoctorQueueTracker(onJoinQueue: _goLogin),
                  ),
                  KeyedSubtree(
                    key: _keys['blood'],
                    child: EmergencyBloodRequest(
                      onRequest: () {
                        showDialog(
                          context: context,
                          builder: (context) => const BloodRequestDialog(),
                        );
                      },
                      onRegisterDonor: _goLogin,
                    ),
                  ),
                  const LiveDonorAvailability(),
                  const OurSolutions(),
                  const SuccessStories(),
                  KeyedSubtree(
                    key: _keys['blog'],
                    child: HealthBlogHub(onReadArticle: _goLogin),
                  ),
                  const SizedBox(height: 20),
                  const PublicFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
