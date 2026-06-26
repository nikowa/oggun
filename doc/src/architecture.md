# Architecture

## Top-Level

There are 4 primary layers: **base**, **core**, **app**, and **ext**. Each layer is dependent on the layers below it and independent from the layers above it. The layer **app** is split into **game** and **tool**. You'll most likely use **base** + **core** or **base** + **core** + **app**. The layer **etx** is for optional extensions to any of the components of the layers below it.

- **1. base** --- general procedures and data structured
	- 1.1. *bs*
- **2. core** --- essential engine components
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
- **3. app/game** --- auxiliary components for game development
	- *sn* --- scene
	- *dg* --- dialogue
	- *ec* --- entity component system
	- *fx* --- graphical effects
	- *sm* --- state machine
	- *ai* --- ai
- **3. app/tool** --- auxiliary components for application & tool development
	- *pt* --- plot
	- *ti* --- tools interface
- **4. ext** --- extensions to components from the layers bellow

## State Modes

Families of functions that construct something that is structurally equivalent to an array, a tree, or a graph, can be used in one of three different modes: _immediate mode_, _stack-retained mode_, or _graph-retained mode_.

- **immediate mode** --- params are not stored
- **stack-retained mode** --- params are stored in stacks
- **graph-retained mode** --- params are stored in nodes

Example:

```c
dr_model :: proc { dr_model_im, dr_model_srm, dr_model_grm }

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

// Graph-Retained Mode //
dr_model_grm(node, model_1)
dr_model_grm(node, model_2)
dr_model_grm(node, model_3)
// (Goes up the graph until it finds a camera node or an env node.)
```
