import 'package:dartchess/dartchess.dart';

class TreeNode {
  final PgnChildNode? pgnNode;
  final TreeNode? parent;
  TreeNode(this.pgnNode, {this.parent});

  List<TreeNode> children = [];

  void addChild(TreeNode node) {
    children.add(node);
  }

  bool get hasSibling => (parent?.branchCount ?? 0) > 1;

  int get branchCount => children.length;

  @override
  String toString() => pgnNode?.data.san ?? '';

  static TreeNode empty() => TreeNode(null);
}

class GameTree {
  late TreeNode _root, _current;

  GameTree(TreeNode node) {
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

  TreeNode selectBranch(int index) {
    _current = _current.children[index];
    return _current;
  }

  TreeNode? switchSibling(int index) {
    if (index < 0 || index >= _current.parent!.branchCount) return null;
    _current = _current.parent!.children[index];
    return _current;
  }

  int get siblingCount => _current.parent?.branchCount ?? 0;

  TreeNode? get current => _current;

  TreeNode? getSibling(int index) {
    if (index < 0 || index >= _current.parent!.branchCount) return null;
    return _current.parent!.children[index];
  }

  void rewind() {
    _current = _root;
  }

  (List<TreeNode>, int) moveList() {
    final link = <TreeNode>[];

    var p = _current;
    while (p != _root) {
      link.insert(0, p);
      p = p.parent!;
    }

    final currentIndex = link.length - 1;

    p = _current;
    while (p.children.isNotEmpty) {
      final child = p.children[0];
      link.add(child);
      p = child;
    }

    return (link, currentIndex);
  }

  bool get atStartPoint => _current == _root;
  bool get hasMoveBranches => _current.branchCount > 1;
  String? get moveComment => _current.pgnNode?.data.comments?.join('\n');
}

class PgnGameEx {
  final PgnGame game;
  PgnGameEx(this.game);

  GameTree? _tree;

  GameTree? get tree {
    if (_tree != null) return _tree;

    final root = TreeNode.empty();
    _visitNode(game.moves, root);
    _tree = GameTree(root);

    return _tree;
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
