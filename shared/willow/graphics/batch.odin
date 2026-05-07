package graphics

Batch_Manager :: struct($Batch: typeid, $Params: typeid) {
	batch_groups: [dynamic]Batch_Group(Batch, Params),
	last_params_hash: u64 }

hash_params :: proc(params: $Params) -> u32 {
}

Batch_Group :: struct($Batch: typeid, $Params: typeid) {
	batches: [dynamic]Batch,
	params: Params }

batch_manager_get_group :: proc(batch_man: Batch_Manager($Batch, $Params), params: Params) -> ^Batch_Group(Batch, Params) {
	if hash_params(params) != batch_man.last_params_hash {
		append(&batch_man.batch_groups, Batch_Group(Batch, Params){})
		batch_man.last_params_hash = hash_params(params) }
	return &batch_man.batch_groups[len(batch_man.batch_groups) - 1] }
