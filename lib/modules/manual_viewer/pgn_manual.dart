import 'package:dartchess/dartchess.dart';

class TreeNode {
  final PgnChildNode? pgnNode;
  final TreeNode? parent;
  TreeNode(this.pgnNode, {this.parent});

  List<TreeNode> children = [];

  void addChild(TreeNode node) {
    children.add(node);
  }

  int get branchCount => children.length;

  @override
  String toString() => pgnNode?.data.san ?? '';

  static TreeNode empty() => TreeNode(null);
}

class ManualTree {
  late TreeNode _root, _current;

  ManualTree(TreeNode node) {
    _current = _root = node;
  }

  List<TreeNode> nextMoves() {
    return _current.children;
  }

  TreeNode? prevMove() {
    if (_current.parent != null) {
      _current = _current.parent!;
      return _current;
    }

    return null;
  }

  void selectBranch(int index) {
    _current = _current.children[index];
  }

  void rewind() {
    _current = _root;
  }

  (List<PgnChildNode>, int) moveList({bool followMainLine = true}) {
    final link = <PgnChildNode>[];

    var p = _current;
    while (p != _root) {
      link.insert(0, p.pgnNode!);
      p = p.parent!;
    }

    final currentIndex = link.length - 1;

    p = _current;
    while (p.children.isNotEmpty) {
      final child = p.children[0];
      link.add(child.pgnNode!);
      p = child;
    }

    return (link, currentIndex);
  }

  bool get atStartPoint => _current == _root;
  bool get hasMoveBranches => _current.branchCount > 1;
  String? get moveComment => _current.pgnNode?.data.comments?.join('\n');
}

class PgnManual {
  final PgnGame game;
  PgnManual(this.game);

  ManualTree createTree() {
    final root = TreeNode.empty();
    _visitNode(game.moves, root);
    return ManualTree(root);
  }

  void _visitNode(PgnNode<PgnNodeData> pgnNode, TreeNode parent) {
    for (var child in pgnNode.children) {
      final node = TreeNode(child, parent: parent);
      parent.addChild(node);
      _visitNode(child, node);
    }
  }

  String? comment() => game.comments.join('\n');
}