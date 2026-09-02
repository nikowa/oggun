# bs/vtree

## **Overview**

**VTree** is a generic virtual tree — an abstraction that presents itself as a whole tree while it is actually only a subtree of said tree. Virtualization works like this: each **VNode** is associated with a **VEnvelope**, an artifact which represents the enveloping structure of the node, and each node can only see the artifact; it cannot see the the whole **VTree**.

## **Types**

### **VTree**

```odin
VTree :: struct {
	... }
```

### **VNode_Context**

```odin
VEnvelope :: struct {
	... }
```

<div style="height: 100vh;"></div>
