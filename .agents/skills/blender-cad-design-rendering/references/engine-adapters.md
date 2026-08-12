# Engine adapter contract

Keep the CAD and Blender core engine-neutral. Put target-engine import, material conversion,
packaging, and runtime validation behind a replaceable adapter.

## Engine-neutral manifest

Record at minimum:

- source identity, requirements, generator version, Blender version, and file hashes;
- units, up axis, forward axis, handedness, origin, pivot, and ground contact;
- mesh, vertex, triangle, normal, UV, material, texture, and LOD counts;
- bounds, collider intent, animation clips, rigid bodies, constraints, and static/dynamic state;
- interchange files, declared import settings, package format, and independent readback path.

The adapter must not silently repair axes, dimensions, materials, or pivots. If a conversion is
required, record it as a declared setting and compare the post-import result with the manifest.

## Unity 6

1. Pin the exact Unity 6 editor and project version.
2. Import FBX or glTF/GLB into an isolated project.
3. Read back transforms, meshes, materials, textures, bounds, animation data, and import flags.
4. Apply only settings declared by the asset manifest.
5. Build the project's selected package format.
6. Read the packaged artifact independently of the build script.
7. Compare the package readback against the engine-neutral manifest and retain the report.

## Unreal Engine

- Pin the engine version and import profile.
- Read back static or skeletal mesh counts, materials, sockets, collision, bounds, LODs, and
  animation assets from imported project content.
- Validate cooked or packaged output independently when the asset is shipped in a build.

## Godot and other engines

- Pin the project and importer version.
- Read back nodes, meshes, materials, textures, transforms, bounds, animations, and collision.
- Keep engine-specific scripts in the adapter directory and compare results with the manifest.

## Minimum readback gate

Record the artifact path and hash, object identity, renderer/mesh/material/texture counts,
shader or material bindings, local and world bounds, pivot, ground contact, forward direction,
triangle and vertex budgets, LODs, colliders, animation clips, and constraint metadata where
applicable. An exit code, imported file, or package size is not sufficient evidence.
