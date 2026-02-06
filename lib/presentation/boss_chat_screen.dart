import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import 'analysis_result_screen.dart';

class BossChatScreen extends StatefulWidget {
  final int threadId; // 과제 제출 후 생성된 스레드 ID

  const BossChatScreen({super.key, required this.threadId});

  @override
  State<BossChatScreen> createState() => _BossChatScreenState();
}

class _BossChatScreenState extends State<BossChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 메시지 목록 관리 (초기값은 비어있거나 서버에서 가져온 기존 대화)
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  Map<String, dynamic>? _evaluationData; // 평가 완료 시 데이터 저장

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // 기존 대화 내역 불러오기
  Future<void> _loadChatHistory() async {
    final api = context.read<TaskFitApi>();
    try {
      final response = await api.getThreadDetail(widget.threadId);
      setState(() {
        // 서버 응답 구조에 따라 메시지 리스트 매핑
        _messages = List<Map<String, dynamic>>.from(response['messages'] ?? []);
        // 이미 평가가 완료된 스레드라면 평가 데이터도 로드
        if (response['evaluation'] != null) {
          _evaluationData = response['evaluation'];
        }
      });
      _scrollToBottom();
    } catch (e) {
      print("대화 내역 로드 실패: $e");
    }
  }

  // 메시지 전송 로직
  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({"content": text, "is_me": true});
      _isTyping = true;
    });
    _scrollToBottom();

    final api = context.read<TaskFitApi>();
    try {
      // AI 팀장에게 메시지 전송
      final response = await api.sendMessage(
        widget.threadId,
        MessageCreateRequest(content: text),
      );

      setState(() {
        _isTyping = false;
        // AI 답변 추가
        _messages.add({"content": response['answer'], "is_me": false});

        // 만약 이번 답변과 함께 평가 결과가 도착했다면 저장
        if (response['evaluation'] != null) {
          _evaluationData = response['evaluation'];
        }
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
      print("메시지 전송 실패: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 16, backgroundColor: Colors.blueGrey),
            SizedBox(width: 8),
            Text('김철수 팀장 (AI)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_evaluationData != null ? 1 : 0) + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // 1. 일반 대화 메시지
                if (index < _messages.length) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg['content'], msg['is_me'] ?? false);
                }

                // 2. AI가 생각 중인 상태 표시
                if (_isTyping && index == _messages.length) {
                  return _buildChatBubble('답변을 생성 중입니다...', false);
                }

                // 3. 평가가 완료되었을 때 결과 카드 노출
                if (_evaluationData != null) {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                        child: const Text('직무 역량 분석이 완료되었습니다.', style: TextStyle(fontSize: 12)),
                      )),
                      const SizedBox(height: 24),
                      _buildResultCard(context, _evaluationData!),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
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
          border: isMe ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> data) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnalysisResultScreen(evaluationId: data['id']))
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF3B5BFF), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            const Text('직무 역량 평가 결과', style: TextStyle(color: Colors.white70)),
            Text(data['title'] ?? '평가 결과', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Text('${data['score']} / 100', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            Text(data['grade'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            // 스탯 바는 데이터의 리스트를 활용해 동적 생성 가능
            _buildStatBar('직무 적합도', (data['job_fit'] ?? 0.0) / 100),
            _buildStatBar('논리력', (data['logic'] ?? 0.0) / 100),
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
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11))),
          Expanded(child: LinearProgressIndicator(value: val, backgroundColor: Colors.white24, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: '팀장님께 답변하기...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _handleSend,
            icon: const Icon(Icons.send, color: Color(0xFF3B5BFF)),
          ),
        ],
      ),
    );
  }
}