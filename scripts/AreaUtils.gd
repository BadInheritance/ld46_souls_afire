
static func get_nodes_of_group_in_area(area2d, group_name):
    var areas = area2d.get_overlapping_areas()
    var nodes = []
    for area in areas:
        var parent = area.get_parent()
        if parent.is_in_group(group_name):
            nodes.append(parent)
    return nodes

static func is_group_close(area2d, group_name) -> bool:
    var areas = area2d.get_overlapping_areas()
    for area in areas:
        var parent = area.get_parent()
        if parent.is_in_group(group_name):
            return true
    return false