# Add-on catalog

Choose tools by intent and verify the installed version before relying on an operator. This
catalog describes optional routes; it does not authorize package installation.

## Modeling and topology

| Intent | Optional route | Native fallback |
|---|---|---|
| Continue a tube around a bend | Curve bevel, a sweep add-on, or a pen-style sweep | Explicit cylinders and arcs |
| Bridge matching rims | Bridge or quick-bridge add-on | `bmesh` bridge or explicit ring construction |
| Safe inset on thin faces | Safe-inset or padding-inset add-on | `bmesh` inset with degenerate-face checks |
| Trim a shared miter plane | Trim or slice add-on | `bmesh.ops.bisect_plane` with fill |
| Align or resample paths | Edge-alignment add-on | Direct vertex and matrix operations |
| Color-code face groups for QC | Face-color add-on | Temporary material indices or vertex colors |

Add-ons are version-sensitive. Verify operator names, context requirements, and background-mode
behavior against the running Blender build. Prefer native APIs when an add-on is modal, UI-only,
or unreliable in headless mode.

## Rendering and compositing

### Shot management

- Use a shot rule system for repeatable camera, frame, resolution, and collection visibility.
- Record current frames with an append operation when authoring multiple shots.
- In background mode, inspect shot rules and call Blender render APIs directly if modal render
  operators do not produce files.

### Layered output

- Use a compositor or layer tool for editable Beauty, Raw, ObjectID, and MaterialID output when
  human compositing is required.
- Set the tool output directory explicitly; a scene render path may not be sufficient.
- Create and assign any compositor group required by the installed version before setup.
- Use multilayer EXR Cryptomatte or another robust ID pass for machine identity. Do not use
  grayscale IDs after JPEG conversion as a scripted object key.

## Native verification toolkit

- `BVHTree.overlap` finds triangle-pair candidates but does not prove full containment.
- Boolean `EXACT` plus `bmesh.calc_volume` supports quantitative overlap checks.
- `bmesh.ops.bisect_plane` supports shared trim and miter planes.
- Direct vertices, dimensions, matrices, and bounds are more reliable than viewport overlays
  for machine checks.
- 3D Print Toolbox can supplement final non-manifold and solid checks when its module is
  available in the chosen Blender version.
