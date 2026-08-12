# Search index

Use English request signals to find this skill. The canonical entry point is
`.agents/skills/blender-cad-design-rendering/SKILL.md`.

## Tags

blender, CAD, FreeCAD, parametric modeling, technical drawing, dimensioned drawing,
orthographic render, turntable render, render QC, visual verification, headless Blender,
bpy, bmesh, BVHTree, Boolean EXACT, bisect plane, weldment, BOM, manufacturing grammar,
industrial modeling, product visualization, prop modeling, mechanism modeling, Blender add-ons,
shot management, compositing, Cryptomatte, multilayer EXR, Unity 6, Unreal Engine, Godot,
FBX, glTF, GLB, material manifest, asset manifest, engine adapter, LOD, collider, interchange,
pipeline, technical portfolio, Claude, Codex, GitHub skill.

## English trigger phrases

- Design a 3D asset from CAD or dimensioned drawings.
- Build a procedural Blender model from measured references.
- Create orthographic, turntable, or articulated-state renders.
- Check dimensions, topology, intersections, materials, UVs, bounds, or pivots.
- Choose a Blender add-on for a modeling or render-QC task.
- Prepare a Unity 6, Unreal, Godot, or engine-neutral asset handoff.
- Produce a technical portfolio cover that compares CAD evidence with a final render.

## Routing

| Request | Load |
|---|---|
| CAD, dimensions, technical drawing, FreeCAD | SKILL.md, then field-notes.md |
| Add-on, operator, topology, UV, render queue | addon-catalog.md |
| Unity 6, Unreal, Godot, FBX, glTF, packaging, readback | engine-adapters.md |
| Render comparison, ID pass, Cryptomatte, portfolio cover | SKILL.md and addon-catalog.md |
