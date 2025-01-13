import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/chess_opening.dart';
import '../../model/provider.dart';

class OpeningExplorerPage extends ConsumerStatefulWidget {
  const OpeningExplorerPage({super.key});

  @override
  ConsumerState<OpeningExplorerPage> createState() => _OpeningExplorerPageState();
}

class _OpeningExplorerPageState extends ConsumerState<OpeningExplorerPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<ChessOpening> chessOpening = ref.watch(chessOpeningProvider);
    final dataSheet = switch (chessOpening) {
      AsyncLoading() => const CircularProgressIndicator(),
      AsyncError() => const Text('Oops, something unexpected happened'),
      AsyncData(:final value) => Text('Activity: ${value.white}, ${value.black}, ${value.draws}'),
      _ => const SizedBox.shrink(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Opening Explorer')),
      body: Center(child: dataSheet),
    );
  }
}
