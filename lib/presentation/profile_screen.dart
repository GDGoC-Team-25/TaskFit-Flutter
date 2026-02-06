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
  Future<Map<String, dynamic>>? _profileDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  // 백엔드 ProfileResponse:
  // { user: { id, email, name, bio, profile_image },
  //   stats: { total_solved, avg_score, rank_percentile },
  //   recent_submissions: [{ id, task_title, total_score, created_at }] }
  void _loadProfileData() {
    final api = context.read<TaskFitApi>();
    setState(() {
      _profileDataFuture = api.getProfile().then((profileData) {
        // profileData는 이미 언래핑된 ProfileResponse
        return Map<String, dynamic>.from(profileData ?? {});
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
          if (_profileDataFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('프로필 정보를 불러오지 못했습니다.'));
          }

          final data = snapshot.data ?? {};
          final user = data['user'] ?? {};
          final stats = data['stats'] ?? {};
          final recentSubmissions = data['recent_submissions'] as List? ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. 사용자 상단 정보 섹션
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFE8F0FF),
                        backgroundImage: user['profile_image'] != null
                            ? NetworkImage(user['profile_image'])
                            : null,
                        child: user['profile_image'] == null
                            ? const Icon(Icons.person, size: 50, color: Color(0xFF3B5BFF))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user['name'] ?? '사용자',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['bio'] ?? '목표를 설정하고 실무를 경험해보세요!',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showEditProfileDialog(context, user);
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

                // 2. 학습 현황 요약 카드
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
                        _ProfileStatItem(label: '해결한 문제', value: '${stats['total_solved'] ?? 0}'),
                        const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F1F1)),
                        _ProfileStatItem(label: '평균 점수', value: '${(stats['avg_score'] ?? 0).toStringAsFixed(0)}점'),
                        const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F1F1)),
                        _ProfileStatItem(
                          label: '내 순위',
                          style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold),
                          value: stats['rank_percentile'] != null
                              ? '상위 ${stats['rank_percentile'].toStringAsFixed(0)}%'
                              : '-',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. 최근 제출 기록
                if (recentSubmissions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('최근 풀이 기록', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  ...recentSubmissions.map((sub) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(sub['task_title'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Text('${sub['total_score'] ?? '-'}점', style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
                ],

                const SizedBox(height: 12),

                // 4. 메뉴 리스트 섹션
                _buildMenuSection('계정 설정', [
                  _MenuTile(icon: Icons.notifications_none, title: '알림 설정', onTap: () {}),
                  _MenuTile(icon: Icons.help_outline, title: '고객센터 / 도움말', onTap: () {}),
                ]),

                // 5. 로그아웃 버튼
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

  void _showEditProfileDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name'] ?? '');
    final bioController = TextEditingController(text: user['bio'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('프로필 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: '자기소개'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final api = context.read<TaskFitApi>();
              try {
                await api.updateProfile(ProfileUpdateRequest(
                  name: nameController.text.isNotEmpty ? nameController.text : null,
                  bio: bioController.text.isNotEmpty ? bioController.text : null,
                ));
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadProfileData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필 수정에 실패했습니다.')),
                  );
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
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
