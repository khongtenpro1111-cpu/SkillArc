import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:skill_arc/models/challenge.dart';
import 'package:skill_arc/providers/challenge_provider.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  int? _selectedOption;
  bool _isSubmitting = false; // Thêm trạng thái loading
  Map<String, dynamic>? _latestSubmission;
  bool _isLoadingSubmission = false;

  final TextEditingController _solutionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.challenge.type == ChallengeType.coding) {
      _loadLatestSubmission();
    }
  }

  Future<void> _loadLatestSubmission() async {
    setState(() => _isLoadingSubmission = true);
    try {
      final challengeProvider = context.read<ChallengeProvider>();
      final submission = await challengeProvider.getLatestSubmission(widget.challenge.id);
      if (submission != null) {
        setState(() {
          _latestSubmission = submission;
          if (submission['solution'] != null) {
            _solutionController.text = submission['solution'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading latest submission: $e');
    } finally {
      setState(() => _isLoadingSubmission = false);
    }
  }

  @override
  void dispose() {
    _solutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isLocked = widget.challenge.status == ChallengeStatus.locked;
    final bool isDone = widget.challenge.status == ChallengeStatus.done;
    final accentColor = isDark ? const Color(0xFF00D2FF) : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(widget.challenge.title,
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : theme.colorScheme.primary,
            )),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.challenge.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.challenge.status.name.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(widget.challenge.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.challenge.reward,
                        style: TextStyle(color: isDark ? widget.challenge.color : theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.challenge.description,
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.challenge.type == ChallengeType.quiz) ...[
                    Text(
                      'Câu hỏi:',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.challenge.question ?? '',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...(widget.challenge.options ?? []).asMap().entries.map((entry) {
                      int idx = entry.key;
                      String val = entry.value;
                      bool isSelected = _selectedOption == idx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: (isLocked || isDone) ? null : () => setState(() => _selectedOption = idx),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentColor.withValues(alpha: 0.1)
                                  : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? accentColor : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  String.fromCharCode(65 + idx),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? accentColor : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(child: Text(
                                  val,
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                )),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: accentColor, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nộp bài giải (Link Github hoặc nội dung bài làm):',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _solutionController,
                          enabled: !isLocked && !isDone,
                          maxLines: 4,
                          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Nhập link repository hoặc code tại đây...',
                            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 14),
                            filled: true,
                            fillColor: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: accentColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.code_rounded, size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                              const SizedBox(height: 8),
                              Text(
                                'Hệ thống sẽ chấm điểm dựa trên mã nguồn bạn nộp.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (!isLocked && !isDone)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting 
                    ? null 
                    : () async {
                    setState(() => _isSubmitting = true); // Bắt đầu loading
                    
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final challengeProvider = context.read<ChallengeProvider>();

                    try {
                      if (widget.challenge.type == ChallengeType.quiz) {
                        if (_selectedOption == null) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Vui lòng chọn một đáp án!')),
                          );
                          setState(() => _isSubmitting = false);
                          return;
                        }
                        
                        final bool success = await challengeProvider.submitQuiz(widget.challenge.id, _selectedOption!);
                        
                        if (!context.mounted) return;
                        
                        if (success) {
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Chúc mừng! Bạn đã hoàn thành thử thách.')),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Đáp án chưa chính xác hoặc có lỗi xảy ra!')),
                          );
                        }
                      } else {
                        if (_solutionController.text.trim().isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập link bài làm hoặc nội dung giải thuật!')),
                          );
                          setState(() => _isSubmitting = false);
                          return;
                        }
                        
                        final Map<String, dynamic>? result = await challengeProvider.submitCodingChallenge(
                          widget.challenge.id,
                          solutionUrl: _solutionController.text.trim(),
                        );
                        
                        if (!context.mounted) return;

                        if (result != null) {
                          _showFeedbackBottomSheet(context, result);
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Nộp bài thất bại, vui lòng thử lại!')),
                          );
                        }
                      }
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false); // Kết thúc loading
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: isDark ? 8 : 4,
                    shadowColor: accentColor.withValues(alpha: 0.5),
                    disabledBackgroundColor: accentColor.withValues(alpha: 0.3),
                  ),
                  child: _isSubmitting 
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white),
                      )
                    : const Text('NỘP BÀI',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              )
            else if (isDone) ...[
              const Center(
                child: Text(
                  'Bạn đã hoàn thành thử thách này!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildFeedbackCard(context),
            ]
            else
              Center(
                child: Text(
                  'Thử thách này hiện đang bị khóa.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    if (_latestSubmission == null) {
      if (_isLoadingSubmission) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bool passed = _latestSubmission!['passed'] == true || _latestSubmission!['isPassed'] == true;
    final double score = (_latestSubmission!['score'] as num?)?.toDouble() ?? 0.0;
    final String? feedback = _latestSubmission!['aiFeedback'];

    if (feedback == null || feedback.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2530) : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: passed 
              ? Colors.green.withValues(alpha: 0.3) 
              : Colors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: passed ? Colors.green : Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                passed ? 'AI ĐÁNH GIÁ: ĐẠT' : 'AI ĐÁNH GIÁ: CHƯA ĐẠT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: passed ? Colors.green : Colors.redAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: passed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${score.toInt()}đ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1),
          const Text(
            'Nhận xét chi tiết:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: feedback,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, height: 1.5),
              code: const TextStyle(
                backgroundColor: Colors.black12,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
              codeblockDecoration: BoxDecoration(
                color: isDark ? Colors.black38 : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackBottomSheet(BuildContext context, Map<String, dynamic> submission) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool passed = submission['passed'] == true || submission['isPassed'] == true;
    final double score = (submission['score'] as num?)?.toDouble() ?? 0.0;
    final String feedback = submission['aiFeedback'] ?? 'Chúc mừng bạn đã hoàn thành!';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  passed ? Icons.stars_rounded : Icons.error_outline_rounded,
                  color: passed ? Colors.amber : Colors.redAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  passed ? 'KẾT QUẢ: ĐẠT' : 'KẾT QUẢ: CHƯA ĐẠT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.redAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  'Điểm: ${score.toInt()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: feedback,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, height: 1.6),
                    code: const TextStyle(
                      backgroundColor: Colors.black12,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close bottom sheet
                  Navigator.of(this.context).pop(); // Go back to challenge list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed ? Colors.green : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('XÁC NHẬN & QUAY LẠI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.done:
        return Colors.green;
      case ChallengeStatus.locked:
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }
}
