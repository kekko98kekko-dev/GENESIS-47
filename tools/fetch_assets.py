"""Download only CC0 data assets, not code. Run in the free CI runner."""
import json, pathlib, urllib.request, urllib.parse, zipfile, io, shutil, re, sys
root=pathlib.Path("assets/generated")
root.mkdir(parents=True,exist_ok=True)
catalog={k:[] for k in ("tree","rock","house","industrial","future","animal","creature","prop","farm","early","cart","reborn_tree","reborn_understory","reborn_home","reborn_civic","reborn_prop","reborn_crop","reborn_beast")}
def get(url):
    req=urllib.request.Request(url,headers={"User-Agent":"GENESIS-47-asset-build"})
    with urllib.request.urlopen(req,timeout=50) as r:return r.read()
def add(kind,path):
    catalog[kind].append("res://"+path.as_posix())
def raw_model(kind,repo,ref,source):
    url=f"https://raw.githubusercontent.com/{repo}/{ref}/"+urllib.parse.quote(source,safe="/")
    dst=root/kind/pathlib.PurePosixPath(source).name.replace(" ","_").lower()
    dst.parent.mkdir(parents=True,exist_ok=True)
    data=get(url)
    if data[:4]!=b"glTF":raise ValueError("Not a GLB: "+source)
    dst.write_bytes(data)
    add(kind,dst)
def safe_call(fn,*args):
    try:fn(*args)
    except Exception as e:print("ASSET WARNING:",str(e),file=sys.stderr)
def tree(repo):
    data=json.loads(pathlib.Path("tools/asset_manifest.json").read_text())[repo]
    return data["ref"],data["paths"]
# Quaternius showcase: converted GLB models, CC0 per upstream pack licenses.
def showcase():
    repo="trebeljahr/quaternius-showcase"
    ref,paths=tree(repo)
    prefix="public/glb/"
    groups={
      "house":("medieval_village_pack/",["House_1","House_2","House_3","House_4","Mill","Inn","Blacksmith","Bell_Tower"]),
      "prop":("medieval_village_pack/",["Well","Barrel","Cart","MarketStand_1","Bonfire_Lit"]),
      "animal":("animals_pack/",["Deer","Fox","Sheep","Rabbit","Cow","Horse"]),
      "industrial":("buildings_pack_2/",[]),
      "future":("modular_sci_fi/",["Props_Teleporter_1","Props_Pod","Props_Capsule","Props_Computer","Props_Vessel_Tall","Props_Vessel"]),
      "farm":("real_time_strategy_pack/",["Farm_FirstAge_Level1_Wheat","Farm_FirstAge_Level2_Wheat","Farm_SecondAge_Level1_Wheat"]),
      "early":("real_time_strategy_pack/",["Houses_FirstAge_1_Level1","Houses_FirstAge_2_Level1","Houses_FirstAge_1_Level2"]),
      "cart":("medieval_village_pack/",["Cart"]),
      "tree":("nature_pack/",["BirchTree_1","BirchTree_2","CommonTree_1","CommonTree_2","CommonTree_3","PineTree_1","PineTree_2","PineTree_3"]),
      "rock":("nature_pack/",["Rock_1","Rock_2","Rock_3","Rock_4","Rock_Moss_1","Rock_Moss_2"])}
    for kind,(folder,names) in groups.items():
        candidates=[p for p in paths if p.startswith(prefix+folder) and p.lower().endswith(".glb")]
        if names:candidates=[p for p in candidates if pathlib.PurePosixPath(p).stem in names]
        elif kind in ("industrial","future"):
            candidates=[p for p in candidates if re.search(r"building|house|tower",p,re.I)]
        for p in sorted(candidates)[:8]:safe_call(raw_model,kind,repo,ref,p)
def kenney():
    data=get("https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip")
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        names=z.namelist()
        models=[n for n in names if n.lower().endswith(".glb")]
        for kind,pattern in [("tree",r"(^|[-_])tree"),("rock",r"(^|[-_])rock")]:
            found=[n for n in models if re.search(pattern,pathlib.PurePosixPath(n).stem,re.I)]
            for n in sorted(found)[:10]:
                dst=root/kind/pathlib.PurePosixPath(n).name.lower()
                dst.parent.mkdir(parents=True,exist_ok=True)
                dst.write_bytes(z.read(n))
                add(kind,dst)
        if not models:
            print("Kenney archive lacks GLB; trying self-contained glTF sets.")
            for kind,pattern in [("tree",r"(^|[-_])tree"),("rock",r"(^|[-_])rock")]:
                found=[n for n in names if n.lower().endswith(".gltf") and re.search(pattern,pathlib.PurePosixPath(n).stem,re.I)]
                for n in sorted(found)[:8]:
                    src=pathlib.PurePosixPath(n)
                    dst=root/kind/src.name.lower()
                    dst.parent.mkdir(parents=True,exist_ok=True)
                    obj=json.loads(z.read(n))
                    for it in obj.get("buffers",[])+obj.get("images",[]):
                        uri=it.get("uri","")
                        if uri and not uri.startswith("data:"):
                            rel=pathlib.PurePosixPath(urllib.parse.unquote(uri))
                            if rel.is_absolute() or ".." in rel.parts:raise ValueError("Invalid resource URI")
                            out=dst.parent/pathlib.Path(*rel.parts)
                            out.parent.mkdir(parents=True,exist_ok=True)
                            out.write_bytes(z.read(str(src.parent/rel)))
                    dst.write_text(json.dumps(obj))
                    add(kind,dst)
def creatures():
    repo="agentkaerf/FreeModels"
    ref,paths=tree(repo)
    prefix="Cute Animated Monsters - Aug 2020/"
    chosen=[p for p in paths if p.startswith(prefix) and p.lower().endswith(".glb")]
    if chosen:
        for p in sorted(chosen)[:8]:safe_call(raw_model,"creature",repo,ref,p)
        return
    chosen=[p for p in paths if p.startswith(prefix) and p.lower().endswith(".gltf")]
    for i,p in enumerate(sorted(chosen)[:8]):
        try:
            raw=f"https://raw.githubusercontent.com/{repo}/{ref}/"
            obj=json.loads(get(raw+urllib.parse.quote(p,safe="/")))
            dest=root/"creature"/str(i)
            dest.mkdir(parents=True,exist_ok=True)
            for it in obj.get("buffers",[])+obj.get("images",[]):
                uri=it.get("uri","")
                if uri and not uri.startswith("data:"):
                    rel=pathlib.PurePosixPath(urllib.parse.unquote(uri))
                    if rel.is_absolute() or ".." in rel.parts:raise ValueError("Invalid resource URI")
                    source=str(pathlib.PurePosixPath(p).parent/rel)
                    target=dest/pathlib.Path(*rel.parts)
                    target.parent.mkdir(parents=True,exist_ok=True)
                    target.write_bytes(get(raw+urllib.parse.quote(source,safe="/")))
            target=dest/"creature.gltf"
            target.write_text(json.dumps(obj))
            add("creature",target)
        except Exception as e:print("CREATURE WARNING",e)
def reborn():
    # Pinned CC0 source, selected names verified against the repository tree.
    repo="agentkaerf/FreeModels"
    ref="db3df04d1e4714298a09510b26fb6de6645138a2"
    raw=f"https://raw.githubusercontent.com/{repo}/{ref}/"
    def gltf(kind,folder,name):
        p=pathlib.PurePosixPath(folder)/("glTF")/(name+".gltf")
        obj=json.loads(get(raw+urllib.parse.quote(str(p),safe="/")))
        dest=root/kind/name.lower()
        dest.mkdir(parents=True,exist_ok=True)
        for it in obj.get("buffers",[])+obj.get("images",[]):
            uri=it.get("uri","")
            if not uri or uri.startswith("data:"):continue
            rel=pathlib.PurePosixPath(urllib.parse.unquote(uri))
            if rel.is_absolute() or ".." in rel.parts:raise ValueError("Unsafe glTF path")
            target=dest/pathlib.Path(*rel.parts)
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(get(raw+urllib.parse.quote(str(p.parent/rel),safe="/")))
        target=dest/(name.lower()+".gltf")
        target.write_text(json.dumps(obj))
        add(kind,target)
    nature="Ultimate Stylized Nature - May 2022"
    for kind,names in [
        ("reborn_tree",["BirchTree_1","BirchTree_3","MapleTree_1","MapleTree_3","MapleTree_5"]),
        ("reborn_understory",["Bush","Bush_Flowers","Bush_Small","Flower_1_Clump","Flower_3_Clump","Grass_Large"]),
        ("reborn_beast",["Alien","Alien_Tall","Cthulhu","Crab","Deer","Demon","Mushroom","YellowDragon"])]:
        for name in names:gltf(kind,"Cute Animated Monsters - Aug 2020" if kind=="reborn_beast" else nature,name)
    repo2="trebeljahr/quaternius-showcase"
    ref2,paths2=tree(repo2)
    groups={
      "reborn_home":("medieval_village_pack",["House_1","House_2","House_3","House_4"]),
      "reborn_civic":("medieval_village_pack",["Mill","Inn","Blacksmith","Bell_Tower","Sawmill","Stable","Gazebo"]),
      "reborn_prop":("medieval_village_pack",["Fence","Bench_1","Crate","Hay","Barrel","MarketStand_1","Well","Cart"]),
      "reborn_crop":("crops_pack",["Pumpkin_4","Wheat_3","Corn_4","Carrot_4","Lettuce_4"])}
    for kind,(folder,names) in groups.items():
        for name in names:
            path=f"public/glb/{folder}/{name}.glb"
            if path not in paths2:raise ValueError("Missing pinned asset "+path)
            raw_model(kind,repo2,ref2,path)

for f in (showcase,creatures):safe_call(f)
reborn()
if not catalog["tree"] or not catalog["rock"]:safe_call(kenney)
(root/"catalog.json").write_text(json.dumps(catalog))
print("ASSET COUNTS", {k:len(v) for k,v in catalog.items()})
if sum(map(len,catalog.values()))<60 or any(not v for v in catalog.values()):
    raise SystemExit("Required art missing: refusing to publish a visually degraded build.")
