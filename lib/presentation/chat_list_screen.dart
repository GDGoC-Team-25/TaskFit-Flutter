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
  late Future<Map<String, dynamic>> _threadsFuture;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  // 데이터 새로고침을 위한 로드 함수
  void _loadThreads() {
    final api = context.read<TaskFitApi>();
    setState(() async {
      _threadsFuture = await api.getThreads(page: 1);
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
          '채팅 목록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      // Pull to Refresh 기능 추가
      body: RefreshIndicator(
        onRefresh: () async {
          _loadThreads();
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _threadsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('목록을 불러오는데 실패했습니다.'));
            }

            final items = snapshot.data?['items'] as List? ?? [];

            if (items.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final thread = items[index];
                return _buildChatListItem(
                  context,
                  thread['id'],
                  thread['title'] ?? '새로운 대화',
                  thread['job_role_name'] ?? '직무 미지정',
                  thread['last_message'] ?? '최근 메시지가 없습니다.',
                  thread['updated_at'] ?? '',
                  thread['message_count'] ?? 0,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // 채팅 내역이 없을 때 표시할 화면
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

  Widget _buildChatListItem(
      BuildContext context,
      int threadId,
      String name,
      String tag,
      String msg,
      String date,
      int count,
      ) {
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
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(color: Colors.purple.shade400, fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    // 날짜 데이터가 있다면 포맷팅 필요 (여기선 간단히 표시)
                    date.split('T')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                msg,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '대화 $count건',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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