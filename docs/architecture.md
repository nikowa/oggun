# Architecture

## Modules Diagram

There are 3 primary layers: Base, Core, and App. Each depends on the layers below it. The App layer is split into Game and Tool. Each layer can be extended by an Ext layer without changing the behavior of the other layers below it.

```mermaid
---
config:
	flowchart:
		nodeSpacing: 5
		rankSpacing: 5
		subGraphTitleMargin: { "top": 0, "bottom": 15 }
		padding: 8
---
flowchart TD
	subgraph Base
	bs
	end
	subgraph Core
	direction TD
	wd
	gx
	au
	am
	dl
	ip
	dr
	ui
	mt
	ms
	px
	end
	subgraph Game["App/Game"]
	direction TD
	sn
	dg
	ec
	fx
	sm
	ai
	end
	subgraph Tool["App/Tool"]
	direction TD
	pt
	ti
	end
	subgraph BaseExt[Base-Ext]
	direction TD
	baseext["..."]
	end
	subgraph CoreExt[Core-Ext]
	direction TD
	coreext["..."]
	end
	subgraph GameExt[Game-Ext]
	direction TD
	gameext["..."]
	end
	subgraph ToolExt[Tool-Ext]
	direction TD
	toolext["..."]
	end
	style Base fill:none
	style Core fill:none
	style Game fill:none
	style Tool fill:none
	style BaseExt fill:none
	style CoreExt fill:none
	style GameExt fill:none
	style ToolExt fill:none
	Base ----- Core
	Base ----- BaseExt
	Core ----- Game
	Core ----- Tool
	Core ----- CoreExt
	Game ----- GameExt
	Tool ----- ToolExt
```

## Modules Listing

### Base

- [x] **bs** — General purpose DSA.

### Core

- [x] **wd** — Window system.
- [x] **gx** — Graphics system.
- [ ] **au** — Audio system.
- [ ] **am** — Asset management.
- [x] **dl** — Dynamic loading.
- [ ] **ip** — Input system.
- [x] **dr** — Drawing commands.
- [x] **ui** — User interface.
- [x] **mt** — Meta.
- [ ] **ms** — Mesh processing.
- [ ] **px** — Physics system.

### App/Game

Auxiliary components for game development

- [x] **sn** — Scene.
- [ ] **dg** — Dialogue system.
- [ ] **ec** — ECS.
- [ ] **fx** — VFX system.
- [ ] **sm** — State machine.
- [ ] **ai** — Game AI.

### App/Tool

Auxiliary components for application & tool development

- [x] **pt** — Plotting utils.
- [ ] **ti** — Tools UI.

## Compilation Process


```mermaid
---
config:
	flowchart:
		nodeSpacing: 5
		rankSpacing: 24
		subGraphTitleMargin: { "top": 0, "bottom": 15 }
		padding: 8
---
flowchart LR
	OggunSource ----> OggunExe
	GameSource ----> GameExe
	Odin ----> OggunExe
	OggunExe ----> GeneratedOggunSource
	GeneratedOggunSource ----> GameExe
	OggunExe ----> GameExe
	Odin@{ shape: stadium, label: "odin.exe" }
	OggunSource@{ shape: stadium, label: "oggun source" }
	GeneratedOggunSource@{ shape: stadium, label: "generated source" }
	GameSource@{ shape: stadium, label: "game source" }
	GameExe@{ shape: stadium, label: "game.exe" }
	OggunExe@{ shape: stadium, label: "oggun.exe" }
```

Some optional features of oggun require preprocessing of your package and generating source code. In that case, you have to compile your package using `oggun.exe`.

```txt
odin run <oggun-path> -- <package-path> [build-args]
```

```txt
oggun build <package-path> [build-args]
```

## Asset Flowchart

```mermaid
---
config:
	flowchart:
		nodeSpacing: 5
		rankSpacing: 80
		subGraphTitleMargin: { "top": 0, "bottom": 15 }
		padding: 8
---
flowchart LR
	GPU -- download --> Memory
	Memory -- upload --> GPU
	Memory -- serialize --> Database
	Database -- deserialize --> Memory
	Source -- import --> Memory
	Memory -- export --> Source
	Database -- write --> Storage
	Storage -- read --> Database
	GPU@{ shape: notch-rect }
	Memory@{ shape: das }
	Database@{ shape: das }
	Source@{ shape: cyl }
	Storage@{ shape: cyl }
```

`Asset` is a generic class for managing things like images, sounds, models, levels, etc. The purpose of this is to (1) simplify the creation of new types of assets, and (2) allow heterogenous assets to be managed in bulk. The hot-reloading system makes use of this feature.

```odin
Asset_Command_Proc :: #type proc(
	asset: ^Asset,
	op: Asset_Op,
	dest: Asset_Location,
	src: Asset_Location,
	watch: bool = false) -> (ok: bool)
```

```odin
Asset_Op :: enum {
	Make,
	Delete,
	Initialize,
	Exists,
	Translate,
	Outdated }
```

## Tree Construction Modes

Several problems in game development involve the walking of some kind of virtual or concrete tree—eg. scenes, GUIs, render graphs, etc. Concrete trees are generally more vertsatile, but they add friction. Procedures that operate on trees have three modes of calling.

1. **immediate mode (IM)** --- The walker sees only the current node. All parameters are given directly to the procedure.
2. **stack-retained mode (SRM)** --- The walker sees only the currently ancestry chain. Some parameters are gathered from parameter stacks.
3. **tree-retained mode (TRM)** --- The walker sees the whole tree. The node is passed as a parameter.

Here's an example with `dr_model`:

```odin
dr_model :: proc { dr_model_im, dr_model_srm, dr_model_trm }

// Immediate Mode //
dr_model_im(env, cam, model_1)
dr_model_im(env, cam, model_2)
dr_model_im(env, cam, model_3)

// Stack-Retained Mode //
push_env(env)
push_cam(cam)
dr_model_srm(model_1)
dr_model_srm(model_2)
dr_model_srm(model_3)

// Tree-Retained Mode //
dr_model_trm(node, model_1)
dr_model_trm(node, model_2)
dr_model_trm(node, model_3)
// (Goes up the graph until it finds a camera node or an env node.)
```

<pre>
























</pre>
