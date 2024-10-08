# network_graph_visualizer

## Network Graph Demo

![Network Graph Demo](demo/Screencast_20241008_150000.mp4)

## Key Features

1. **Physics Simulation**:
   - Force-directed layout using spring forces
   - Node repulsion to prevent overlapping
   - Damping for smooth movement
   - Can be enabled/disabled via `enablePhysics`

2. **Interactive Features**:
   - Drag and drop nodes
   - Zoom and pan with InteractiveViewer
   - Node selection with visual feedback
   - Connected nodes highlighting

3. **Visual Elements**:
   - Different node types (person, team, project) with custom icons
   - Directional arrows on edges
   - Node shadows for depth
   - Opacity changes for unrelated nodes when selecting

4. **Customization Options**:
   - Node colors and sizes
   - Edge colors and strengths
   - Custom node labels
   - Configurable physics parameters

5. **Performance Considerations**:
   - Efficient custom painting
   - Physics calculations optimized for smooth animation
   - Proper state management

The graph is particularly useful for:

- Organizational charts
- Project dependencies
- System architecture diagrams
- Team collaboration visualization
- Process flows
- Knowledge graphs