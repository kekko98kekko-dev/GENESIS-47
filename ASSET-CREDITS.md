# Asset credits
All imported models are selected from public CC0 model packs; original models remain the work of their creators.
- Kenney, Nature Kit — https://kenney.nl/assets/nature-kit — CC0.
- Quaternius, Medieval Village, Ultimate Animated Animals, Cute Animated Monsters and related CC0 packs — https://quaternius.com/ — GLB mirror https://github.com/trebeljahr/quaternius-showcase and glTF mirror https://github.com/agentkaerf/FreeModels.
- Original terrain, procedural geometry, shaders and UI for GENESIS 47.
- Godot Engine — MIT; engine attribution is available at https://godotengine.org/license/.
The asset fetch script lists actual downloaded assets in assets/generated/catalog.json. If a source fails, native procedural models remain available.

## Motion capture — CMU Graphics Lab
Walking motion 35_01, derived from the BVH conversion at https://github.com/una-dinosauria/cmu-mocap/blob/master/data/035/35_01.bvh. Original database: https://mocap.cs.cmu.edu/. CMU permits inclusion in commercial products, but prohibits resale of the capture data itself. Data obtained from the CMU database, funded by NSF EIA-0196217. 32 retargeted samples from frames 85–218, sagittal axes mapped and constrained for GENESIS 47. The game includes the derived cycle, not the original dataset or an external runtime.

## 7.0 — Additional CMU recordings
- eat: CMU 13_09, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/013/13_09.bvh, source frames 88–1014; 40 retargeted samples, three rotation channels per selected joint.
- farm: CMU 79_04, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/079/79_04.bvh, source frames 72–837; 40 retargeted samples, three rotation channels per selected joint.
- craft: CMU 62_07, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/062/62_07.bvh, source frames 89–1025; 40 retargeted samples, three rotation channels per selected joint.
- carry: CMU 70_01, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/070/70_01.bvh, source frames 25–91; 40 retargeted samples, three rotation channels per selected joint.
- play: CMU 16_01, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/016/16_01.bvh, source frames 25–297; 40 retargeted samples, three rotation channels per selected joint.
- sleep: CMU 77_16, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/077/77_16.bvh, source frames 52–601; 40 retargeted samples, three rotation channels per selected joint.
- run: CMU 09_01, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/009/09_01.bvh, source frames 11–137; 40 retargeted samples, three rotation channels per selected joint.
- gather: CMU 26_10, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/026/26_10.bvh, source frames 55–642; 40 retargeted samples, three rotation channels per selected joint.
- social: CMU 18_09, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/018/18_09.bvh, source frames 18–214; 40 retargeted samples, three rotation channels per selected joint.
- idle: CMU 140_07, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/140/140_07.bvh, source frames 98–1137; 40 retargeted samples, three rotation channels per selected joint.
- guard: CMU 77_03, source https://raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/data/077/77_03.bvh, source frames 78–906; 40 retargeted samples, three rotation channels per selected joint.
Original database and attribution as above. The recordings are adapted to creature tasks and are not distributed as original BVH files. Some tasks use an analogous motion rather than a dedicated capture.
