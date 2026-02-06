import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskfit/presentation/chat_list_screen.dart';
import 'package:taskfit/presentation/main_shell.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 분석 결과'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '네트워크 계층 모델 문제',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'OSI 7계층과 TCP/IP 모델 비교',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '78점',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B5BFF),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '난이도: 중급 | 소요시간: 12분',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'AI 분석 요약',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '전체적으로 개념 이해는 좋으나 응용 문제에서 약점이 보입니다. TCP/IP 모델의 실제 구현 사례 관련 문제에서 오답률이 높았습니다.',
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '상세 분석 결과',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAnalysisItem(
              Icons.check_circle,
              Colors.green,
              'OSI 7계층 각 계층의 기본 기능을 정확히 이해하고 있음',
            ),
            _buildAnalysisItem(
              Icons.lightbulb,
              Colors.orange,
              '실제 네트워크 장비에서의 계층별 동작 이해 부족',
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('유사 문제 다시 풀기'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('채팅 이어가기'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1,)),
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('채팅 목록으로 가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
