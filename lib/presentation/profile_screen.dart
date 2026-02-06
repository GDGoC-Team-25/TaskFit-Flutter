// --- 9. 프로필 스크린 ---
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('프로필', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 사용자 상단 정보 섹션
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFFE8F0FF),
                    child: Icon(Icons.person, size: 50, color: Color(0xFF3B5BFF)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '태스크핏 님',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '신입 앱 개발자 지망생',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
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

            // 학습 현황 요약 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStatItem(label: '해결한 문제', value: '128'),
                    VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F1F1)),
                    _ProfileStatItem(label: '평균 점수', value: '84점'),
                    VerticalDivider(thickness: 1, width: 1, color: Color(0xFFF1F1F1)),
                    _ProfileStatItem(label: '내 순위', style: TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold), value: '상위 15%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 메뉴 리스트 섹션
            _buildMenuSection('나의 학습 기록', [
              _MenuTile(icon: Icons.bookmark_border, title: '저장한 문제 목록', count: '12'),
              _MenuTile(icon: Icons.history, title: '최근 응시 기록'),
              _MenuTile(icon: Icons.note_add_outlined, title: '오답 노트'),
            ]),
            const SizedBox(height: 12),
            _buildMenuSection('계정 설정', [
              _MenuTile(icon: Icons.notifications_none, title: '알림 설정'),
              _MenuTile(icon: Icons.lock_outline, title: '보안 및 인증'),
              _MenuTile(icon: Icons.help_outline, title: '고객센터 / 도움말'),
            ]),

            // 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: TextButton(
                onPressed: () {},
                child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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

// 프로필 상단 스탯 아이템 위젯
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

// 메뉴 리스트 타일 위젯
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? count;

  const _MenuTile({required this.icon, required this.title, this.count});

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
      onTap: () {},
    );
  }
}