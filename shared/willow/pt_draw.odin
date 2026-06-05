#+feature using-stmt
package willow

Graph_Viz :: struct {
	font_group: ^Font_Group,
	text_style: ^Text_Style,
	font_size: f32 }

Graph_Node_Viz :: struct {
	background_color: Color,
	class: string, // Nodes of the same class can be clustered together or given the same color. //
	outline_color: Color,
	size: Maybe([2]f32), // If size is not specified, it's calculated to fit the contents. //
	text_color: Color,

}
