import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../data/taskfit_api.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<dynamic>? _summaryFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final api = context.read<TaskFitApi>();
    setState(() {
      // 백엔드 DashboardSummaryResponse:
      // { weekly_summary: { score_percentage, problems_solved, avg_time_minutes, weak_tag_count },
      //   ai_insight: { improvements, weak_areas },
      //   recent_submissions: [{ id, task_title, category, total_score, is_correct, time_spent_seconds, created_at }],
      //   competencies: [{ company_name, job_role_name, avg_score, attempt_count, weak_tags }] }
      _summaryFuture = api.getDashboardSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SvgPicture.asset('assets/logo.svg', fit: BoxFit.contain),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '대시보드',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<dynamic>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (_summaryFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          }

          final data = snapshot.data ?? {};
          final weeklySummary = data['weekly_summary'] ?? {};
          final aiInsight = data['ai_insight'] ?? {};
          final recentSubmissions = data['recent_submissions'] as List? ?? [];
          final competencies = data['competencies'] as List? ?? [];

          return RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. 학습 요약 카드
                _buildSummaryCard(weeklySummary),

                const SizedBox(height: 24),
                const Text(
                  'AI 분석 인사이트',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 2. AI 인사이트
                if (aiInsight['improvements'] == null && aiInsight['weak_areas'] == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('충분한 데이터가 쌓이면 AI 인사이트가 제공됩니다.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  )
                else ...[
                  if (aiInsight['improvements'] != null)
                    _buildInsightCard(Icons.bolt, Colors.blue, '개선 방향', aiInsight['improvements']),
                  if (aiInsight['weak_areas'] != null)
                    _buildInsightCard(Icons.warning_amber, Colors.orange, '약점 분야', aiInsight['weak_areas']),
                ],

                // 3. 역량 요약
                if (competencies.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('역량 현황', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...competencies.map((c) => _buildCompetencyCard(c)),
                ],

                const SizedBox(height: 24),
                const Text('최근 풀이 기록', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 4. 최근 풀이 기록
                if (recentSubmissions.isEmpty)
                  const Center(child: Text('최근 풀이한 문제가 없습니다.', style: TextStyle(color: Colors.grey)))
                else
                  ...recentSubmissions.map((item) => _buildHistoryItem(item)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이번 주 학습 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${(summary['score_percentage'] ?? 0).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat('${summary['problems_solved'] ?? 0}', '풀이 문제'),
              _buildSummaryStat('${(summary['avg_time_minutes'] ?? 0).toStringAsFixed(0)}', '평균 소요(분)'),
              _buildSummaryStat('${summary['weak_tag_count'] ?? 0}', '약점 태그'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInsightCard(IconData icon, Color color, String title, String desc) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildCompetencyCard(dynamic competency) {
    final weakTags = competency['weak_tags'] as List? ?? [];
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${competency['company_name']} · ${competency['job_role_name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${(competency['avg_score'] ?? 0).toStringAsFixed(0)}점',
                  style: const TextStyle(color: Color(0xFF3B5BFF), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '시도 ${competency['attempt_count'] ?? 0}회',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (weakTags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: weakTags.map<Widget>((tag) => Chip(
                  label: Text(tag.toString(), style: const TextStyle(fontSize: 10)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide.none,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 백엔드 RecentSubmission: { id, task_title, category, total_score, is_correct, time_spent_seconds, created_at }
  Widget _buildHistoryItem(dynamic item) {
    final title = item['task_title'] ?? '';
    final totalScore = item['total_score'];
    final timeSpent = item['time_spent_seconds'];
    final String timeText = timeSpent != null ? '${(timeSpent / 60).toStringAsFixed(0)}분' : '-';
    final String scoreText = totalScore != null ? '$totalScore점' : '채점 전';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Text(
            scoreText,
            style: TextStyle(
              color: totalScore != null ? const Color(0xFF3B5BFF) : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(timeText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
