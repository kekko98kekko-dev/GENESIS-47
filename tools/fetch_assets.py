"""Download only CC0 data assets, not code. Run in the free CI runner."""
import json, pathlib, urllib.request, urllib.parse, zipfile, io, shutil, re, sys
root=pathlib.Path("assets/generated")
root.mkdir(parents=True,exist_ok=True)
catalog={k:[] for k in ("tree","rock","house","industrial","future","animal","creature","prop")}
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
    data=json.loads(get(f"https://api.github.com/repos/{repo}/git/trees/main?recursive=1"))
    return data["sha"],[x["path"] for x in data["tree"] if x.get("type")=="blob"]
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
      "future":("cyberpunk_pack/",[])}
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
for f in (showcase,kenney,creatures):safe_call(f)
(root/"catalog.json").write_text(json.dumps(catalog))
print("ASSET COUNTS", {k:len(v) for k,v in catalog.items()})
