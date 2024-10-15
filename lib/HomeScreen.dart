import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // Keep the same color without changes during drag
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (index) {
          return Draggable<int>(
            data: index, // Pass the index as data
            feedback: widget.builder(_items[index]), // Feedback during drag
            childWhenDragging: Opacity(
              opacity: 0.4, // Show a faded icon while dragging
              child: widget.builder(_items[index]),
            ),
            onDragStarted: () {
              setState(() {
                // Nothing is needed here; we keep the color the same.
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                // No color change needed when dragging is canceled.
              });
            },
            child: DragTarget<int>(
              onWillAccept: (data) => true, // Always accept drag
              onAccept: (data) {
                setState(() {
                  // Swap items when dropped
                  final temp = _items[index];
                  _items[index] = _items[data];
                  _items[data] = temp;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return widget.builder(_items[index]);
              },
            ),
          );
        }),
      ),
    );
  }
}