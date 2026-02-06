import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskfit/presentation/problem_solving_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. leadingWidth를 로고 사이즈에 적절하게 맞춥니다.
        leadingWidth: 100,
        leading: SvgPicture.asset('assets/logo.svg'),
        // 2. leading과 title 사이의 간격을 0으로 만듭니다.
        centerTitle: true,
        title: const Text(
          'TASK FIT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              avatar: const Icon(Icons.business, size: 16),
              label: const Text('삼성전자 > 소프트웨어 엔지니어'),
              backgroundColor: const Color(0xFFE8F0FF),
              side: BorderSide.none,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '생성된 문제 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('새로 생성'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildProblemCard(
                    context,
                    '자료구조',
                    '중',
                    '트리 순회 알고리즘에 대해 설명하고, 전위/중위/후위 순회의 차이점을 서술하시오.',
                  ),
                  _buildProblemCard(
                    context,
                    '시스템 설계',
                    '상',
                    '초당 10만 요청을 처리하는 URL 단축 서비스를 설계하시오.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemCard(
    BuildContext context,
    String tag,
    String level,
    String title,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '난이도: $level',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
                const Spacer(),
                const Text(
                  '2025.03',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  '25분 예상',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  '서술형',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProblemSolvingScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('풀러가기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
