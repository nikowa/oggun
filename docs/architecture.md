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
	GeneratedOggunSource@{ shape: stadium, label: "generated oggun source" }
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

`Asset` is a generic class for managing things like images, sounds, models, levels, etc. The purpose of this is to (1) simplify the creation of new types of assets, and (2) allow assets of various kinds to be grouped together such that common operations can be performed on said groups.

## Context Trees

Certain families of objects—eg. entities in a scene, widgets in a GUI, commands in a render graph—naturally form a tree-like structure, where adjacent nodes have a *child*-*parent* relationship, and generally the parent provides some kind of context to the child, such that any procedure that constructs/processes the child requires to know who it's parent is (and who the parent of it's parent is and so on).

Procedures that operate on these object have three variants, each having a distinct way of gathering the needed parameters.

1. **immediate mode (IM)** --- All the parameters are given directly to the procedure, such that you don't have to construct a tree or manage any auxiliary state.
2. **stack-retained mode (SRM)** --- Some of the parameters are gathered from parameter stacks, which represent the chain of nodes from the current object to the root node.
3. **tree-retained mode (TRM)** --- The procedure is given a pointer to a node in an actual tree and it gathers the parameters by walking the tree.

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
