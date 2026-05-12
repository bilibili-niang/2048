import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/models/history_record.dart';
import 'package:game2048/providers/game_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _HistoryFilter { all, running, finished, reachedTarget }

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final records = gameProvider.historyRecords;
          final filteredRecords = _applyFilter(records);
          if (records.isEmpty) {
            return const Center(
              child: Text('暂无历史记录'),
            );
          }

          return Column(
            children: [
              _HistorySummaryBar(
                allCount: records.length,
                runningCount: records.where((record) => record.result == 'running').length,
                finishedCount: records.where((record) => record.result != 'running').length,
                reachedCount: records.where((record) => record.isTargetReached).length,
              ),
              _HistoryFilterBar(
                current: _filter,
                onChanged: (nextFilter) {
                  setState(() {
                    _filter = nextFilter;
                  });
                },
              ),
              Expanded(
                child: filteredRecords.isEmpty
                    ? const Center(child: Text('当前筛选下暂无记录'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final record = filteredRecords[index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            title: Text(
                              '${record.gridSize}x${record.gridSize}  分数 ${record.finalScore}',
                            ),
                            subtitle: Text(
                              '${_resultLabel(record.result)} · 最高 ${record.maxTile} · 步数 ${record.steps}',
                            ),
                            trailing: Text(_displayTime(record)),
                            onTap: () => _showDetails(context, record),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemCount: filteredRecords.length,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<HistoryRecord> _applyFilter(List<HistoryRecord> records) {
    switch (_filter) {
      case _HistoryFilter.all:
        return records;
      case _HistoryFilter.running:
        return records.where((record) => record.result == 'running').toList();
      case _HistoryFilter.finished:
        return records.where((record) => record.result != 'running').toList();
      case _HistoryFilter.reachedTarget:
        return records.where((record) => record.isTargetReached).toList();
    }
  }

  String _displayTime(HistoryRecord record) {
    final raw = record.endAt ?? record.updatedAt;
    final time = DateTime.tryParse(raw);
    if (time == null) {
      return raw;
    }
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  String _displayDetailTime(String raw) {
    final time = DateTime.tryParse(raw);
    if (time == null) {
      return raw;
    }
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '${time.year}-$month-$day $hour:$minute:$second';
  }

  String _resultLabel(String result) {
    switch (result) {
      case 'running':
        return '进行中';
      case 'over':
        return '失败';
      case 'abandoned':
        return '主动结束';
      case 'won_continued':
        return '达成目标后继续';
      default:
        return result;
    }
  }

  void _showDetails(BuildContext context, HistoryRecord record) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('记录详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('网格：${record.gridSize}x${record.gridSize}'),
              Text('目标方块：${record.targetTile}'),
              Text('最终分数：${record.finalScore}'),
              Text('最高方块：${record.maxTile}'),
              Text('步数：${record.steps}'),
              Text('目标达成：${record.isTargetReached ? '是' : '否'}'),
              Text('结果：${_resultLabel(record.result)}'),
              Text('开始时间：${_displayDetailTime(record.startAt)}'),
              if (record.endAt != null) Text('结束时间：${_displayDetailTime(record.endAt!)}'),
              Text('最近更新时间：${_displayDetailTime(record.updatedAt)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}

class _HistorySummaryBar extends StatelessWidget {
  final int allCount;
  final int runningCount;
  final int finishedCount;
  final int reachedCount;

  const _HistorySummaryBar({
    required this.allCount,
    required this.runningCount,
    required this.finishedCount,
    required this.reachedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _PillStat(label: '总记录', value: allCount),
          _PillStat(label: '进行中', value: runningCount),
          _PillStat(label: '已结束', value: finishedCount),
          _PillStat(label: '达成目标', value: reachedCount),
        ],
      ),
    );
  }
}

class _HistoryFilterBar extends StatelessWidget {
  final _HistoryFilter current;
  final ValueChanged<_HistoryFilter> onChanged;

  const _HistoryFilterBar({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipItem(
            selected: current == _HistoryFilter.all,
            label: '全部',
            onTap: () => onChanged(_HistoryFilter.all),
          ),
          _FilterChipItem(
            selected: current == _HistoryFilter.running,
            label: '进行中',
            onTap: () => onChanged(_HistoryFilter.running),
          ),
          _FilterChipItem(
            selected: current == _HistoryFilter.finished,
            label: '已结束',
            onTap: () => onChanged(_HistoryFilter.finished),
          ),
          _FilterChipItem(
            selected: current == _HistoryFilter.reachedTarget,
            label: '达成目标',
            onTap: () => onChanged(_HistoryFilter.reachedTarget),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  final String label;
  final int value;

  const _PillStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text('$label $value'),
    );
  }
}
