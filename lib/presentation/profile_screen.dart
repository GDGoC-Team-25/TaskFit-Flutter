import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import '../serivce/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 프로필과 대시보드 요약을 동시에 불러옵니다.
  void _loadProfileData() {
    final api = context.read<TaskFitApi>();
    setState(() {
      _profileDataFuture = Future.wait([
        api.getProfile(),
        api.getDashboardSummary(),
      ]).then((results) {
        // 두 API 결과를 하나로 합칩니다.
        return {
          ...results[0],
          ...results[1],
        };
      });
    });
  }

  // 로그아웃 처리
  Future<void> _handleLogout() async {
    final authService = AuthService();
    await authService.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('프로필', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadProfileData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('프로필 정보를 불러오지 못했습니다.'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. 사용자 상단 정보 섹션 (API 데이터 반영)
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFE8F0FF),
                        backgroundImage: data['profile_image'] != null
                            ? NetworkImage(data['profile_image'])
                            : null,
                        child: data['profile_image'] == null
                            ? const Icon(Icons.person, size: 50, color: Color(0xFF3B5BFF))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data['name'] ?? '사용자',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['bio'] ?? '목표를 설정하고 실무를 경험해보세요!',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: 프로필 수정 다이얼로그나 페이지 연결 (PATCH /profile)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F4FF),
                          foregroundColor: const Color(0xFF3B5BFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          minimumSize: const Size(120, 36),
                        ),
                        child: const Text('프로필 수정', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. 학습 현황 요약 카드 (Dashboard API 데이터 반영)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProfileStatItem(label: '해결한 문제', value: '${data['solved_count'] ?? 0}'),
                        const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F1F1)),
                        _ProfileStatItem(label: '평균 점수', value: '${data['avg_score'] ?? 0}점'),
                        const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F1F1)),
                        _ProfileStatItem(
                          label: '내 순위',
                          style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold),
                          value: '상위 ${data['rank_percent'] ?? '-'}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. 메뉴 리스트 섹션
                _buildMenuSection('나의 학습 기록', [
                  _MenuTile(icon: Icons.bookmark_border, title: '저장한 문제 목록', count: '${data['bookmark_count'] ?? 0}'),
                  _MenuTile(icon: Icons.history, title: '최근 응시 기록', onTap: () {}),
                  _MenuTile(icon: Icons.note_add_outlined, title: '오답 노트', onTap: () {}),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection('계정 설정', [
                  _MenuTile(icon: Icons.notifications_none, title: '알림 설정', onTap: () {}),
                  _MenuTile(icon: Icons.lock_outline, title: '보안 및 인증', onTap: () {}),
                  _MenuTile(icon: Icons.help_outline, title: '고객센터 / 도움말', onTap: () {}),
                ]),

                // 4. 로그아웃 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: TextButton(
                    onPressed: _handleLogout,
                    child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(String sectionTitle, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            sectionTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? style;

  const _ProfileStatItem({required this.label, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? count;
  final VoidCallback? onTap;

  const _MenuTile({required this.icon, required this.title, this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count != null)
            Text(count!, style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}