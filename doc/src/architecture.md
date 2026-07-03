# Architecture

## Top-Level

There are 4 primary layers: *base*, *core*, *app*, and *ext*. Each layer is dependent on the layers below it and independent from the layers above it. The layer *app* is split into *game* and *tool*. You'll most likely use *base* + *core* or *base* + *core* + *app*. The layer *ext* is for optional extensions to any of the components of the layers below it.

![top-level](top-level.svg)

- **1. Base** --- general procedures and data structured
	- 1.1. *bs*
- **2. Core** --- essential engine components
	- *wd* --- window
	- *gx* --- graphics
	- *au* --- audio
	- *am* --- asset management
	- *dl* --- dynamic loading
	- *ip* --- input
	- *dr* --- draw
	- *ui* --- user interface
	- *mt* --- meta
	- *ms* --- mesh
	- *px* --- physics
- **3. App/Game** --- auxiliary components for game development
	- *sn* --- scene
	- *dg* --- dialogue
	- *ec* --- entity component system
	- *fx* --- graphical effects
	- *sm* --- state machine
	- *ai* --- ai
- **3. App/Tool** --- auxiliary components for application & tool development
	- *pt* --- plot
	- *ti* --- tools interface
- **4. Ext** --- extensions to components from the layers bellow

## Context Trees

Certain families of objects—eg. entities in a scene, widgets in a GUI, commands in a render graph—naturally form a tree-like structure, where adjacent nodes have a *child*-*parent* relationship, and generally the parent provides some kind of context to the child, such that any procedure that constructs/processes the child requires to know who it's parent is (and who the parent of it's parent is and so on).

![element-hierarchy](element-hierarchy.svg)

Procedures that operate on these object have three variants, each having a distinct way of gathering the needed parameters.

1. **immediate mode (IM)** --- All the parameters are given directly to the procedure, such that you don't have to construct a tree or manage any auxiliary state.
2. **stack-retained mode (SRM)** --- Some of the parameters are gathered from parameter stacks, which represent the chain of nodes from the current object to the root node.
3. **tree-retained mode (TRM)** --- The procedure is given a pointer to a node in an actual tree and it gathers the parameters by walking the tree.

Here's an example with `dr_model`:

```c
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

## Asset Manager

![asset-manager](asset-manager.svg)

`Asset` is a generic class for managing things like images, sounds, models, levels, etc. It provides a standard interface for importing from and exporting to standard exchange formats, saving to and loading from the database, reading from and writing to disk, and downloading from and uploading to the GPU.

All asset operatins happen through a single asset command procedure which is mapped to the derived asset type when the asset is registered with the asset manager.

It can query where an asset is represented and when each representation was last modified. It can also automate transports from one location to another, which can be used for live-reloading of assets. This is demonstrated in the [watcher example](examples.html#watcher).

<pre>
























</pre>
