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
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final api = context.read<TaskFitApi>();
    setState(() async {
      _summaryFuture = await api.getDashboardSummary();
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
            onPressed: _loadDashboardData, // 새로고침 기능
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          }

          final data = snapshot.data ?? {};
          // 서버에서 내려오는 필드명에 맞춰 매핑 (예시 필드명 기준)
          final insights = data['insights'] as List? ?? [];
          final history = data['recent_history'] as List? ?? [];

          return RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. 학습 요약 카드
                _buildSummaryCard(data),

                const SizedBox(height: 24),
                const Text(
                  'AI 분석 인사이트',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 2. 인사이트 리스트 (동적 생성)
                if (insights.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('충분한 데이터가 쌓이면 AI 인사이트가 제공됩니다.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...insights.map((item) => _buildInsightCard(
                    item['type'] == 'improvement' ? Icons.bolt : Icons.warning_amber,
                    item['type'] == 'improvement' ? Colors.blue : Colors.orange,
                    item['title'] ?? '',
                    item['description'] ?? '',
                  )),

                const SizedBox(height: 24),
                const Text('최근 풀이 기록', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 3. 최근 풀이 기록 (동적 생성)
                if (history.isEmpty)
                  const Center(child: Text('최근 풀이한 문제가 없습니다.'))
                else
                  ...history.map((item) => _buildHistoryItem(
                    item['task_title'] ?? '',
                    item['is_correct'] == true ? '정답' : '오답',
                    item['time_spent'] ?? '0분',
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> data) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '이번 주 학습 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '목표 직무: ${data['target_job'] ?? '설정 전'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '${data['achievement_rate'] ?? 0}%',
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
              _buildSummaryStat('${data['solved_count'] ?? 0}', '풀이 문제'),
              _buildSummaryStat('${data['avg_time'] ?? 0}', '평균 소요(분)'),
              _buildSummaryStat('${data['weak_tag_count'] ?? 0}', '약점 태그'),
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

  Widget _buildHistoryItem(String title, String status, String time) {
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
            status,
            style: TextStyle(
              color: status == '정답' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}