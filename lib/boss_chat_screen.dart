import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'analysis_result_screen.dart';

class BossChatScreen extends StatelessWidget {
  const BossChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 16),
            SizedBox(width: 8),
            Text('김철수 팀장 (AI)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChatBubble('안녕하세요. 네이버의 "전략기획" 직무를 선택하셨군요. 첫 번째 질문입니다: 네이버의 핵심 수익원인 검색광고 시장에서, 경쟁사 구글과의 차별화 전략은 무엇이라고 생각하시나요?', false),
                _buildChatBubble('네이버는 국내 검색어 데이터와 생활밀착형 서비스(카페, 블로그, 쇼핑)를 통합한 로컬 검색 경험에서 강점을 가집니다...', true),
                const SizedBox(height: 24),
                Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                  child: const Text('답변을 분석하고 최종 점수를 계산 중입니다.', style: TextStyle(fontSize: 12)),
                )),
                const SizedBox(height: 24),
                _buildResultCard(context),
              ],
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE8F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisResultScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF3B5BFF), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            const Text('직무 역량 평가 결과', style: TextStyle(color: Colors.white70)),
            const Text('네이버 전략기획 모의고사 #5', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            const Text('92 / 100', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Outstanding', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            _buildStatBar('시장 분석력', 0.9),
            _buildStatBar('전략 수립력', 0.8),
            const Divider(color: Colors.white24),
            const Text('상세 분석 결과 보기 >', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))),
          Expanded(child: LinearProgressIndicator(value: val, backgroundColor: Colors.white24, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.add),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '팀장님께 답변하기...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.send, color: Color(0xFF3B5BFF)),
        ],
      ),
    );
  }
}
