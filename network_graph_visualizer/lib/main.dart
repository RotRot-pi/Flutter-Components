import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

void main() {
  runApp(const MyApp());
}

final nodes = [
  const NodeData(
    id: '1',
    label: 'Design Team',
    type: NodeType.team,
    color: Colors.blue,
  ),
  const NodeData(
    id: '2',
    label: 'Dev Team',
    type: NodeType.team,
    color: Colors.green,
  ),
  const NodeData(
    id: '3',
    label: 'Product Owner',
    type: NodeType.person,
    color: Colors.purple,
  ),
  const NodeData(
    id: '4',
    label: 'Mobile App',
    type: NodeType.project,
    color: Colors.orange,
  ),
  const NodeData(
    id: '5',
    label: 'Web Platform',
    type: NodeType.project,
    color: Colors.red,
  ),
  const NodeData(
    id: '6',
    label: 'QA Team',
    type: NodeType.team,
    color: Colors.teal,
  ),
];

final edges = [
  EdgeData(
    source: '3',
    target: '1',
    color: Colors.grey.shade600,
    strength: 3.0,
  ),
  EdgeData(
    source: '3',
    target: '2',
    color: Colors.grey.shade600,
    strength: 3.0,
  ),
  EdgeData(
    source: '1',
    target: '4',
    color: Colors.blue.shade300,
    strength: 2.0,
  ),
  EdgeData(
    source: '1',
    target: '5',
    color: Colors.blue.shade300,
    strength: 2.0,
  ),
  EdgeData(
    source: '2',
    target: '4',
    color: Colors.green.shade300,
    strength: 2.0,
  ),
  EdgeData(
    source: '2',
    target: '5',
    color: Colors.green.shade300,
    strength: 2.0,
  ),
  EdgeData(
    source: '6',
    target: '4',
    color: Colors.teal.shade300,
    strength: 2.0,
  ),
  EdgeData(
    source: '6',
    target: '5',
    color: Colors.teal.shade300,
    strength: 2.0,
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: NetworkGraph(
          nodes: nodes,
          edges: edges,
          nodeSize: 60,
          enablePhysics: true,
          onNodeTap: (node) {
            print('Tapped node: ${node.label}');
          },
        ),
      ),
    );
  }
}

class NetworkGraph extends StatefulWidget {
  final List<NodeData> nodes;
  final List<EdgeData> edges;
  final double nodeSize;
  final Function(NodeData)? onNodeTap;
  final bool enablePhysics;

  const NetworkGraph({
    super.key,
    required this.nodes,
    required this.edges,
    this.nodeSize = 60,
    this.onNodeTap,
    this.enablePhysics = true,
  });

  @override
  State<NetworkGraph> createState() => _NetworkGraphState();
}

class _NetworkGraphState extends State<NetworkGraph>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late List<NodePosition> nodePositions;
  NodePosition? draggedNode;
  NodeData? selectedNode;
  late AnimationController _physicsController;

  @override
  void initState() {
    super.initState();
    _initializePositions();
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..addListener(_updatePhysics);

    if (widget.enablePhysics) {
      _physicsController.repeat();
    }
  }

  void _initializePositions() {
    final random = math.Random();
    const centerX = 500.0;
    const centerY = 500.0;
    const radius = 200.0;

    nodePositions = List.generate(widget.nodes.length, (index) {
      final angle = (index / widget.nodes.length) * 2 * math.pi;
      return NodePosition(
        node: widget.nodes[index],
        x: centerX +
            radius * math.cos(angle) +
            (random.nextDouble() - 0.5) * 100,
        y: centerY +
            radius * math.sin(angle) +
            (random.nextDouble() - 0.5) * 100,
        vx: 0,
        vy: 0,
      );
    });
  }

  void _updatePhysics() {
    if (!widget.enablePhysics) return;

    const springLength = 200.0;
    const springStrength = 0.1;
    const repulsionStrength = 5000.0;
    const damping = 0.8;

    for (var i = 0; i < nodePositions.length; i++) {
      var position = nodePositions[i];
      double fx = 0;
      double fy = 0;

      // Calculate repulsion between nodes
      for (var j = 0; j < nodePositions.length; j++) {
        if (i != j) {
          final other = nodePositions[j];
          final dx = position.x - other.x;
          final dy = position.y - other.y;
          final distance = math.sqrt(dx * dx + dy * dy);
          if (distance > 0) {
            final force = repulsionStrength / (distance * distance);
            fx += (dx / distance) * force;
            fy += (dy / distance) * force;
          }
        }
      }

      // Calculate spring forces for edges
      for (final edge in widget.edges) {
        if (edge.source == position.node.id ||
            edge.target == position.node.id) {
          final other = nodePositions.firstWhere((np) =>
              np.node.id ==
              (edge.source == position.node.id ? edge.target : edge.source));

          final dx = position.x - other.x;
          final dy = position.y - other.y;
          final distance = math.sqrt(dx * dx + dy * dy);
          if (distance > 0) {
            final force = (distance - springLength) * springStrength;
            fx -= (dx / distance) * force;
            fy -= (dy / distance) * force;
          }
        }
      }

      // Update velocity and position
      if (position != draggedNode) {
        position.vx = (position.vx + fx) * damping;
        position.vy = (position.vy + fy) * damping;
        position.x += position.vx;
        position.y += position.vy;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onPanDown: (details) {
          final offset =
              _transformationController.toScene(details.localPosition);
          draggedNode = _findNearestNode(offset);
        },
        onPanUpdate: (details) {
          if (draggedNode != null) {
            final offset =
                _transformationController.toScene(details.localPosition);
            setState(() {
              draggedNode!.x = offset.dx;
              draggedNode!.y = offset.dy;
            });
          }
        },
        onPanEnd: (_) => draggedNode = null,
        child: CustomPaint(
          size: Size(width, height),
          painter: NetworkPainter(
            nodePositions: nodePositions,
            edges: widget.edges,
            nodeSize: widget.nodeSize,
            selectedNode: selectedNode,
            onTapNode: (node) {
              setState(() => selectedNode = node);
              widget.onNodeTap?.call(node);
            },
          ),
        ),
      ),
    );
  }

  NodePosition? _findNearestNode(Offset point) {
    NodePosition? nearest;
    double minDistance = double.infinity;

    for (final position in nodePositions) {
      final distance = (Offset(position.x, position.y) - point).distance;
      if (distance < widget.nodeSize / 2 && distance < minDistance) {
        minDistance = distance;
        nearest = position;
      }
    }

    return nearest;
  }

  @override
  void dispose() {
    _physicsController.dispose();
    _transformationController.dispose();
    super.dispose();
  }
}

class NetworkPainter extends CustomPainter {
  final List<NodePosition> nodePositions;
  final List<EdgeData> edges;
  final double nodeSize;
  final NodeData? selectedNode;
  final Function(NodeData)? onTapNode;

  NetworkPainter({
    required this.nodePositions,
    required this.edges,
    required this.nodeSize,
    this.selectedNode,
    this.onTapNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges first
    for (final edge in edges) {
      final start = nodePositions.firstWhere((np) => np.node.id == edge.source);
      final end = nodePositions.firstWhere((np) => np.node.id == edge.target);

      final paint = Paint()
        ..color = edge.color.withOpacity(selectedNode == null ||
                edge.source == selectedNode?.id ||
                edge.target == selectedNode?.id
            ? 1.0
            : 0.2)
        ..strokeWidth = edge.strength
        ..style = PaintingStyle.stroke;

      // Draw edge with arrow
      _drawArrowedLine(
        canvas,
        Offset(start.x, start.y),
        Offset(end.x, end.y),
        paint,
      );
    }

    // Draw nodes
    for (final position in nodePositions) {
      final node = position.node;
      final isSelected = node == selectedNode;
      final isConnected = selectedNode == null ||
          edges.any((e) =>
              (e.source == node.id && e.target == selectedNode?.id) ||
              (e.target == node.id && e.source == selectedNode?.id));

      // Draw node shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        Offset(position.x, position.y),
        nodeSize / 2,
        shadowPaint,
      );

      // Draw node background
      final bgPaint = Paint()
        ..color = node.color.withOpacity(isConnected ? 1.0 : 0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(position.x, position.y),
        nodeSize / 2,
        bgPaint,
      );

      // Draw selection indicator
      if (isSelected) {
        final selectionPaint = Paint()
          ..color = node.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawCircle(
          Offset(position.x, position.y),
          nodeSize / 2 + 4,
          selectionPaint,
        );
      }

      // Draw node icon
      final iconPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      _drawNodeIcon(
        canvas,
        Offset(position.x, position.y),
        node.type,
        iconPaint,
        nodeSize * 0.3,
      );

      // Draw node label
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: nodeSize / 4,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.x - textPainter.width / 2,
          position.y + nodeSize / 2 + 4,
        ),
      );
    }
  }

  void _drawArrowedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final original = paint.strokeWidth;

    // Draw main line
    canvas.drawLine(start, end, paint);

    // Calculate arrow
    final delta = end - start;
    final angle = math.atan2(delta.dy, delta.dx);
    final arrowSize = nodeSize / 3;

    final arrowPoint1 = end -
        Offset(
          math.cos(angle - math.pi / 6) * arrowSize,
          math.sin(angle - math.pi / 6) * arrowSize,
        );

    final arrowPoint2 = end -
        Offset(
          math.cos(angle + math.pi / 6) * arrowSize,
          math.sin(angle + math.pi / 6) * arrowSize,
        );

    // Draw arrow
    paint.strokeWidth = original / 2;
    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
  }

  void _drawNodeIcon(
      Canvas canvas, Offset center, NodeType type, Paint paint, double size) {
    final path = Path();

    switch (type) {
      case NodeType.person:
        // Draw person icon
        path.addOval(Rect.fromCenter(
          center: center + Offset(0, -size / 3),
          width: size * 0.6,
          height: size * 0.6,
        ));
        path.addOval(Rect.fromCenter(
          center: center + Offset(0, size / 2),
          width: size,
          height: size * 0.8,
        ));
        break;
      case NodeType.team:
        // Draw team icon
        for (var i = 0; i < 3; i++) {
          final angle = -math.pi / 4 + (i * math.pi / 4);
          final offset = Offset(
            math.cos(angle) * size / 2,
            math.sin(angle) * size / 2,
          );
          path.addOval(Rect.fromCenter(
            center: center + offset,
            width: size * 0.6,
            height: size * 0.6,
          ));
        }
        break;
      case NodeType.project:
        // Draw project icon
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: size,
            height: size * 0.8,
          ),
          Radius.circular(size * 0.1),
        ));
        path.addRect(Rect.fromCenter(
          center: center + Offset(0, -size * 0.2),
          width: size * 0.6,
          height: size * 0.1,
        ));
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NetworkPainter oldDelegate) {
    return true;
  }
}

class NodePosition {
  final NodeData node;
  double x;
  double y;
  double vx;
  double vy;

  NodePosition({
    required this.node,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
  });
}

class NodeData {
  final String id;
  final String label;
  final NodeType type;
  final Color color;

  const NodeData({
    required this.id,
    required this.label,
    required this.type,
    required this.color,
  });
}

class EdgeData {
  final String source;
  final String target;
  final Color color;
  final double strength;

  const EdgeData({
    required this.source,
    required this.target,
    this.color = Colors.grey,
    this.strength = 2.0,
  });
}

enum NodeType {
  person,
  team,
  project,
}
