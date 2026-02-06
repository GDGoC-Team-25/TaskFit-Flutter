import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../data/taskfit_api.dart';
import 'boss_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Future<dynamic>? _threadsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThreads();
    });
  }

  void _loadThreads() {
    final api = context.read<TaskFitApi>();
    setState(() {
      // 백엔드 ThreadListResponse:
      // { items: [ThreadListItem], total, page, page_size }
      _threadsFuture = api.getThreads(page: 1);
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
          '직무대화',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadThreads();
        },
        child: FutureBuilder<dynamic>(
          future: _threadsFuture,
          builder: (context, snapshot) {
            if (_threadsFuture == null || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('목록을 불러오는데 실패했습니다.'));
            }

            final data = snapshot.data;
            final items = data?['items'] as List? ?? [];

            if (items.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                // 백엔드 ThreadListItem:
                // { id, persona_name, persona_department, topic_tag, status,
                //   total_questions, asked_count, message_count,
                //   last_message_preview, company_name, job_role_name,
                //   created_at, updated_at }
                final thread = items[index];
                return _buildChatListItem(context, thread);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('아직 진행 중인 대화가 없습니다.', style: TextStyle(color: Colors.grey)),
          const Text('과제를 제출하고 팀장님과 대화를 시작해보세요!', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, dynamic thread) {
    final int threadId = thread['id'];
    final String personaName = thread['persona_name'] ?? '팀장';
    final String topicTag = thread['topic_tag'] ?? '';
    final String companyName = thread['company_name'] ?? '';
    final String jobRoleName = thread['job_role_name'] ?? '';
    final String lastMessage = thread['last_message_preview'] ?? '메시지가 없습니다.';
    final String updatedAt = (thread['updated_at'] ?? '').toString();
    final int messageCount = thread['message_count'] ?? 0;
    final String status = thread['status'] ?? 'questioning';
    final int askedCount = thread['asked_count'] ?? 0;
    final int totalQuestions = thread['total_questions'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BossChatScreen(threadId: threadId)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE8F0FF),
                    child: Icon(Icons.person, size: 16, color: Color(0xFF3B5BFF)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$personaName (AI)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (topicTag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        topicTag,
                        style: TextStyle(color: Colors.purple.shade400, fontSize: 10),
                      ),
                    ),
                  const Spacer(),
                  if (updatedAt.isNotEmpty)
                    Text(
                      updatedAt.split('T')[0],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              if (companyName.isNotEmpty || jobRoleName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '$companyName · $jobRoleName',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                lastMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '대화 $messageCount건',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'completed' ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status == 'completed' ? '완료 ($askedCount/$totalQuestions)' : '진행중 ($askedCount/$totalQuestions)',
                          style: TextStyle(
                            fontSize: 10,
                            color: status == 'completed' ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '대화 보기 >',
                    style: TextStyle(
                      color: Color(0xFF3B5BFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
