#+feature using-stmt
package oggun
import "base:runtime"

DAG :: struct($T: typeid) {
	nodes: [dynamic]DAG_Node(T) }

DAG_Node :: struct($T: typeid) {
	value: T,
	parents: []^DAG_Node(T) }

dag_init :: proc(dag: ^DAG($T)) {
	dag.nodes = make([dynamic]DAG_Node(T)) }

dag_add_node :: proc(dag: ^DAG($T), node: DAG_Node(T)) {
	append(&dag.nodes, node) }
