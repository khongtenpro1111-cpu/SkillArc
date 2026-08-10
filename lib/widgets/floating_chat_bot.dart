import 'dart:ui';
import 'dart:async' as async_timer;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:skill_arc/core/constants/design_tokens.dart';
import 'package:skill_arc/core/constants/app_strings.dart';
import 'package:skill_arc/core/constants/app_constants.dart';
import 'package:skill_arc/providers/language_provider.dart';
import 'package:skill_arc/services/chat_service.dart';

class FloatingChatBot extends StatefulWidget {
  final Widget child;
  const FloatingChatBot({super.key, required this.child});

  @override
  State<FloatingChatBot> createState() => _FloatingChatBotState();
}

class _FloatingChatBotState extends State<FloatingChatBot> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isBlinking = false;
  async_timer.Timer? _blinkTimer;

  // Chat bubble position
  static double _x = -1.0;
  static double _y = -1.0;

  bool _isChatOpen = false;
  double _dragOffset = 0.0;
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Add default greeting
    _messages.add({
      'isBot': true,
      'text': '', // Will be updated dynamically in build
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.shakeDurationMs),
    )..repeat(reverse: true);

    _shakeAnimation = Tween<double>(
      begin: AppConstants.shakeAngleStart,
      end: AppConstants.shakeAngleEnd,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _blinkTimer = async_timer.Timer.periodic(const Duration(seconds: AppConstants.blinkIntervalSeconds), (timer) {
      if (mounted) {
        setState(() {
          _isBlinking = true;
        });
        Future.delayed(const Duration(milliseconds: AppConstants.blinkDurationMs), () {
          if (mounted) {
            setState(() {
              _isBlinking = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _blinkTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_x == -1.0 && _y == -1.0) {
      final size = MediaQuery.of(context).size;
      // Position bottom right above the floating nav bar
      _x = size.width - AppConstants.initialXOffset;
      _y = size.height - AppConstants.initialYOffset;
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messageController.clear();

    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await _chatService.sendMessage(text);

    setState(() {
      _messages.add({'isBot': true, 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: AppConstants.scrollDurationMs),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic localization updates
    // ignore: unused_local_variable
    final currentLocale = context.watch<LanguageProvider>().currentLocale;
    if (_messages.isNotEmpty && _messages[0]['isBot'] == true) {
      final textVal = _messages[0]['text'];
      if (textVal == '' || 
          textVal == AppStrings.get('botGreeting', 'vi') || 
          textVal == AppStrings.get('botGreeting', 'en')) {
        _messages[0]['text'] = AppStrings.of(context, 'botGreeting');
      }
    }

    final quickPrompts = [
      AppStrings.of(context, 'quickPrompt1'),
      AppStrings.of(context, 'quickPrompt2'),
      AppStrings.of(context, 'quickPrompt3'),
    ];

    return PopScope(
      canPop: !_isChatOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isChatOpen) {
          setState(() {
            _isChatOpen = false;
          });
        }
      },
      child: Stack(
        children: [
          // Main Screen Child
          widget.child,

          // Full Screen Chat Overlay Card
          if (_isChatOpen)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final topSafetyMargin = MediaQuery.of(context).padding.top + 12;
                    final availableHeight = constraints.maxHeight - topSafetyMargin;
                    final targetHeight = availableHeight;
                    return Stack(
                    children: [
                      // Blur background
                      GestureDetector(
                        onTap: () => setState(() => _isChatOpen = false),
                        child: Container(
                          color: AppDesignTokens.chatBarrier.withValues(alpha: 0.5),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: AppConstants.blurSigmaX,
                              sigmaY: AppConstants.blurSigmaY,
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                      
                      // Chat Box panel sliding from bottom / centered
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(0, _dragOffset > 0 ? _dragOffset : 0.0),
                          child: Material(
                            color: Colors.transparent,
                            child: AnimatedContainer(
                              duration: (_dragOffset != 0.0 || MediaQuery.of(context).viewInsets.bottom > 0)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 150),
                              height: _dragOffset < 0
                                  ? (targetHeight - _dragOffset).clamp(targetHeight, availableHeight)
                                  : targetHeight,
                              width: size.width,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppDesignTokens.chatBgDark.withValues(alpha: 0.9)
                                    : AppDesignTokens.chatBgLight.withValues(alpha: 0.9),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                                border: Border.all(
                                  color: isDark
                                      ? AppDesignTokens.chatBorderDark
                                      : AppDesignTokens.chatBorderLight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppDesignTokens.chatShadow.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                behavior: HitTestBehavior.translucent,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onVerticalDragStart: (details) {},
                                      onVerticalDragUpdate: (details) {
                                        setState(() {
                                          _dragOffset += details.delta.dy;
                                          final maxNegativeOffset = -(availableHeight - targetHeight);
                                          if (_dragOffset < maxNegativeOffset) {
                                            _dragOffset = maxNegativeOffset;
                                          }
                                        });
                                      },
                                      onVerticalDragEnd: (details) {
                                        if (_dragOffset > AppConstants.dragCloseThreshold ||
                                            (details.primaryVelocity ?? 0) > AppConstants.dragCloseVelocityThreshold) {
                                          setState(() {
                                            _isChatOpen = false;
                                            _dragOffset = 0.0;
                                          });
                                        } else if (_dragOffset > 0) {
                                          setState(() {
                                            _dragOffset = 0.0;
                                          });
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          // Drag Indicator / Header
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Container(
                                              width: 40,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: isDark ? Colors.white24 : Colors.black26,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),

                                          // Header Panel
                                          Padding(
                                            padding: AppDesignTokens.paddingHeader,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: AppDesignTokens.avatarBorder,
                                                          width: 1.5,
                                                        ),
                                                        image: const DecorationImage(
                                                          image: AssetImage('assets/bot_avatar.png'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          AppStrings.of(context, 'botTitle'),
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                        Text(
                                                          AppStrings.of(context, 'botStatus'),
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppDesignTokens.onlineIndicator,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close_rounded),
                                                  onPressed: () => setState(() => _isChatOpen = false),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),

                                    // Message List
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: AppDesignTokens.paddingMsgList,
                                        itemCount: _messages.length,
                                        itemBuilder: (context, index) {
                                          final msg = _messages[index];
                                          final isBot = msg['isBot'] as bool;
                                          return Align(
                                            alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(vertical: 6),
                                              padding: AppDesignTokens.paddingBubble,
                                              constraints: BoxConstraints(maxWidth: size.width * 0.75),
                                              decoration: BoxDecoration(
                                                color: isBot
                                                    ? (isDark ? AppDesignTokens.msgBotBgDark : AppDesignTokens.msgBotBgLight)
                                                    : Theme.of(context).colorScheme.primary,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(16),
                                                  topRight: const Radius.circular(16),
                                                  bottomLeft: Radius.circular(isBot ? 4 : 16),
                                                  bottomRight: Radius.circular(isBot ? 16 : 4),
                                                ),
                                                border: isBot
                                                    ? Border.all(
                                                        color: isDark
                                                            ? Colors.white.withValues(alpha: 0.05)
                                                            : Colors.transparent,
                                                      )
                                                    : null,
                                              ),
                                              child: MarkdownBody(
                                                data: msg['text'] as String,
                                                styleSheet: MarkdownStyleSheet(
                                                  p: TextStyle(
                                                    color: isBot
                                                        ? (isDark ? Colors.white70 : AppDesignTokens.msgTextBotLight)
                                                        : AppDesignTokens.msgTextUser,
                                                    fontSize: 14,
                                                    height: 1.4,
                                                  ),
                                                  strong: TextStyle(
                                                    color: isBot
                                                        ? (isDark ? Colors.white : AppDesignTokens.msgTextBotLight)
                                                        : AppDesignTokens.msgTextUser,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // Typing Indicator
                                    if (_isLoading)
                                      Padding(
                                        padding: AppDesignTokens.paddingThinking,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 14,
                                                height: 14,
                                                child: CircularProgressIndicator(strokeWidth: 1.5),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                AppStrings.of(context, 'botThinking'),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? Colors.white54 : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    // Quick Prompts Row
                                    if (!_isLoading)
                                      SizedBox(
                                        height: 40,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          padding: AppDesignTokens.paddingQuickPrompts,
                                          itemCount: quickPrompts.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () => _sendMessage(quickPrompts[index]),
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 8, bottom: 6),
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  color: AppDesignTokens.quickPromptBg,
                                                  border: Border.all(
                                                    color: AppDesignTokens.quickPromptBorder,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    quickPrompts[index],
                                                    style: const TextStyle(
                                                      color: AppDesignTokens.quickPromptText,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                    // Input Box
                                    Padding(
                                      padding: AppDesignTokens.paddingInputBox,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isDark ? AppDesignTokens.msgBotBgDark : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(25),
                                                border: Border.all(
                                                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                                                ),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: TextField(
                                                controller: _messageController,
                                                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                                decoration: InputDecoration(
                                                  hintText: AppStrings.of(context, 'inputHint'),
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  filled: false,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                                  hintStyle: const TextStyle(fontSize: 14),
                                                ),
                                                maxLines: null,
                                                textInputAction: TextInputAction.send,
                                                onSubmitted: _sendMessage,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            child: IconButton(
                                              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                              onPressed: () => _sendMessage(_messageController.text),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              ),// AnimatedPadding
            ),

          // Draggable floating chat bubble
          if (!_isChatOpen)
            Positioned(
              left: _x,
              top: _y,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _x += details.delta.dx;
                    _y += details.delta.dy;
                    // Constrain position within bounds
                    _x = _x.clamp(
                      AppConstants.floatMinX,
                      size.width - AppConstants.floatMaxXOffset,
                    );
                    _y = _y.clamp(
                      AppConstants.floatMinY,
                      size.height - AppConstants.floatMaxYOffset,
                    );
                  });
                },
                onTap: () {
                  setState(() {
                    _isChatOpen = true;
                  });
                  _scrollToBottom();
                },
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Static Cybernetic Robot Head
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppDesignTokens.botBtnBg,
                            boxShadow: [
                              BoxShadow(
                                color: AppDesignTokens.botBtnShadow,
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: RotationTransition(
                              turns: _shakeAnimation,
                              alignment: Alignment.bottomCenter,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Centered robot avatar image
                                  Positioned(
                                    left: -6, // Centers the 68px image inside the 56px frame
                                    top: 0,
                                    bottom: 0,
                                    width: 68,
                                    child: Image.asset(
                                      'assets/bot_avatar.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  
                                  // Simulated blink overlay
                                  if (_isBlinking)
                                    Positioned(
                                      left: 15, // Aligned with the eyes in the center
                                      top: 24,
                                      child: Container(
                                        width: 26,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppDesignTokens.botEyeBlinkOverlay,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
