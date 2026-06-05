#+feature using-stmt
package willow

//

Graph :: struct {
	nodes: [dynamic]^Graph_Node,
	edges: [dynamic][2]^Graph_Node }

Graph_Node :: struct {
	sources: [dynamic]^Graph_Node,
	targets: [dynamic]^Graph_Node }


