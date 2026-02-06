import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/taskfit_api.dart';
import 'main_shell.dart';

class AnalysisResultScreen extends StatelessWidget {
  final int evaluationId;

  const AnalysisResultScreen({super.key, required this.evaluationId});

  @override
  Widget build(BuildContext context) { // async를 삭제하고 반환 타입을 Widget으로 변경
    final api = context.read<TaskFitApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 분석 결과'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
      // FutureBuilder가 비동기 데이터를 위젯으로 변환해줍니다.
      body: FutureBuilder<dynamic>(
        future: api.getEvaluationDetail(evaluationId),
        builder: (context, snapshot) {
          // 1. 데이터를 가져오는 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. 에러가 발생했을 때
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          // 3. 데이터가 성공적으로 도착했을 때
          final data = snapshot.data;
          if (data == null) return const Center(child: Text('데이터가 없습니다.'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['task_title'] ?? '과제 제목',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${data['company_name']} · ${data['job_role_name']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // 점수 및 난이도 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${data['score']}점',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5BFF),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '난이도: ${data['difficulty'] ?? '중'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text('AI 분석 요약', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(data['summary'] ?? '요약 내용이 없습니다.'),
                ),
                const SizedBox(height: 32),

                const Text('상세 분석 결과', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 상세 분석 항목 리스트 (서버 응답 데이터 기반)
                ...((data['details'] as List?)?.map((item) => _buildAnalysisItem(
                  item['type'] == 'POSITIVE' ? Icons.check_circle : Icons.lightbulb,
                  item['type'] == 'POSITIVE' ? Colors.green : Colors.orange,
                  item['content'] ?? '',
                )) ?? []),

                const SizedBox(height: 40),

                // 버튼들
                _buildActionButton('유사 문제 다시 풀기', () {}),
                const SizedBox(height: 12),
                _buildActionButton('채팅 이어가기', () => Navigator.pop(context)),
                const SizedBox(height: 12),
                _buildActionButton('채팅 목록으로 가기', () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
                        (route) => false,
                  );
                }),
              ],
            ),
          );
        },
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

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B5BFF),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}