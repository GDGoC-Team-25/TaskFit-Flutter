import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/api_models.dart';
import '../data/taskfit_api.dart';
import 'analysis_result_screen.dart';

class BossChatScreen extends StatefulWidget {
  final int threadId;

  const BossChatScreen({super.key, required this.threadId});

  @override
  State<BossChatScreen> createState() => _BossChatScreenState();
}

class _BossChatScreenState extends State<BossChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 백엔드 MessageResponse: { id, role("ai"/"user"), content, message_order, created_at }
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  Map<String, dynamic>? _evaluationData;

  // 스레드 메타 정보 (페르소나)
  String _personaName = 'AI 팀장';
  String _personaDepartment = '';
  String _topicTag = '';
  int _totalQuestions = 0;
  int _askedCount = 0;
  String _threadStatus = 'questioning';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // 기존 대화 내역 불러오기
  // 백엔드 ThreadDetailResponse:
  // { id, persona_name, persona_department, topic_tag, status,
  //   total_questions, asked_count,
  //   submission: { id, task_id, task_title },
  //   evaluation: { id, total_score, score_label } | null,
  //   messages: [ { id, role, content, message_order, created_at }, ... ] }
  Future<void> _loadChatHistory() async {
    final api = context.read<TaskFitApi>();
    try {
      final response = await api.getThreadDetail(widget.threadId);
      setState(() {
        _personaName = response['persona_name'] ?? 'AI 팀장';
        _personaDepartment = response['persona_department'] ?? '';
        _topicTag = response['topic_tag'] ?? '';
        _totalQuestions = response['total_questions'] ?? 0;
        _askedCount = response['asked_count'] ?? 0;
        _threadStatus = response['status'] ?? 'questioning';

        final rawMessages = response['messages'] as List? ?? [];
        _messages = rawMessages.map<Map<String, dynamic>>((m) => {
          'content': m['content'] ?? '',
          'role': m['role'] ?? 'ai',
        }).toList();

        if (response['evaluation'] != null) {
          _evaluationData = Map<String, dynamic>.from(response['evaluation']);
        }
      });
      _scrollToBottom();
    } catch (e) {
      print("대화 내역 로드 실패: $e");
    }
  }

  // 메시지 전송 로직
  // 백엔드 ChatResponse:
  // { user_message: MessageResponse, ai_message: MessageResponse | null,
  //   thread: { status, asked_count, total_questions },
  //   evaluation: { id, total_score, score_label, scores_detail, ai_summary, analysis_points } | null }
  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _threadStatus == 'completed') return;

    _messageController.clear();
    setState(() {
      _messages.add({"content": text, "role": "user"});
      _isTyping = true;
    });
    _scrollToBottom();

    final api = context.read<TaskFitApi>();
    try {
      final response = await api.sendMessage(
        widget.threadId,
        MessageCreateRequest(content: text),
      );

      setState(() {
        _isTyping = false;

        // AI 후속 질문 메시지 추가
        if (response['ai_message'] != null) {
          _messages.add({
            "content": response['ai_message']['content'] ?? '',
            "role": "ai",
          });
        }

        // 스레드 상태 업데이트
        final threadStatus = response['thread'];
        if (threadStatus != null) {
          _threadStatus = threadStatus['status'] ?? _threadStatus;
          _askedCount = threadStatus['asked_count'] ?? _askedCount;
          _totalQuestions = threadStatus['total_questions'] ?? _totalQuestions;
        }

        // 평가 결과 도착 시
        if (response['evaluation'] != null) {
          _evaluationData = Map<String, dynamic>.from(response['evaluation']);
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
    final bool isCompleted = _threadStatus == 'completed';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Colors.blueGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_personaName (AI)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_personaDepartment.isNotEmpty)
                    Text(_personaDepartment, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_totalQuestions > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '$_askedCount / $_totalQuestions',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ),
        ],
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
                  final isMe = msg['role'] == 'user';
                  return _buildChatBubble(msg['content'] ?? '', isMe);
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
          _buildChatInput(isCompleted),
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

  // 백엔드 EvaluationInline: { id, total_score, score_label, scores_detail, ai_summary, analysis_points }
  Widget _buildResultCard(BuildContext context, Map<String, dynamic> data) {
    final totalScore = data['total_score'] ?? 0;
    final scoreLabel = data['score_label'] ?? '';
    final scoresDetail = data['scores_detail'] as List? ?? [];

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
            Text(scoreLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Text('$totalScore / 100', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // scores_detail: [{"name": "시장 분석력", "score": 88}, ...]
            ...scoresDetail.take(3).map((s) =>
                _buildStatBar(s['name'] ?? '', (s['score'] ?? 0) / 100)),
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
          Expanded(child: LinearProgressIndicator(value: val.clamp(0.0, 1.0), backgroundColor: Colors.white24, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildChatInput(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isCompleted,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: isCompleted ? '대화가 종료되었습니다.' : '팀장님께 답변하기...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: isCompleted ? null : _handleSend,
            icon: Icon(Icons.send, color: isCompleted ? Colors.grey : const Color(0xFF3B5BFF)),
          ),
        ],
      ),
    );
  }
}
