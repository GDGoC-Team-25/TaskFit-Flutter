import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: SvgPicture.asset('assets/logo.svg'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '대시보드',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '선택 직무: 프론트엔드 개발자',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      '87%',
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
                    _buildSummaryStat('24', '풀이 문제'),
                    _buildSummaryStat('5.2', '평균 소요(분)'),
                    _buildSummaryStat('3', '약점 태그'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI 분석 인사이트',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            Icons.bolt,
            Colors.blue,
            'JavaScript 클로저 이해도 향상',
            '지난주 대비 관련 문제 정답률이 15% 상승했습니다.',
          ),
          _buildInsightCard(
            Icons.warning_amber,
            Colors.orange,
            'React Hook 종속성 배열',
            '세 문제 연속 오답. 추가 학습이 필요합니다.',
          ),
          const SizedBox(height: 24),
          const Text('최근 풀이 기록', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildHistoryItem('Virtual DOM 동작 방식', '정답', '2분 15초'),
          _buildHistoryItem('useEffect 클린업 함수', '오답', '4분 30초'),
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

  Widget _buildInsightCard(
    IconData icon,
    Color color,
    String title,
    String desc,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            status,
            style: TextStyle(
              color: status == '정답' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
