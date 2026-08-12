# Field notes

These are reusable observations for CAD-first Blender work. Reconfirm version-sensitive details
against the active tools and asset contract.

## CAD and provenance

- Perspective can make a rectangular panel look trapezoidal. Prefer dimensioned drawings over
  small perspective references for topology and section decisions.
- Keep requirements, measured values, and proposals in separate rows. Preserve rejected rows and
  their reasons so a later correction does not silently resurrect a discarded assumption.
- A real drawing can settle silhouette and construction; a style reference can settle palette
  and presentation. Neither source should silently replace the other authority.
- Headless FreeCAD may swallow standard output and tracebacks. Write explicit build and error
  reports and distinguish a successful gate from a command that merely exited.
- `Shape.BoundBox` can overestimate swept or rotated geometry. Measure a tessellated envelope
  for acceptance where the visible envelope matters.
- Sweep profiles can tilt when a closed wire is used as a section. Validate section orientation
  with a cross-section probe and prefer explicit arcs or solids when the result is unstable.

## Blender construction

- One continuous extrusion should remain one continuous solid. Fragment stacks can create seams,
  shading discontinuities, and false joints.
- Parent-local placement avoids wobbling caps and inclined-member errors. Transform local offsets
  with the parent's world matrix, then apply only intentional ground cuts in world space.
- Manufacturing grammar is a useful geometry test: constant section for extrusions, thickness
  and bend radius for sheet, draft and radii for cast parts, and declared treatment for machined
  edges.
- Use distance-based resolution and inspect close-ups. A mesh can meet a triangle budget while
  still showing curvature discontinuities at the camera distance that matters.
- Regenerate from parameters after corrections. Do not patch an exported mesh while retaining an
  old source file as if it were reproducible.

## Rendering and QC

- Render orthographic views, scale views, turntable angles, articulated states, and joint
  close-ups. A single attractive perspective can hide incorrect proportions or joints.
- Put reference and render side by side at each stage instead of waiting for final presentation.
- Inspect the actual image files. Render completion and file size do not prove visual quality.
- A world-space lighting function can make vertical tubes dark and horizontal members bright.
  For stylized tube materials, evaluate light in the plane perpendicular to each tube axis.
- Treat beauty, ID, and material passes as different evidence. Use Cryptomatte or multilayer EXR
  for machine identity; use editable grayscale layers for human selection only.
- Keep background and unrelated pixels out of prop-only material tests.

## Common failure classes

- Build report marked OK without opening the render.
- One pixel measurement used to infer hidden topology.
- A typical product used in place of a supplied drawing.
- A local symptom patch that invalidates another settled requirement.
- The same coordinate duplicated in prose, JSON, and generator code.
- A modal add-on called from background mode and silently producing no output.
- A grayscale or JPEG ID pass used as machine identity after it has collided with the background.
