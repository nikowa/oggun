#+feature using-stmt
package bary
import "core:fmt"

Bary :: [3]f32

bary_from_point :: proc { bary_from_point2 }

bary_from_point2 :: proc(point: [2]f32, triangle: [3][2]f32) -> (bary: Bary) {
	det: = (triangle[1][1] - triangle[2][1]) * (triangle[0][0] - triangle[2][0]) + (triangle[2][0] - triangle[1][0]) * (triangle[0][1] - triangle[2][1])
	bary[0] = ((triangle[1][1] - triangle[2][1]) * (point[0] - triangle[2][0]) + (triangle[2][0] - triangle[1][0]) * (point[1] - triangle[2][1])) / det
	bary[1] = ((triangle[2][1] - triangle[0][1]) * (point[0] - triangle[2][0]) + (triangle[0][0] - triangle[2][0]) * (point[1] - triangle[2][1])) / det
	bary[2] = 1 - bary[0] - bary[1]
	// if bary_inside(bary) do fmt.println(point, triangle, bary)
	return }

bary_to_point :: proc { bary_to_point2, bary_to_point3 }

bary_to_point2 :: proc(bary: Bary, triangle: [3][2]f32) -> (point: [2]f32) {
	return bary[X] * triangle[X] + bary[Y] * triangle[Y] + bary[Z] * triangle[Z] }

bary_to_point3 :: proc(bary: Bary, triangle: [3][3]f32) -> (point: [3]f32) {
	return bary[X] * triangle[X] + bary[Y] * triangle[Y] + bary[Z] * triangle[Z] }
	// o := (triangle[0] + triangle[1] + triangle[2]) / 3
	// oa := triangle[0] - o
	// ob := triangle[1] - o
	// oc := triangle[2] - o
	// return o + bary[0] * oa + bary[1] * ob + bary[2] * oc }

bary_inside :: proc(bary: Bary) -> bool {
	return in_range(bary[X], 0, 1) && in_range(bary[Y], 0, 1) && in_range(bary[Z], 0, 1) }

point_inside_triangle :: proc { point2_inside_triangle }

point2_inside_triangle :: proc(point: [2]f32, triangle: [3][2]f32) -> bool {
	return bary_inside(bary_from_point(point, triangle)) }
