---
name: blender-cad-design-rendering
description: CAD-first проектирование 3D-ассетов, процедурный моделинг в Blender, технические чертежи, рендер и независимая проверка. Использовать для точного моделинга по размерам, чертежам или CAD; ортографических и turntable-рендеров; проверки геометрии, материалов, шарниров и габаритов; экспорта в Unity, Unreal Engine, Godot, FBX, glTF или GLB.
---

# Blender CAD Design and Rendering

Use this skill when the shape, scale, construction, procedural mesh, or verification render of a
3D asset must be decided from evidence rather than guesswork. Keep the workflow engine-neutral
until the final adapter stage.

## Oridium integration

- Load the `blender` and `learned-rules` skills alongside this one.
- Use the repository's configured `blender-mcp` connection for Blender operations.
- Treat FreeCAD and optional Blender add-ons as optional external tools. Do not install them
  without the user's approval; use native Blender APIs when they are sufficient.

## Operating contract

1. Read the project instructions and check the worktree before editing files.
2. State a mechanical completion condition before beginning.
3. Keep requirements and provenance next to the asset. Label each requirement as measured,
   user-specified, reference-derived, or proposed. Never let an aesthetic preference silently
   override a measured dimension.
4. Separate authority domains:
   - dimensions, topology, bends, articulation, and construction: CAD or dimensioned drawings;
   - silhouette, palette, and visual style: supplied reference art;
   - explicit user constraints: authoritative for the stated condition;
   - web references: cross-checks unless explicitly promoted by the user.
5. When references disagree, remeasure with one method or ask for a decision. Do not average
   contradictory measurements.
6. Keep generated files, source parameters, manifests, and verification reports distinguishable.
   Never edit generated mesh data by hand and then claim the source remains authoritative.

## CAD-first workflow

### L0 - Reference and drawing contract

- Collect the dimensioned drawing, manufacturer sheet, scan, or user-provided measurement first.
- Establish origin, axes, units, ground plane, and pivot in one short datum statement.
- Record major parts in a BOM and record seams, joints, radii, fasteners, and material boundaries
  in a separate detail inventory.
- Mark hidden geometry as inferred. Do not present inferred surfaces as measured facts.
- Produce front, side, top, and relevant articulated-state views before mesh construction.
- Put the reference beside the drawing and obtain visual approval when the project requires it.

### L1 - Parametric CAD

- Use FreeCAD or another real parametric CAD system as the authoritative construction layer.
- Keep parameters, requirements, STEP/native CAD output, technical views, and build reports
  together for each asset.
- Write diagnostics to explicit report files because headless CAD commands may swallow stdout
  and tracebacks. Give success, gate failure, and recorded exception distinct outcomes.
- Measure tessellated surfaces as well as analytic bounding boxes. Sweeps, tori, and rotated
  parts can make a bounding box larger than the visible envelope.
- Prefer explicit cylinders, arcs, and verified transitions when a sweep operation changes the
  section orientation unexpectedly.
- Use real CAD operations for drawings. Do not replace the drawing contract with a homemade
  plotting script.

### L2 - Blender realization

- Read geometry from the CAD parameter model or a machine-readable source manifest.
- Store changeable values in one parameter dictionary or JSON document.
- Apply object scale before measuring or placing dependent parts.
- Build dependent parts in the parent member local frame, then transform by the parent world
  matrix. Cut only intentional ground contacts to world-horizontal planes.
- Use manufacturing tags: sheet metal has thickness and bend radius, extrusions keep a section,
  cast parts have draft and radii, and machined parts have declared edge treatment.
- Declare joints such as welds, rivets, ferrules, fasteners, or clearances. Do not hide an
  accidental interpenetration and call it a joint.
- For human-scale or repeated structures, keep section and ergonomic pitch fixed while changing
  count or length. Do not proportionally scale the whole object without a reason.
- Choose the Blender version and add-on route deliberately. Verify the live API against the
  binary that will run the generator.

### L3 - Engine-neutral handoff

- Export units, axes, handedness, origin, pivot, ground contact, meshes, materials, textures,
  LODs, colliders, animation clips, bounds, and hashes in a machine-readable asset manifest.
- Prefer FBX or glTF/GLB with explicit material and texture references. Use OBJ only for simple
  static geometry where its limitations are acceptable.
- Keep engine APIs and package settings in an adapter layer. Do not put Unity, Unreal, or Godot
  assumptions into the CAD source or the core Blender generator.
- Load `references/engine-adapters.md` when a target engine or package format is selected.

## Verification and rendering gates

Use machine evidence and human visual evidence. A generator report is not an independent test.

1. Re-import the exported asset with a separate checker. Compare part census, dimensions,
   envelopes, triangle budget, manifold state, self-intersections, materials, UVs, pivots,
   animation endpoints, and declared bounds.
2. Use BVH overlap for candidate contacts, Boolean EXACT plus volume checks for quantitative
   overlap or containment, and plane bisects for shared trim or miter planes.
3. Render orthographic front, side, and top views; an isometric view with scale; turntable
   angles; articulated states; and close-ups of joints or high-risk details.
4. Place references beside renders at every major stage: silhouette, proportions, construction,
   detail, and material/look development.
5. Open the actual PNG or EXR files. Exit code, file existence, and byte size are not visual
   proof.
6. Record exact paths, tool versions, measured values, and unverified gates in the handoff.

## Render and add-on routing

- Prefer native `bpy`, `bmesh`, `mathutils`, BVH, Boolean, and matrix APIs for repeatable
  headless work.
- Use an add-on only when it materially improves a repeated task and the installed version
  is verified. Load `references/addon-catalog.md` for intent-based routing.
- Use a shot manager for stable repeated framings, but inspect its rules and bypass modal
  operators in background mode when they do not write renders.
- Use Cryptomatte or another machine-readable multilayer ID pass for scripted identity.
  Treat grayscale ID layers and JPEG intermediates as human selection aids, not identity truth.
- Compare prop-only renders against references. Do not classify highlights or background pixels
  as material evidence.

## Resource map

- `references/field-notes.md`: reusable CAD, Blender, and rendering failure modes.
- `references/addon-catalog.md`: optional add-ons and native alternatives by intent.
- `references/engine-adapters.md`: engine-neutral manifest and Unity/Unreal/Godot handoff.
- `references/search-index.md`: English trigger phrases and routing tags.

## Safety boundary

- Preserve source files and unrelated worktree changes.
- Do not expose or save tokens, keys, credentials, private paths, or environment files.
- Do not deploy assets to a live application as part of this skill.
- Keep the CAD source, Blender generator, exported asset, and packaged runtime artifact as
  separate stages with independent verification.
