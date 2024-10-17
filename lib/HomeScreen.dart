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
            builder: (icon) {
              return _buildDockItem(icon); // Method to build each dock item
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}

/// Dock widget to manage draggable items.
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<IconData> items;
  final Widget Function(IconData) builder;

  @override
  State<Dock> createState() => _DockState();
}

/// State of the Dock widget
class _DockState extends State<Dock> {
  late List<IconData> _items = widget.items.toList(); // Active dock items
  List<IconData> _removedItems = []; // Removed items

  @override
  Widget build(BuildContext context) {
    // Get the screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          // The draggable dock where items can be added/removed
          DragTarget<IconData>(
            onAccept: (data) {
              setState(() {
                // Add item back to the dock only if it's not already there
                if (!_items.contains(data)) {
                  _items.add(data);
                }
              });
            },
            onWillAccept: (data) =>
                !_items.contains(data), // Only accept new items
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black12,
                ),
                padding: const EdgeInsets.all(4),
                width: _items.length * 64.0 +
                    8, // Dynamic width based on item count
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _items.map((icon) {
                    return Draggable<IconData>(
                      data: icon,
                      child: widget.builder(icon), // Display icon in dock
                      feedback: Material(
                        color: Colors.transparent,
                        child: widget.builder(icon), // Display icon during drag
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: widget.builder(
                            icon), // Semi-transparent item while dragging
                      ),
                      onDragCompleted: () {
                        setState(() {
                          _items.remove(
                              icon); // Remove item from dock when drag completes
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Drag target outside the dock for dropping the icon
          DragTarget<IconData>(
            onAccept: (data) {
              setState(() {
                _removedItems.add(data); // Add item to the removed items list
                _items.remove(data); // Remove item from the dock
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 100,
                width: screenWidth * 0.8, // Make the container width responsive
                color: Colors.grey.withOpacity(0.3),
                child: const Center(
                  child: Text("Drag here to remove"),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Display removed items and allow them to be redragged back into the dock
          _removedItems.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  children: _removedItems.map((icon) {
                    return Draggable<IconData>(
                      data: icon,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 48),
                        height: 48,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.primaries[
                              icon.hashCode % Colors.primaries.length],
                        ),
                        child: Center(
                          child: Icon(icon, color: Colors.white),
                        ),
                      ),
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 48),
                          height: 48,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.primaries[
                                icon.hashCode % Colors.primaries.length],
                          ),
                          child: Center(
                            child: Icon(icon, color: Colors.white),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 48),
                          height: 48,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.primaries[
                                icon.hashCode % Colors.primaries.length],
                          ),
                          child: Center(
                            child: Icon(icon, color: Colors.white),
                          ),
                        ),
                      ),
                      onDragCompleted: () {
                        setState(() {
                          _removedItems
                              .remove(icon); // Remove item from removed list
                          // Add item back to dock only if it's not already there
                          if (!_items.contains(icon)) {
                            _items.add(icon);
                          }
                        });
                      },
                    );
                  }).toList(),
                )
              : const Text("No items removed yet."),
          const SizedBox(height: 20),
          // New TextField as a drop target to reinsert icons
          DragTarget<IconData>(
            onAccept: (data) {
              setState(() {
                // Add item back to the dock only if it's not already there
                if (!_items.contains(data)) {
                  _items.add(data); // Add item back to the dock
                  _removedItems
                      .remove(data); // Remove item from the removed list
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context)
                      .unfocus(); // Remove keyboard when tapping
                },
                child: AbsorbPointer(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Drag here to reinsert an icon",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
