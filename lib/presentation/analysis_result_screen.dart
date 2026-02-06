import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/taskfit_api.dart';
import 'main_shell.dart';

class AnalysisResultScreen extends StatelessWidget {
  final int evaluationId;

  const AnalysisResultScreen({super.key, required this.evaluationId});

  @override
  Widget build(BuildContext context) {
    final api = context.read<TaskFitApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 분석 결과'),
      ),
      // 백엔드 EvaluationDetailResponse:
      // { id, total_score, score_label, scores_detail: [{name, score}],
      //   ai_summary, analysis_points: {strengths: [...], weaknesses: [...]},
      //   feedback,
      //   submission: { id, content, time_spent_seconds,
      //     task: { id, title, category, difficulty,
      //       company: {id, name}, job_role: {id, name} } },
      //   thread: { id, persona_name },
      //   created_at }
      body: FutureBuilder<dynamic>(
        future: api.getEvaluationDetail(evaluationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null) return const Center(child: Text('데이터가 없습니다.'));

          // 중첩 구조에서 필드 추출
          final submission = data['submission'] ?? {};
          final task = submission['task'] ?? {};
          final company = task['company'] ?? {};
          final jobRole = task['job_role'] ?? {};
          final analysisPoints = data['analysis_points'] ?? {};
          final strengths = analysisPoints['strengths'] as List? ?? [];
          final weaknesses = analysisPoints['weaknesses'] as List? ?? [];
          final scoresDetail = data['scores_detail'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? '과제 제목',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${company['name'] ?? ''} · ${jobRole['name'] ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // 점수 및 난이도 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${data['total_score'] ?? 0}점',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5BFF),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['score_label'] ?? '',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '난이도: ${task['difficulty'] ?? '중'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 세부 점수 바
                if (scoresDetail.isNotEmpty) ...[
                  const Text('세부 평가', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...scoresDetail.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 100, child: Text(s['name'] ?? '', style: const TextStyle(fontSize: 13))),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: ((s['score'] ?? 0) / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF3B5BFF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${s['score'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],

                // AI 분석 요약
                const Text('AI 분석 요약', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(data['ai_summary'] ?? '요약 내용이 없습니다.'),
                ),
                const SizedBox(height: 32),

                // 강점
                if (strengths.isNotEmpty) ...[
                  const Text('강점', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...strengths.map((item) => _buildAnalysisItem(
                    Icons.check_circle, Colors.green, item.toString(),
                  )),
                  const SizedBox(height: 24),
                ],

                // 약점
                if (weaknesses.isNotEmpty) ...[
                  const Text('개선점', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...weaknesses.map((item) => _buildAnalysisItem(
                    Icons.lightbulb, Colors.orange, item.toString(),
                  )),
                  const SizedBox(height: 24),
                ],

                // 종합 피드백
                if (data['feedback'] != null && data['feedback'].toString().isNotEmpty) ...[
                  const Text('종합 피드백', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(data['feedback']),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 16),

                // 버튼들
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
