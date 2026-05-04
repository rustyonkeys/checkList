import 'package:checklist/util/inbox_block.dart';
import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  final bool isDarkMode;
  final List<InboxBlock> blocks;
  final ValueChanged<List<InboxBlock>> onBlocksChanged;

  const InboxPage({
    super.key,
    required this.isDarkMode,
    required this.blocks,
    required this.onBlocksChanged,
  });

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final TextEditingController _draftController = TextEditingController();
  final FocusNode _draftFocusNode = FocusNode();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final ScrollController _scrollController = ScrollController();

  late List<InboxBlock> _blocks;
  String? _activeBlockId;
  bool _showCommandMenu = false;

  List<_InboxCommand> get _commands => const [
    _InboxCommand(
      type: InboxBlockType.todo,
      title: 'To-do list',
      subtitle: 'Track tasks without a date',
      icon: Icons.checklist,
    ),
    _InboxCommand(
      type: InboxBlockType.bullet,
      title: 'Bulleted list',
      subtitle: 'Quick notes and loose ideas',
      icon: Icons.format_list_bulleted,
    ),
    _InboxCommand(
      type: InboxBlockType.text,
      title: 'Text',
      subtitle: 'Plain paragraph note',
      icon: Icons.notes,
    ),
    _InboxCommand(
      type: InboxBlockType.heading1,
      title: 'Heading 1',
      subtitle: 'Big section title',
      icon: Icons.title,
    ),
    _InboxCommand(
      type: InboxBlockType.heading2,
      title: 'Heading 2',
      subtitle: 'Smaller section title',
      icon: Icons.short_text,
    ),
  ];

  String get _commandQuery {
    final controller =
        _activeBlockId == null ? _draftController : _controllers[_activeBlockId];
    final trimmed = controller?.text.trimLeft() ?? '';
    if (!trimmed.startsWith('/')) return '';
    return trimmed.substring(1).trim().toLowerCase();
  }

  List<_InboxCommand> get _filteredCommands {
    final query = _commandQuery;
    if (query.isEmpty) return _commands;
    return _commands.where((command) {
      return command.title.toLowerCase().contains(query) ||
          command.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _blocks = widget.blocks.map(_cloneBlock).toList();
    _syncControllers();
    _draftController.addListener(_handleDraftChanged);
    _draftFocusNode.addListener(_handleDraftFocusChange);
  }

  @override
  void didUpdateWidget(covariant InboxPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameBlocks(widget.blocks, _blocks)) {
      _blocks = widget.blocks.map(_cloneBlock).toList();
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _draftController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _draftFocusNode.removeListener(_handleDraftFocusChange);
    _draftFocusNode.dispose();
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _syncControllers() {
    final ids = _blocks.map((block) => block.id).toSet();

    for (final block in _blocks) {
      _controllers.putIfAbsent(
        block.id,
        () => TextEditingController(text: block.text),
      );
      _focusNodes.putIfAbsent(block.id, FocusNode.new);
      final controller = _controllers[block.id]!;
      if (controller.text != block.text) {
        controller.value = TextEditingValue(
          text: block.text,
          selection: TextSelection.collapsed(offset: block.text.length),
        );
      }
    }

    final removedIds =
        _controllers.keys.where((id) => !ids.contains(id)).toList();
    for (final id in removedIds) {
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
    }
  }

  void _handleDraftChanged() {
    final controller =
        _activeBlockId == null ? _draftController : _controllers[_activeBlockId];
    final shouldShow = (controller?.text.trimLeft() ?? '').startsWith('/');
    if (shouldShow != _showCommandMenu) {
      setState(() {
        _showCommandMenu = shouldShow;
      });
    } else if (shouldShow) {
      setState(() {});
    }
  }

  void _handleDraftFocusChange() {
    if (!_draftFocusNode.hasFocus) {
      _commitDraftIfNeeded();
    }
  }

  void _updateBlocks(List<InboxBlock> blocks) {
    setState(() {
      _blocks = blocks.map(_cloneBlock).toList();
      _syncControllers();
    });
    widget.onBlocksChanged(_blocks.map(_cloneBlock).toList());
  }

  void _setActiveBlock(String? blockId) {
    if (_activeBlockId == null && blockId != null) {
      _commitDraftIfNeeded();
    }
    if (_activeBlockId == blockId) return;
    setState(() {
      _activeBlockId = blockId;
    });
    _handleDraftChanged();
  }

  void _updateBlockText(InboxBlock block, String value) {
    final normalized = value.replaceAll('\r', '');
    if (normalized.contains('\n')) {
      _continueBlock(block, normalized);
      return;
    }

    block.text = value;
    _updateBlocks(_blocks);
    _handleDraftChanged();
  }

  void _toggleTodo(InboxBlock block, bool value) {
    block.isChecked = value;
    _updateBlocks(_blocks);
  }

  void _removeBlock(InboxBlock block) {
    final updatedBlocks = List<InboxBlock>.from(_blocks)
      ..removeWhere((item) => item.id == block.id);
    _updateBlocks(updatedBlocks);
  }

  void _commitDraftIfNeeded() {
    final text = _draftController.text.trim();
    if (text.isEmpty || text.startsWith('/')) return;
    _insertBlock(type: InboxBlockType.text, text: text, focusNewBlock: false);
  }

  void _insertBlock({
    required InboxBlockType type,
    String text = '',
    bool focusNewBlock = true,
    int? atIndex,
  }) {
    final block = InboxBlock(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      text: text,
      createdAt: DateTime.now(),
    );

    final updatedBlocks = List<InboxBlock>.from(_blocks);
    if (atIndex != null && atIndex >= 0 && atIndex <= updatedBlocks.length) {
      updatedBlocks.insert(atIndex, block);
    } else {
      updatedBlocks.add(block);
    }

    _draftController.clear();
    _updateBlocks(updatedBlocks);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (focusNewBlock) {
        _focusNodes[block.id]?.requestFocus();
      } else {
        _draftFocusNode.requestFocus();
      }
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applyCommand(_InboxCommand command) {
    if (_activeBlockId == null) {
      _insertBlock(type: command.type);
      return;
    }

    final index = _blocks.indexWhere((block) => block.id == _activeBlockId);
    if (index == -1) {
      _insertBlock(type: command.type);
      return;
    }

    final updatedBlocks = List<InboxBlock>.from(_blocks);
    final current = updatedBlocks[index];
    current.type = command.type;
    current.text = '';
    current.isChecked = false;
    _controllers[current.id]?.text = '';
    _updateBlocks(updatedBlocks);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNodes[current.id]?.requestFocus();
    });
  }

  void _continueBlock(InboxBlock block, String rawValue) {
    final segments = rawValue.split('\n');
    final currentText = segments.first;
    final nextText = segments.skip(1).join(' ').trim();
    final index = _blocks.indexWhere((item) => item.id == block.id);
    if (index == -1) return;

    block.text = currentText;
    final nextType = _continuationType(block.type);
    _insertBlock(
      type: nextType,
      text: nextText,
      atIndex: index + 1,
    );
  }

  InboxBlockType _continuationType(InboxBlockType type) {
    switch (type) {
      case InboxBlockType.heading1:
      case InboxBlockType.heading2:
        return InboxBlockType.text;
      case InboxBlockType.todo:
      case InboxBlockType.bullet:
      case InboxBlockType.text:
        return type;
    }
  }

  InboxBlock _cloneBlock(InboxBlock block) {
    return InboxBlock(
      id: block.id,
      type: block.type,
      text: block.text,
      isChecked: block.isChecked,
      createdAt: block.createdAt,
    );
  }

  bool _sameBlocks(List<InboxBlock> a, List<InboxBlock> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].type != b[i].type ||
          a[i].text != b[i].text ||
          a[i].isChecked != b[i].isChecked) {
        return false;
      }
    }
    return true;
  }

  TextStyle _blockTextStyle(InboxBlockType type, Color textColor) {
    switch (type) {
      case InboxBlockType.heading1:
        return TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: textColor,
          height: 1.2,
        );
      case InboxBlockType.heading2:
        return TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1.25,
        );
      case InboxBlockType.todo:
      case InboxBlockType.bullet:
      case InboxBlockType.text:
        return TextStyle(fontSize: 18, color: textColor, height: 1.45);
    }
  }

  String _hintForType(InboxBlockType type) {
    switch (type) {
      case InboxBlockType.todo:
        return 'To-do';
      case InboxBlockType.bullet:
        return 'List item';
      case InboxBlockType.text:
        return 'Empty note';
      case InboxBlockType.heading1:
        return 'Heading';
      case InboxBlockType.heading2:
        return 'Subheading';
    }
  }

  Widget _leading(InboxBlock block, Color subtleTextColor) {
    switch (block.type) {
      case InboxBlockType.todo:
        return Checkbox(
          value: block.isChecked,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: widget.isDarkMode ? Colors.white : Colors.black,
          checkColor: widget.isDarkMode ? Colors.black : Colors.white,
          side: BorderSide(color: subtleTextColor, width: 1.6),
          onChanged: (value) => _toggleTodo(block, value ?? false),
        );
      case InboxBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Icon(Icons.circle, size: 8, color: subtleTextColor),
        );
      case InboxBlockType.text:
        return const SizedBox(width: 8, height: 8);
      case InboxBlockType.heading1:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'H1',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: subtleTextColor,
            ),
          ),
        );
      case InboxBlockType.heading2:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'H2',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: subtleTextColor,
            ),
          ),
        );
    }
  }

  Widget _buildBlockRow(
    InboxBlock block,
    int index,
    Color textColor,
    Color subtleTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 34, child: _leading(block, subtleTextColor)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controllers[block.id],
              focusNode: _focusNodes[block.id],
              minLines: 1,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: _blockTextStyle(block.type, textColor).copyWith(
                decoration:
                    block.type == InboxBlockType.todo && block.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                color:
                    block.type == InboxBlockType.todo && block.isChecked
                        ? subtleTextColor
                        : textColor,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: _hintForType(block.type),
                hintStyle: TextStyle(color: subtleTextColor),
              ),
              onTap: () => _setActiveBlock(block.id),
              onChanged: (value) => _updateBlockText(block, value),
              onSubmitted: (_) => _insertBlock(
                type: block.type,
                atIndex: index + 1,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeBlock(block),
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: 18, color: subtleTextColor),
            tooltip: 'Remove block',
          ),
        ],
      ),
    );
  }

  Widget _buildDraftRow(Color textColor, Color subtleTextColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 34),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _draftController,
              focusNode: _draftFocusNode,
              minLines: 1,
              maxLines: null,
              style: TextStyle(fontSize: 18, color: textColor, height: 1.45),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Type here, or use "/" for commands',
                hintStyle: TextStyle(color: subtleTextColor),
              ),
              onTap: () => _setActiveBlock(null),
              onSubmitted: (_) {
                if (_showCommandMenu && _filteredCommands.isNotEmpty) {
                  _applyCommand(_filteredCommands.first);
                  return;
                }
                _commitDraftIfNeeded();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isDarkMode ? const Color(0xFF111111) : const Color(0xFFF8F6F1);
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF181411);
    final subtleTextColor =
        widget.isDarkMode ? Colors.grey[500]! : const Color(0xFF7A6E64);
    final borderColor =
        widget.isDarkMode ? const Color(0xFF303030) : const Color(0xFFE4DDD1);
    final menuColor =
        widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFCF7);
    final accentColor =
        widget.isDarkMode ? const Color(0xFFE2B36A) : const Color(0xFFB65C1A);

    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _commitDraftIfNeeded();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inbox',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                'Unscheduled work and loose thoughts',
                style: TextStyle(fontSize: 12, color: subtleTextColor),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_showCommandMenu)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  decoration: BoxDecoration(
                    color: menuColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withAlpha(widget.isDarkMode ? 40 : 14),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredCommands.length,
                      separatorBuilder:
                          (_, __) => Divider(color: borderColor, height: 1),
                      itemBuilder: (context, index) {
                        final command = _filteredCommands[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(command.icon, color: accentColor),
                          title: Text(
                            command.title,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            command.subtitle,
                            style: TextStyle(color: subtleTextColor),
                          ),
                          onTap: () => _applyCommand(command),
                        );
                      },
                    ),
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _setActiveBlock(null);
                    _draftFocusNode.requestFocus();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    itemCount: _blocks.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _blocks.length) {
                        return _buildDraftRow(textColor, subtleTextColor);
                      }
                      return _buildBlockRow(
                        _blocks[index],
                        index,
                        textColor,
                        subtleTextColor,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxCommand {
  final InboxBlockType type;
  final String title;
  final String subtitle;
  final IconData icon;

  const _InboxCommand({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
