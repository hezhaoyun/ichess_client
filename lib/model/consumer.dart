import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chess_opening.dart';
import 'provider.dart';

/// 我们应用程序主页
class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ChessOpening> chessOpening = ref.watch(
      chessOpeningProvider,
    );

    final widget = switch (chessOpening) {
      AsyncLoading() => const CircularProgressIndicator(),
      AsyncError() => const Text('Oops, something unexpected happened'),
      AsyncData(:final value) => Text(
        'Activity: ${value.white}, ${value.black}, ${value.draws}',
      ),
      _ => const SizedBox.shrink(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Chess Opening')),
      body: Center(child: widget),
    );
  }
}
