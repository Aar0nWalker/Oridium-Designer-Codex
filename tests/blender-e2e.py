import asyncio
import importlib.util
import os
import pathlib
import sys
import zipfile


def start_blender_addon():
    import bpy

    addon_path = "/src/tools/blender/addon.py"
    spec = importlib.util.spec_from_file_location("oridium_blender_mcp", addon_path)
    addon = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = addon
    spec.loader.exec_module(addon)
    # Direct import has no Blender add-on preferences, and this add-on's fallback
    # incorrectly treats missing preferences as telemetry consent.
    addon.BlenderMCPServer.get_telemetry_consent = lambda self: {"consent": False}
    addon.register()
    bpy.app.driver_namespace["oridium_blender_mcp"] = addon
    print("ORIDIUM_BLENDER_MCP_READY", flush=True)

    optimizer_dir = pathlib.Path("/tmp/oridium-blender-model-optimizer")
    optimizer_zip = pathlib.Path("/src/tools/blender/blender_model_optimizer-2.1.1.zip")
    with zipfile.ZipFile(optimizer_zip) as archive:
        archive.extractall(optimizer_dir)
    optimizer_spec = importlib.util.spec_from_file_location(
        "blender_model_optimizer",
        optimizer_dir / "__init__.py",
        submodule_search_locations=[str(optimizer_dir)],
    )
    optimizer = importlib.util.module_from_spec(optimizer_spec)
    sys.modules[optimizer_spec.name] = optimizer
    optimizer_spec.loader.exec_module(optimizer)
    optimizer.register()
    bpy.app.driver_namespace["oridium_blender_model_optimizer"] = optimizer
    print("ORIDIUM_BLENDER_MODEL_OPTIMIZER_READY", flush=True)


async def run_client():
    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client

    output = pathlib.Path("/output")
    output.mkdir(parents=True, exist_ok=True)
    params = StdioServerParameters(
        command="uvx",
        args=["blender-mcp==1.8.0"],
        env={**os.environ, "BLENDER_MCP_DISABLE_TELEMETRY": "true"},
    )

    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            tools = {tool.name for tool in (await session.list_tools()).tools}
            assert {"get_scene_info", "execute_blender_code"} <= tools

            scene = await session.call_tool(
                "get_scene_info", {"user_prompt": "Inspect the current Blender scene"}
            )
            if scene.isError:
                raise RuntimeError(f"get_scene_info: {scene.content}")
            print("OK: get_scene_info")

            scripts = [
                """import bpy
for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj, do_unlink=True)
bpy.ops.mesh.primitive_plane_add(size=14, location=(0, 0, 0))
ground = bpy.context.object
ground.name = 'test_ground'
bpy.ops.mesh.primitive_cube_add(location=(0, 0, 1.6), scale=(1.5, 1.5, 1.5))
hero = bpy.context.object
hero.name = 'mcp_hero_cube'
bevel = hero.modifiers.new(name='soft_edges', type='BEVEL')
bevel.width = 0.22
bevel.segments = 5
bpy.ops.mesh.primitive_torus_add(major_radius=2.35, minor_radius=0.13, location=(0, 0, 0.35))
ring = bpy.context.object
ring.name = 'mcp_orbit_ring'
bpy.ops.mesh.primitive_uv_sphere_add(segments=64, ring_count=32, location=(3.4, 0, 1.3))
optimizer_target = bpy.context.object
optimizer_target.name = 'optimizer_test_sphere'""",
                """import bpy
def material(name, color, metallic=0.0, roughness=0.45):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = (*color, 1.0)
    shader.inputs['Metallic'].default_value = metallic
    shader.inputs['Roughness'].default_value = roughness
    return mat
bpy.data.objects['test_ground'].data.materials.append(material('ground_navy', (0.025, 0.055, 0.09), roughness=0.7))
bpy.data.objects['mcp_hero_cube'].data.materials.append(material('hero_amber', (1.0, 0.42, 0.035), metallic=0.15, roughness=0.3))
bpy.data.objects['mcp_orbit_ring'].data.materials.append(material('ring_cyan', (0.02, 0.65, 0.9), metallic=0.5, roughness=0.2))
bpy.data.objects['optimizer_test_sphere'].data.materials.append(material('optimizer_green', (0.08, 0.75, 0.3), roughness=0.35))""",
                """import bpy
from mathutils import Vector
def point_at(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat('-Z', 'Y').to_euler()
bpy.ops.object.light_add(type='AREA', location=(4.5, -3.5, 7.0))
key = bpy.context.object
key.name = 'key_light'
key.data.energy = 950
key.data.shape = 'DISK'
key.data.size = 5.0
point_at(key, (0, 0, 1.2))
bpy.ops.object.light_add(type='AREA', location=(-4.0, 1.5, 4.0))
fill = bpy.context.object
fill.name = 'fill_light'
fill.data.energy = 650
fill.data.color = (0.15, 0.55, 1.0)
fill.data.size = 4.0
point_at(fill, (0, 0, 1.2))
bpy.ops.object.camera_add(location=(7.2, -7.2, 5.5))
camera = bpy.context.object
camera.name = 'test_camera'
camera.data.lens = 52
point_at(camera, (0, 0, 1.25))
bpy.context.scene.camera = camera""",
                """import bpy
target = bpy.data.objects['optimizer_test_sphere']
bpy.ops.object.select_all(action='DESELECT')
target.select_set(True)
bpy.context.view_layer.objects.active = target
props = bpy.context.scene.ai_optimizer
props.analysis_target_preset = 'WEB'
assert bpy.ops.ai_optimizer.analyze_mesh() == {'FINISHED'}
props.join_meshes = False
props.merge_materials = False
props.run_remove_interior = False
props.run_remove_small_pieces = False
props.run_symmetry = False
props.run_floor_snap = False
props.run_clean_unused = False
props.run_resize_textures = False
props.bake_normal_map = False
props.protect_uv_seams = True
props.run_planar_prepass = False
props.decimate_ratio = 0.5
faces_before = len(target.data.polygons)
assert bpy.ops.ai_optimizer.decimate() == {'FINISHED'}
faces_after = len(target.data.polygons)
assert 0 < faces_after < faces_before
target['optimizer_faces_before'] = faces_before
target['optimizer_faces_after'] = faces_after""",
                """import bpy
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE_NEXT'
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = '/output/oridium-mcp-test.png'
scene.world.color = (0.008, 0.012, 0.02)
bpy.ops.wm.save_as_mainfile(filepath='/output/oridium-mcp-test.blend')
bpy.ops.render.render(write_still=True)""",
            ]

            for index, code in enumerate(scripts, 1):
                result = await session.call_tool("execute_blender_code", {"code": code})
                if result.isError:
                    raise RuntimeError(f"Blender block {index}: {result.content}")
                print(f"OK: Blender-блок {index}/{len(scripts)}")

            final_scene = await session.call_tool(
                "get_scene_info", {"user_prompt": "Verify the completed test scene"}
            )
            scene_text = " ".join(
                getattr(item, "text", "") for item in final_scene.content
            )
            for object_name in ("test_ground", "mcp_hero_cube", "mcp_orbit_ring", "optimizer_test_sphere"):
                assert object_name in scene_text
            print("OK: итоговая сцена прочитана через MCP")


if __name__ == "__main__":
    mode = sys.argv[-1]
    if mode == "startup":
        start_blender_addon()
    elif mode == "client":
        asyncio.run(run_client())
    else:
        raise SystemExit(f"Unknown mode: {mode}")
