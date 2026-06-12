#!mainFile "soldier_x.opy"

#--- Bot-only defineMember (variable[300-318]) ---
#!defineMember bot_prev_dist variable[300]
#!defineMember bot_navigate_start_pos variable[301]
#!defineMember bot_timeout_end variable[302]
#!defineMember prev_dest_node_ground_pos variable[303]
#!defineMember current_dest_node_ground_pos variable[304]
#!defineMember bot_off_network variable[305]
#!defineMember nearest_nodes_when_timed_out variable[306]
#!defineMember edge_lookup_result variable[307]
#!defineMember recovery_raycast_hit variable[308]
#!defineMember current_pathfinder_node variable[309]
#!defineMember idle_bots_at_destination variable[310]
#!defineMember melee_progress_distance variable[311]
#!defineMember potion_earliest_expiry variable[312]
#!defineMember bot_search_destination variable[313]
#!defineMember bot_was_shot variable[314]
#!defineMember bot_combat_awareness_start variable[315]
#!defineMember bot_using_teleport variable[316]
#!defineMember debug_no_path_found variable[317]
#!defineMember debug_astar_timed_out variable[318]

#--- Bot-only global defineMember (global_variable[50-51]) ---
#!defineMember decompress_buffer global_variable[50]
#!defineMember map_dest_nodes global_variable[51]

# ============================================================
# BOT SYSTEM v2 — Custom navigation + combat for Soldier X
# Node data from dropthatbeat's editor (YYVNG)
# A* with Deltin-style parallel arrays (.append() only)
# Y-encoding for node index extraction
# ============================================================


# ============================================================
# MACROS — all tweakable values in one place
# ============================================================

#--- Navigation ---
macro BOT_PATROL_SPEED = 1
macro BOT_TURN_SPEED = 100
macro NODE_ARRIVAL_OUTER_RADIUS = 1.5     # intermediate node arrival (pass-through)
macro NODE_ARRIVAL_INNER_RADIUS = 0.4         # final destination arrival (walk to center)
macro BOT_NODE_ARRIVE_VERTICAL = 1.5
macro BOT_PAUSE_MIN = 1.5             # minimum pause — enough time for bot to turn toward next path
macro BOT_PAUSE_MAX = 10               # pause after trivially short walks
macro BOT_PAUSE_SCALE = 0.2           # each second of travel reduces pause by this much
macro BOT_RESPAWN_WAIT = 1

#--- Strafe avoidance (reactive) ---
macro BOT_STRAFE_AMOUNT = 1         # rightward offset strength when blocked
macro BOT_STRAFE_CHECK_INTERVAL = 0.25 # full cycle time for all bots (min 0.128 — divided by max players, each wait must be >= 0.016)
macro BOT_STRAFE_PROGRESS = 0.3       # minimum distance progress per check to count as "not blocked"
macro BOT_STRAFE_DURATION = 0.5      # seconds to strafe before re-checking

#--- Bot avoidance (waypoint + early arrival) ---
macro BOT_WAYPOINT_OFFSET = 1.5       # distance from prev node toward dest for yellow waypoint

#--- Stuck detection (dynamic timeout per node) ---
macro BOT_EFFECTIVE_SPEED = 4          # conservative m/s at 75% move speed (base 5.5 * 0.75 ≈ 4.1)
macro BOT_STUCK_TIMEOUT_MULT = 1.25    # allow 1.25x expected travel time
macro BOT_STUCK_TIMEOUT_BUFFER = 1     # minimum seconds buffer — don't set too low, bot needs time to turn and start moving

#--- Shadow Step (attribute 2) ---
macro BOT_SHADOW_STEP_HEIGHT_THRESHOLD = 1.55   # if target node is >= this much higher, use elevated aim
macro BOT_SHADOW_STEP_AIM_OFFSET = 2         # meters toward bot in XZ for elevated aim (prevents overshoot)
macro BOT_SHADOW_STEP_AIM_HEIGHT = 1.55        # meters above Node Ground Position for elevated aim (too low = fails, too high = invalid)
macro BOT_SHADOW_STEP_AIM_HEIGHT_FLAT = 0.25   # meters above Node Ground Position for same-level/lower teleport
macro BOT_SHADOW_STEP_AIM_ANGLE = 1            # degrees — bot must face within this angle before teleporting
macro BOT_SHADOW_STEP_MELEE_WAIT = 0.5         # seconds to wait after melee press (attribute 3)

#--- Elevator (attribute 4) ---
macro BOT_ELEVATOR_Y_THRESHOLD = 0.25         # fraction of Y distance between prev and dest node to consider "lifted" (0.5 = halfway)
macro BOT_ELEVATOR_STEP_OFF_DIST = 2.5          # meters from prev node before bot stops walking away during retry

#--- Jump (attribute 1) ---
macro BOT_JUMP_DETECT_DIST = 2               # raycast distance from knee to trigger jump




#--- Recovery (off-network detection) ---
macro BOT_RECOVERY_RAYCAST_COUNT = 3

#--- Combat ---
macro BOT_DETECTION_RANGE = 30
macro BOT_VIEW_ANGLE = 90
macro BOT_COMBAT_REACTION_SCAN = 1
macro BOT_COMBAT_REACTION_SHOT = 0.25
macro BOT_DISENGAGE_RANGE = 40
macro BOT_SEARCH_DURATION = 5
macro BOT_COMBAT_CLOSE_RANGE = 7
macro BOT_COMBAT_TELEPORT_RANGE = 35

#--- Node index extraction from Y coordinate ---
macro nodeIndexFromPos(pos):
    floor(abs(pos.y) * 1000 % 1000)


# ============================================================
# ENUMS
# ============================================================

enum BotState:
    IDLE,
    NAVIGATE,
    COMBAT,
    SEARCHING,
    DEAD


# ============================================================
# GLOBAL VARIABLES
# ============================================================

macro BOT_PATHFINDER_BUDGET_THRESHOLD = 100

#--- Map data (single-file) ---
globalvar map_neighbors = []
globalvar i
globalvar j
globalvar strafe_bots = []
globalvar strafe_index
globalvar scan_visible_players = []


# ============================================================
# PLAYER VARIABLES
# ============================================================

#--- Reaper init ---
playervar reaper_has_respawned_once

#--- Bot state ---
playervar bot_state_id = BotState.DEAD
playervar bot_face_target

#--- Navigation ---
playervar pathfinder_source = -1
playervar pathfinder_destination = -1
playervar pathfinder_path = []
playervar pathfinder_path_index = 0

playervar pathfinder_done = false
playervar pathfinder_reconstructing = false
playervar pathfinder_reconstruction_entry = -1
playervar bot_patrol_destination

#--- A* per-bot data (Deltin-style parallel arrays, .append() only) ---
playervar pathfinder_open = []
playervar pathfinder_entry_nodes = []
playervar pathfinder_entry_parents = []
playervar pathfinder_entry_cost = []
playervar pathfinder_visited = []
playervar pathfinder_best_entry = 0
playervar pathfinder_current_node = 0
playervar pathfinder_neighbor_index

#--- Combat (stubbed) ---
playervar bot_combat_target = null




# ============================================================
# SUBROUTINE DECLARATIONS
# ============================================================

subroutine bot_state_machine
subroutine bot_sm_idle
subroutine bot_sm_navigate
subroutine bot_sm_combat
subroutine bot_sm_searching
subroutine bot_compute_path
subroutine bot_astar_step
subroutine bot_path_reconstruct
subroutine bot_strafe_and_scan
subroutine decompressingNumbers
subroutine decompressingVectors


# ============================================================
# SHARED DECOMPRESSOR (LulledLion technique)
# Reuses one decompressor across all maps instead of
# embedding a new one per compressed() call.
# ============================================================

macro compressParam = decompress_buffer

def decompressingNumbers():
    @Name "MAP - - - Decompress Numbers"
    compressParam = decompressNumbers(compressParam)

def decompressingVectors():
    @Name "MAP - - - Decompress Vectors"
    compressParam = decompressVectors(compressParam)

macro compressedNumbers(var, data):
    compressParam = compress(data)
    decompressingNumbers()
    var = compressParam

macro compressedVectors(var, data):
    compressParam = compress(data)
    decompressingVectors()
    var = compressParam


# ============================================================
# MAP DATA — loaded via subroutines called from If_map() in soldier_x.opy
# Uses shared decompressor (LulledLion technique) for element savings.
# Flattened neighbors with -1 separators, reconstructed at game start.
# ============================================================

def map_black_forest():
    @Name "MAP - - - Black Forest"

    #--- Node positions (shared decompressor) ---
    compressedVectors(map_nodes, [vect(-9.63, 16.269, 4.885), vect(-12.333, 15, 35.358), vect(-15.177, 13, 31.024), vect(-6.948, 13, 28.416), vect(-2.602, 11.034, 35.62), vect(0.011, 12.424, 24.334), vect(-19.553, 13.282, 20.914), vect(-13.722, 13, 28.079), vect(4.21, 12.49, 15.289), vect(3.924, 12.534, -5.844), vect(-7.004, 13.064, -18.534), vect(-2.677, 11.043, -25.903), vect(-14.154, 13.064, -19.647), vect(-18.827, 13.343, -11.199), vect(-15.439, 13.064, -21.799), vect(-12.926, 15, -26.219), vect(-5.439, 18, -22.057), vect(-7.255, 18, -18.645), vect(-4.05, 18.066, -16.699), vect(-9.397, 18, -14.959), vect(-15.221, 18, -17.943), vect(27.907, 12.057, -12.716), vect(28.086, 12, -25.761), vect(31.636, 12, -19.629), vect(18.794, 11.31, -13.84), vect(12.92, 17.063, -5.835), vect(15.838, 16.831, -2.333), vect(15.948, 17, 2.201), vect(27.923, 17, -2.964), vect(33.952, 17, -2.577), vect(25.596, 17, -18.061), vect(11.554, 17, 4.966), vect(15.646, 17, 7.987), vect(15.939, 16.834, 11.989), vect(4.779, 17, 1.56), vect(1.399, 17, 4.875), vect(4.923, 17, 8.359), vect(-2.598, 17.818, 5.153), vect(-2.588, 17.765, -3.405), vect(-2.618, 17.759, 13.407), vect(-5.161, 18, 31.667), vect(-6.614, 18, 28.156), vect(-3.671, 18.057, 26.553), vect(-7.38, 18.018, 19.374), vect(-16.684, 18.152, 24.693), vect(-14.99, 18, 27.594), vect(-9.08, 18, 24.408), vect(27.211, 11.869, 26.894), vect(27.808, 12.032, 22.593), vect(34.013, 14, 22.935), vect(33.915, 17, 12.586), vect(27.83, 17, 12.515), vect(17.794, 11.475, 22.786), vect(12.715, 17.709, 15.822), vect(10.895, 10.761, 32.887), vect(34.249, 14, -12.854), vect(10.757, 10.684, -22.348), vect(27.781, 12, 35.611), vect(31.125, 12, 29.418), vect(-5.588, 13.211, -1.489), vect(-7.721, 18.075, -10.108), vect(-16.582, 18.13, -15.326), vect(-5.95, 13.264, 12.368), vect(-5.539, 13.007, 15.9), vect(21.394, 11.219, -7.047), vect(21.512, 11.225, 17.199), vect(-22.168, 12.441, 13.35), vect(-23.145, 12.118, 2.321), vect(-4.959, 12.976, -6.889), vect(4.715, 12.232, 5.157), vect(0.318, 12.394, -14.805), vect(9.492, 11.662, 23.727), vect(27.296, 11.835, -16.873), vect(8.997, 11.756, -14.13), vect(25.748, 16.898, 28.109), vect(21.016, 9, 4.978), vect(27.787, 17, -12.868), vect(27.906, 16.955, 23.199)])

    #--- Flattened neighbors (shared decompressor, -1 = node separator) ---
    compressedNumbers(map_flat_neighbors, [66, 67, 37, -1, 2, 40, -1, 7, 1, -1, 4, 7, 5, -1, 3, 54, -1, 8, 3, 63, 39, 42, 71, 54, -1, 7, 63, 66, 44, -1, 3, 2, 6, -1, 5, 63, 65, 71, 69, -1, 64, 68, 70, 73, 69, -1, 12, 11, 70, -1, 10, 56, -1, 13, 14, 10, -1, 12, 67, 68, 61, -1, 12, 15, -1, 14, 16, -1, 15, 17, -1, 16, 19, 18, -1, 17, 60, 70, -1, 17, 20, -1, 19, 61, -1, 55, 64, 72, -1, 23, 56, -1, 22, 72, -1, 25, 56, 64, 30, 72, 73, -1, 26, 24, 9, -1, 27, 25, 28, 64, -1, 31, 26, -1, 29, 26, 76, -1, 28, 55, -1, 24, 76, -1, 32, 36, 34, 27, -1, 33, 31, -1, 51, 53, 32, 65, -1, 35, 31, -1, 36, 37, 34, 69, -1, 31, 35, -1, 35, 39, 38, 43, 60, 0, -1, 37, 68, 70, -1, 37, 63, 5, -1, 1, 41, -1, 40, 46, 42, -1, 43, 41, 5, -1, 44, 42, 37, 63, -1, 45, 43, 6, -1, 46, 44, -1, 41, 45, -1, 58, 52, 48, -1, 47, 49, 65, -1, 48, 50, -1, 49, 51, -1, 50, 33, 77, -1, 54, 47, 53, 65, 71, 74, -1, 33, 52, 8, -1, 52, 57, 4, 5, -1, 29, 21, -1, 24, 22, 11, 70, -1, 58, 54, -1, 57, 47, -1, 62, 68, 69, -1, 18, 61, 68, 37, -1, 20, 60, 13, -1, 63, 59, 69, -1, 6, 5, 62, 8, -1, 9, 24, 21, 75, -1, 52, 8, 48, 75, -1, 0, 6, 67, -1, 13, 0, 66, -1, 59, 13, 9, 70, -1, 35, 62, 8, 9, 59, -1, 9, 18, 38, 10, 68, 56, 73, -1, 52, 8, 5, -1, 23, 21, 24, -1, 24, 70, 9, -1, 52, 77, -1, 64, 65, -1, 30, 28, -1, 74, 51, -1])

    #--- Attributed edges: [from_node, to_node, attribute] ---
    #--- 0=blocked, 1=jump, 2=Shadow Step, 3=melee, 4=elevator ---
    map_attributes_raw = [[5, 39, 2], [5, 42, 2], [13, 61, 2], [24, 30, 2], [37, 43, 2], [37, 60, 2], [43, 37, 2], [52, 74, 2], [60, 37, 2], [64, 75, 3], [65, 75, 3], [69, 35, 2], [70, 18, 2], [70, 38, 2], [75, 64, 3], [75, 65, 3]]


def map_eichenwalde():
    @Name "MAP - - - Eichenwalde"

    #--- Node positions (shared decompressor) ---
    compressedVectors(map_nodes, [vect(103.303, 12.678, -74.448), vect(103.751, 12.73, -79.357), vect(103.372, 9.623, -89.638), vect(92.832, 12.723, -115.727), vect(71.443, 10.5, -114.061), vect(57.81, 10.723, -114.127), vect(57.696, 10.723, -105.662), vect(53.494, 10.723, -103.589), vect(57.589, 11.073, -87.654), vect(55.92, 10.515, -95.765), vect(46.872, 10.369, -98.533), vect(33.952, 10.053, -93.923), vect(38.825, 7.837, -84.905), vect(32.134, 8, -82.265), vect(34.956, 6.024, -74.14), vect(44.32, 6.127, -74.972), vect(40.157, 5.202, -59.199), vect(35.016, 5.25, -57.076), vect(38.654, 5.25, -48.255), vect(43.824, 5.237, -50.277), vect(58.513, 11.702, -59.364), vect(56.925, 11.723, -67.452), vect(55.845, 11.723, -77.353), vect(49.759, 11.493, -75.758), vect(47.274, 11.622, -84.729), vect(56.484, 11.723, -71.65), vect(65.367, 12.723, -73.906), vect(68.006, 12.723, -70.258), vect(72.166, 12.66, -71.387), vect(75.217, 12.66, -67.914), vect(84.129, 12.637, -70.52), vect(76.719, 12.71, -95.623), vect(75.772, 10.684, -109.383), vect(54.298, 6.723, -105.254), vect(58.806, 6.723, -74.631), vect(55.166, 6.723, -67.931), vect(59.05, 4.723, -84.606), vect(67.484, 4.736, -82.874), vect(70.536, 13.345, -77.695), vect(79.12, 12.724, -87.139), vect(69.135, 12.665, -92.385), vect(64.009, 15.797, -61.228), vect(69.258, 15.639, -62.698), vect(66.167, 17.997, -68.431), vect(52.483, 21.206, -65.177), vect(57.604, 18.046, -79.779), vect(52.441, 18.046, -77.904), vect(62.488, 17.511, -85.798), vect(55.964, 17.723, -110.182), vect(39.616, 10.734, -98.892), vect(37.878, 12.723, -105.493), vect(60.653, 18.723, -92.345), vect(49.4, 5.831, -59.007), vect(42.855, 5.347, -55.339), vect(40.96, 4.946, -64.008), vect(48.434, 5.804, -65.934), vect(54.812, 11.511, -87.145), vect(91.201, 12.723, -108.145), vect(94.842, 12.723, -110.103), vect(97.718, 12.723, -101.765), vect(90.438, 12.723, -102.854), vect(84.721, 12.688, -88.68), vect(89.179, 12.679, -76.37), vect(67.08, 12.358, -99.335), vect(76.843, 12.718, -101.607), vect(81.353, 12.712, -99.033), vect(60.27, 11.082, -92.242), vect(57.597, 17.723, -103.722), vect(68.638, 12.622, -94.307), vect(58.689, 18.046, -84.421)])

    #--- Flattened neighbors (shared decompressor, -1 = node separator) ---
    compressedNumbers(map_flat_neighbors, [30, 1, -1, 0, 2, 62, -1, 1, 61, 59, -1, 58, 32, -1, 5, 32, -1, 6, 4, -1, 7, 5, -1, 9, 6, -1, 9, 56, 66, -1, 8, 7, 63, 66, 10, -1, 9, 49, -1, 12, 49, -1, 13, 11, 15, -1, 14, 12, -1, 15, 13, -1, 54, 55, 14, 12, -1, 53, 17, 54, -1, 16, 18, -1, 17, 19, -1, 18, 53, 20, -1, 19, 21, 41, -1, 20, 25, -1, 25, 23, 56, -1, 15, 24, 22, -1, 12, 23, 56, -1, 26, 21, 22, -1, 27, 25, 47, -1, 28, 26, 35, -1, 29, 38, 27, -1, 30, 28, 42, -1, 39, 29, 0, 62, -1, 39, 65, 64, 68, -1, 4, 33, 64, 3, -1, 32, 36, 49, -1, 36, 35, -1, 55, 34, 27, -1, 33, 37, 34, -1, 36, 38, 40, 39, -1, 28, 37, -1, 31, 30, 61, 51, -1, 63, -1, 20, 42, -1, 41, 29, 43, -1, 42, 44, 45, -1, 43, 52, -1, 46, 43, 69, -1, 45, 23, -1, 51, 26, 69, -1, 50, 67, -1, 11, 50, 10, 33, -1, 49, 48, -1, 47, 40, 64, 67, -1, 53, 55, -1, 52, 16, 19, -1, 16, 55, 15, 44, -1, 52, 54, 35, 15, -1, 8, 22, 24, -1, 60, 58, -1, 57, 3, 59, -1, 58, 2, 60, -1, 65, 57, 59, -1, 62, 2, 39, 65, -1, 61, 30, 1, -1, 9, 40, 64, -1, 32, 63, 65, 31, 51, -1, 64, 60, 61, 31, -1, 9, 8, 68, -1, 48, 51, 10, -1, 31, 66, -1, 47, 45, -1])

    #--- Attributed edges: [from_node, to_node, attribute] ---
    #--- 0=blocked, 1=jump, 2=Shadow Step, 3=melee, 4=elevator ---
    map_attributes_raw = [[2, 61, 2], [20, 41, 2], [37, 38, 2], [37, 40, 2], [37, 39, 2], [39, 51, 2], [54, 44, 2], [61, 2, 2], [64, 51, 2]]
def map_hollywood():
    @Name "MAP - - - Hollywood"

    #--- Node positions (shared decompressor) ---
    compressedVectors(map_nodes, [vect(14.227, 1.902, -31.5), vect(14.441, 1.75, -12.24), vect(4.571, 1.75, -5.505), vect(-1.385, 1.604, -8.573), vect(18.712, 1.625, -24.388), vect(13.009, 1.61, -20.908), vect(-4.254, 1.604, -18.514), vect(0.134, 1.604, -17.332), vect(-3.81, 1.604, -50.587), vect(-8.453, 1.729, -53.026), vect(-15.71, 3.75, -43.65), vect(-21.375, 5.751, -46.424), vect(-21.596, 5.75, -57.958), vect(-7.172, 1.968, -58.673), vect(-11.609, 1.729, -64.238), vect(-16.302, 5.75, -63.565), vect(-19.946, 5.75, -62.031), vect(-19.394, 1.729, -75.579), vect(-16.341, 1.729, -76.204), vect(-9.595, 1.729, -69.33), vect(-5.012, 1.604, -77.999), vect(-3.209, 1.604, -70.375), vect(5.734, 1.676, -71.706), vect(15.65, 1.604, -82.233), vect(19.435, 1.604, -73.854), vect(25.256, 1.858, -76.141), vect(26.061, 1.858, -80.863), vect(33.189, 1.604, -83.678), vect(30.578, 1.611, -88.28), vect(37.369, 1.604, -72.056), vect(34.923, 1.748, -66.319), vect(35.866, 2.75, -62.679), vect(24.784, 1.604, -65.326), vect(20.832, 1.604, -63.015), vect(27.415, 2.751, -53.534), vect(32.525, 2.75, -54.863), vect(31.894, 2.75, -60.246), vect(42.88, 2.75, -63.421), vect(46.89, 2.753, -59.405), vect(43.303, 2.75, -47.343), vect(38.965, 2.75, -44.676), vect(38.543, 2.75, -32.756), vect(34.335, 1.75, -30.74), vect(24.432, 1.625, -33.404), vect(24.745, 1.625, -39.073), vect(29.645, 2.061, -46.218), vect(23.81, 1.604, -52.785), vect(-4.622, 4, -63.948), vect(10.769, 6.003, -68.367), vect(12.954, 6.003, -61.017), vect(9.715, 6.003, -54.908), vect(1.789, 6.003, -53.098), vect(6.183, 2, -68.719), vect(3.026, 2, -65.005), vect(3.27, 2.025, -62.513), vect(-2.8, 2.024, -55.469), vect(9.512, 2, -58.98), vect(5.265, 2, -59.261), vect(21.67, 1.607, -45.488), vect(0.95, 1.604, -45.713), vect(-0.918, 1.604, -42.128), vect(3.123, 5.754, -32.301), vect(2.552, 5.728, -28.604), vect(4.058, 3.731, -22.684), vect(2.862, 1.75, -37.335), vect(-3.446, 10.01, -59.666), vect(5.174, 11.01, -63.988), vect(6.984, 12.834, -57.809), vect(8.648, 12.835, -38.482), vect(11.547, 10.75, -33.306), vect(2.953, 10.75, -29.389), vect(8.038, 11.01, -68.747), vect(21.997, 6.797, -80.459), vect(25.993, 6.797, -70.726), vect(0.17, 5.75, -34.145), vect(17.84, 1.604, -78.759), vect(9.236, 1.604, -81.369), vect(15.833, 1.604, -55.354), vect(6.584, 1.604, -48.123), vect(36.505, 2.798, -45.459), vect(13.242, 1.748, -25.094), vect(18.106, 1.75, -32.02), vect(8.878, 1.75, -28.075), vect(16.713, 1.75, -30.1), vect(5.504, 10.75, -33.264), vect(-9.95, 1.729, -57.902), vect(10.04, 1.604, -73.084), vect(5.361, 1.75, -35.1), vect(-3.394, 1.604, -36.048), vect(-6.058, 1.604, -30.236), vect(15.416, 1.604, -50.56), vect(11.315, 2.005, -67.485), vect(18.056, 1.604, -69.096), vect(12.26, 6.003, -57.406), vect(31.098, 1.75, -34.223)])

    #--- Flattened neighbors (shared decompressor, -1 = node separator) ---
    compressedNumbers(map_flat_neighbors, [69, 83, -1, 5, 2, -1, 3, 1, -1, 6, 7, 2, -1, 43, 5, 80, -1, 4, 80, 7, 1, -1, 7, 3, 89, -1, 5, 6, 3, -1, 59, 9, 55, -1, 8, 85, 10, -1, 11, 9, -1, 12, 10, -1, 16, 11, -1, 65, 85, -1, 85, 19, -1, 17, 16, 14, -1, 15, 12, -1, 18, 15, -1, 19, 17, 20, -1, 14, 18, 21, -1, 76, 21, 18, -1, 20, 22, 19, -1, 76, 21, 52, 86, -1, 28, 75, 76, -1, 75, 25, 86, 92, -1, 24, 26, -1, 25, 27, -1, 29, 28, 26, -1, 27, 23, -1, 30, 27, 32, -1, 29, 32, 31, -1, 36, 30, 37, -1, 33, 30, 29, 34, -1, 32, 77, 92, -1, 32, 45, 35, -1, 34, 36, 79, 46, -1, 35, 31, -1, 31, 38, -1, 37, 39, -1, 38, 40, -1, 39, 41, 79, -1, 40, 42, -1, 41, 94, -1, 4, 44, 81, 94, -1, 45, 58, 43, 81, -1, 34, 44, -1, 77, 58, 90, 35, -1, 55, 48, -1, 47, 49, 86, -1, 48, 93, -1, 51, 93, -1, 50, 8, -1, 22, 53, -1, 54, 52, -1, 57, 53, 55, -1, 8, 54, 47, -1, 57, 77, -1, 56, 54, -1, 44, 90, 46, -1, 78, 8, 60, -1, 64, 59, 88, -1, 74, 62, -1, 63, 61, -1, 62, 80, -1, 60, 87, 88, -1, 66, 85, -1, 67, 71, 65, -1, 68, 66, -1, 84, 67, 69, -1, 70, 84, 83, -1, 69, 63, 84, -1, 48, 72, 73, 66, -1, 27, 75, 73, -1, 30, 72, 27, -1, 61, 88, -1, 23, 24, -1, 22, 20, 86, 23, -1, 33, 46, 56, 90, -1, 59, 90, -1, 40, 35, -1, 63, 5, 82, 83, 4, -1, 43, 44, 83, -1, 80, 87, -1, 80, 81, 0, -1, 70, 69, 68, -1, 9, 14, 13, -1, 22, 24, 76, -1, 82, 64, -1, 60, 89, 64, -1, 88, 6, -1, 78, 77, 58, 46, -1, 92, -1, 91, 24, 33, -1, 50, 49, 77, -1, 43, 42, -1])

    #--- Attributed edges: [from_node, to_node, attribute] ---
    #--- 0=blocked, 1=jump, 2=Shadow Step, 3=melee, 4=elevator ---
    map_attributes_raw = [[0, 69, 4], [13, 65, 4], [15, 14, 3], [46, 35, 1], [48, 86, 3], [51, 8, 3], [65, 66, 1], [71, 72, 2], [71, 73, 2], [74, 88, 3], [93, 77, 3]]


# ============================================================
# MAP INIT — Y-encoding + neighbor reconstruction
# Runs once at game start after map data is loaded.
# ============================================================

rule "MAP INIT - - - Encode Node Indices Into Y":
    @Condition map_nodes == true

    #--- Rebuild array with .append() (Set At Index is unreliable in Workshop) ---
    #--- Uses map_temp_neighbors as temp to hold original nodes ---
    map_temp_neighbors = map_nodes
    map_nodes = []
    for i in range(len(map_temp_neighbors)):
        map_nodes.append(vect(map_temp_neighbors[i].x, floor(map_temp_neighbors[i].y) + i / 1000, map_temp_neighbors[i].z))
    map_temp_neighbors = null
    map_encoded = true


rule "MAP INIT - - - Reconstruct Neighbors":
    @Condition map_flat_neighbors == true
    @Condition map_encoded == true

    map_neighbors = []
    map_temp_neighbors = []
    for i in range(len(map_flat_neighbors)):
        if map_flat_neighbors[i] == -1:
            map_neighbors.append([map_temp_neighbors])
            map_temp_neighbors = []
        else:
            map_temp_neighbors.append([[map_flat_neighbors[i], []]])

    #--- Apply attributes to specific edges ---
    for i in range(len(map_attributes_raw)):
        for j in range(len(map_neighbors[map_attributes_raw[i][0]])):
            if map_neighbors[map_attributes_raw[i][0]][j][0] == map_attributes_raw[i][1]:
                map_neighbors[map_attributes_raw[i][0]][j] = [map_attributes_raw[i][1], [map_attributes_raw[i][2]]]

    #--- Precompute valid destination nodes (exclude elevator nodes) ---
    map_dest_nodes = []
    for i in range(len(map_nodes)):
        if len([edge for edge in map_neighbors[i] if len(edge[1]) > 0 and edge[1][0] == 4]) == 0:
            map_dest_nodes.append(map_nodes[i])

    #--- Cleanup ---
    map_flat_neighbors = null
    map_attributes_raw = null
    map_ready = true

    #--- Start global strafe avoidance (serialized raycasts across all bots) ---
    async(bot_strafe_and_scan, AsyncBehavior.NOOP)

# ============================================================
# BOT SPAWN / INIT
# ============================================================

rule "GENERAL - - - Add Bots":
    @Condition spawn_bots == true
    @Condition getNumberOfPlayers(Team.ALL) < amount_of_bots_and_players

    createDummy(Hero.REAPER, Team.ALL, -1, dummy_bot_spawn_position, dummy_bot_spawn_facing)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "BOT - - - Init":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true

    eventPlayer.stats = [100, 166.666, 75, 0, 0, 1, 1, 0, 100, 0]
    eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    eventPlayer.reaper_has_respawned_once = false

    #--- Single startFacing with reevaluation — never stopped/restarted ---
    # bot_face_target is updated by navigation (raycast ground + eye height).
    # In combat, faces bot_combat_target body center directly via reevaluation.
    # When very close (< 0.5m) during navigation, faces horizontally to avoid looking at feet.
    eventPlayer.bot_face_target = eventPlayer.getPosition() + eventPlayer.getFacingDirection()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getPosition() + vect(0, eventPlayer.bot_combat_target.stats[Stat.EYE_HEIGHT] / 2, 0) if eventPlayer.bot_state_id == BotState.COMBAT else vect(eventPlayer.bot_face_target.x, eventPlayer.getEyePosition().y if distance(eventPlayer.getPosition(), eventPlayer.bot_face_target) < 0.5 else eventPlayer.bot_face_target.y, eventPlayer.bot_face_target.z)), BOT_TURN_SPEED, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    #--- Single startThrottleInDirection with reevaluation — never stopped/restarted ---
    # In combat, moves toward bot_combat_target. Otherwise, toward bot_patrol_destination.
    # Magnitude controlled by bot_throttle_paused. Strafe offset only during navigation.
    eventPlayer.bot_throttle_paused = true
    eventPlayer.bot_off_network = false
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition() if eventPlayer.bot_state_id == BotState.COMBAT else eventPlayer.bot_patrol_destination) + crossProduct(directionTowards(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination), vect(0, 1, 0)) * eventPlayer.bot_strafe, 0 if eventPlayer.bot_throttle_paused or (eventPlayer.bot_state_id == BotState.COMBAT and distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) <= BOT_COMBAT_CLOSE_RANGE) else BOT_PATROL_SPEED, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)


    eventPlayer.debug_bot_state = "DEAD"

    #--- Wait for first spawn, then respawn to get correct eye height ---
    waitUntil(eventPlayer.hasSpawned() and eventPlayer.isAlive() and spawn_bots, 99999)
    wait(BOT_RESPAWN_WAIT)
    eventPlayer.respawn()
    wait(BOT_RESPAWN_WAIT)
    eventPlayer.stats[Stat.EYE_HEIGHT] = eventPlayer.getEyePosition().y - eventPlayer.getPosition().y
    eventPlayer.reaper_has_respawned_once = true
    eventPlayer.bot_state_id = BotState.IDLE

    #--- Start state machine loop ---
    bot_state_machine()





# ============================================================
# STATE MACHINE
# ============================================================

def bot_state_machine():
    @Name "BOT - - - State Machine"

    while true:
        if not eventPlayer.isAlive() or not spawn_bots:
            wait()
            continue

        if eventPlayer.bot_state_id == BotState.IDLE:
            eventPlayer.debug_bot_state = "IDLE"
            bot_sm_idle()
        elif eventPlayer.bot_state_id == BotState.NAVIGATE:
            eventPlayer.debug_bot_state = "NAVIGATE"
            bot_sm_navigate()
        elif eventPlayer.bot_state_id == BotState.COMBAT:
            bot_sm_combat()
        elif eventPlayer.bot_state_id == BotState.SEARCHING:
            bot_sm_searching()

        wait()


# ============================================================
# STATE: IDLE
# ============================================================

def bot_sm_idle():
    @Name "BOT - - - [STATE] Idle"

    #--- Inverse-distance pause: short walks = long pause, long walks = short pause ---
    #--- Interruptible: external state changes (wake-up) exit immediately ---
    waitUntil(eventPlayer.bot_state_id != BotState.IDLE, max(BOT_PAUSE_MIN, BOT_PAUSE_MAX - (getTotalTimeElapsed() - eventPlayer.bot_prev_dist) * BOT_PAUSE_SCALE))

    if eventPlayer.bot_state_id == BotState.IDLE:
        eventPlayer.bot_state_id = BotState.NAVIGATE


# ============================================================
# STATE: NAVIGATE — find nearest node, pick destination,
#   compute A* path, walk node by node.
# ============================================================

def bot_sm_navigate():
    @Name "BOT - - - [STATE] Navigate"

    #--- Wait for map to be fully loaded + encoded ---
    if not map_ready:
        eventPlayer.bot_state_id = BotState.IDLE
        return

    #--- First navigation or failed path: compute path from scratch ---
    if len(eventPlayer.pathfinder_path) <= 1:
        bot_compute_path()
        if eventPlayer.bot_state_id != BotState.NAVIGATE:
            return

    #--- Walk the path (pre-computed or just computed) ---
    if len(eventPlayer.pathfinder_path) > 1:
        eventPlayer.pathfinder_path_index = len(eventPlayer.pathfinder_path) - 1
        #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
        eventPlayer.debug_bot_state = "NAV: STARTED"
        #--- Stuck detection: if bot hasn't moved > 2m since last walk attempt ---
        if distance(eventPlayer.getPosition(), eventPlayer.bot_navigate_start_pos) < 2 and eventPlayer.bot_navigate_start_pos != 0:
            eventPlayer.debug_bot_stuck = true
        else:
            eventPlayer.debug_bot_stuck = false
        eventPlayer.bot_navigate_start_pos = eventPlayer.getPosition()

        #--- Unpause throttle (started once in Bot Init, never stopped) ---
        eventPlayer.bot_throttle_paused = false


        #--- Track walk start time (used for inverse-distance pause) ---
        eventPlayer.bot_prev_dist = getTotalTimeElapsed()

        #--- Initialize prev ground pos to bot's current position for first node's yellow waypoint ---
        eventPlayer.current_dest_node_ground_pos = eventPlayer.getPosition()

        #--- Walk node by node (attribute-aware) ---
        while eventPlayer.pathfinder_path_index > 0 and eventPlayer.bot_state_id == BotState.NAVIGATE and eventPlayer.isAlive():
            eventPlayer.bot_patrol_destination = map_nodes[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index - 1])]

            #--- Look up edge attribute: current node → next node ---
            eventPlayer.edge_lookup_result = [edge[1] for edge in map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index])] if round(edge[0]) == round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index - 1])]
            eventPlayer.bot_edge_attr = eventPlayer.edge_lookup_result[0][0] if len(eventPlayer.edge_lookup_result) > 0 and len(eventPlayer.edge_lookup_result[0]) > 0 else -1
            #--- Raycast destination ground position once (reused by all attributes) ---
            eventPlayer.prev_dest_node_ground_pos = eventPlayer.current_dest_node_ground_pos
            eventPlayer.current_dest_node_ground_pos = raycast(eventPlayer.bot_patrol_destination + vect(0, 1, 0), eventPlayer.bot_patrol_destination + vect(0, -10, 0), null, null, false).getHitPosition()
            eventPlayer.bot_face_target = eventPlayer.current_dest_node_ground_pos + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)

            #--- Yellow waypoint: 1.5m from prev node toward dest (skip for shadow step + zero vector guard) ---
            if eventPlayer.prev_dest_node_ground_pos != 0 and eventPlayer.bot_edge_attr != 2 \
                and distance(eventPlayer.prev_dest_node_ground_pos, eventPlayer.current_dest_node_ground_pos) > 0.5:
                eventPlayer.bot_patrol_destination = eventPlayer.prev_dest_node_ground_pos + normalize(eventPlayer.current_dest_node_ground_pos - eventPlayer.prev_dest_node_ground_pos) * BOT_WAYPOINT_OFFSET
                waitUntil(\
                    distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                    or eventPlayer.bot_state_id != BotState.NAVIGATE \
                    or eventPlayer.isDead(), 3)
                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return
                #--- Resume walking toward actual destination ---
                eventPlayer.bot_patrol_destination = map_nodes[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index - 1])]
                eventPlayer.bot_face_target = eventPlayer.current_dest_node_ground_pos + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)

            #--- Attribute 1: JUMP ---
            if eventPlayer.bot_edge_attr == 1:
                eventPlayer.bot_throttle_paused = false
                eventPlayer.bot_timeout_end = getTotalTimeElapsed() + distance(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination) / BOT_EFFECTIVE_SPEED * BOT_STUCK_TIMEOUT_MULT + BOT_STUCK_TIMEOUT_BUFFER
                while distance(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination) > 2 \
                    and eventPlayer.bot_state_id == BotState.NAVIGATE and eventPlayer.isAlive() \
                    and getTotalTimeElapsed() < eventPlayer.bot_timeout_end:
                    if distance(eventPlayer.getPosition() + vect(0, 0.5, 0), raycast(eventPlayer.getPosition() + vect(0, 0.5, 0), eventPlayer.getPosition() + vect(0, 0.5, 0) + directionTowards(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination) * BOT_JUMP_DETECT_DIST, null, getAllPlayers(), false).getHitPosition()) < BOT_JUMP_DETECT_DIST \
                        and distance(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination) > 3:
                        eventPlayer.forceButtonPress(Button.JUMP)
                        #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
                        eventPlayer.debug_bot_state = "NAV: JUMP"
                        wait(1)
                    else:
                        wait(0.20)

                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return

            #--- Attribute 2: SHADOW STEP ---
            elif eventPlayer.bot_edge_attr == 2:
                #--- Walk to inner radius of current node first (consistent aim position) ---
                eventPlayer.bot_patrol_destination = eventPlayer.prev_dest_node_ground_pos
                waitUntil(\
                    (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.prev_dest_node_ground_pos * vect(1, 0, 1)) < NODE_ARRIVAL_INNER_RADIUS \
                    and abs(eventPlayer.getPosition().y - eventPlayer.prev_dest_node_ground_pos.y) < BOT_NODE_ARRIVE_VERTICAL) \
                    or eventPlayer.bot_state_id != BotState.NAVIGATE \
                    or eventPlayer.isDead(), 3)
                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return
                eventPlayer.bot_patrol_destination = map_nodes[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index - 1])]
                eventPlayer.bot_throttle_paused = true

                if eventPlayer.current_dest_node_ground_pos.y - eventPlayer.getPosition().y >= BOT_SHADOW_STEP_HEIGHT_THRESHOLD:
                    eventPlayer.bot_face_target = eventPlayer.current_dest_node_ground_pos + vect(0, BOT_SHADOW_STEP_AIM_HEIGHT, 0)
                    eventPlayer.bot_face_target = eventPlayer.bot_face_target + normalize(directionTowards(eventPlayer.bot_face_target, eventPlayer.getEyePosition()) * vect(1, 0, 1)) * BOT_SHADOW_STEP_AIM_OFFSET
                else:
                    eventPlayer.bot_face_target = eventPlayer.current_dest_node_ground_pos + vect(0, BOT_SHADOW_STEP_AIM_HEIGHT_FLAT, 0)

                waitUntil(\
                    angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), eventPlayer.bot_face_target)) < BOT_SHADOW_STEP_AIM_ANGLE \
                    or eventPlayer.bot_state_id != BotState.NAVIGATE \
                    or eventPlayer.isDead(), 2)

                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = false
                    return

                #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
                eventPlayer.debug_bot_state = "NAV: TELEPORT"
                eventPlayer.forceButtonPress(Button.ABILITY_2)
                wait()
                eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)

                #--- Wait for shadow step animation to complete ---
                waitUntil(\
                    eventPlayer.bot_state_id != BotState.NAVIGATE \
                    or eventPlayer.isDead(), 1.5)

                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = false
                    return

                #--- Teleport landed — walk to node regardless of landing distance ---
                eventPlayer.bot_throttle_paused = false
                eventPlayer.bot_face_target = eventPlayer.current_dest_node_ground_pos + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)
                waitUntil(\
                    (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                    and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL) \
                    or eventPlayer.bot_state_id != BotState.NAVIGATE \
                    or eventPlayer.isDead(), 3)

                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return

                #--- Check if arrived — if not, abort path and re-plan ---
                if distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                    and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL:
                    eventPlayer.pathfinder_path_index -= 1
                else:
                    eventPlayer.debug_bot_state = "NAV: TIMED OUT"
                    eventPlayer.bot_throttle_paused = true
                    eventPlayer.bot_off_network = true
                    eventPlayer.pathfinder_path = []
                    eventPlayer.bot_state_id = BotState.IDLE
                    return


                continue

            #--- Attribute 3: MELEE WHEN BLOCKED ---
            elif eventPlayer.bot_edge_attr == 3:
                eventPlayer.bot_throttle_paused = false
                while not (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                    and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL) \
                    and eventPlayer.bot_state_id == BotState.NAVIGATE and eventPlayer.isAlive():
                    eventPlayer.melee_progress_distance = distance(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination)
                    wait(1)
                    if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                        break
                    if not (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                        and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL) \
                        and distance(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination) > eventPlayer.melee_progress_distance - 0.5:
                        #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
                        eventPlayer.debug_bot_state = "NAV: MELEE"
                        eventPlayer.forceButtonPress(Button.MELEE)
                        wait(BOT_SHADOW_STEP_MELEE_WAIT)
                        break

                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return

            #--- Attribute 4: ELEVATOR ---
            elif eventPlayer.bot_edge_attr == 4:
                #--- Walk to inner radius of bottom node first (bot arrived at outer radius) ---
                eventPlayer.bot_patrol_destination = eventPlayer.prev_dest_node_ground_pos
                waitUntil(\
                    (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.prev_dest_node_ground_pos * vect(1, 0, 1)) < NODE_ARRIVAL_INNER_RADIUS \
                    and abs(eventPlayer.getPosition().y - eventPlayer.prev_dest_node_ground_pos.y) < BOT_NODE_ARRIVE_VERTICAL) \
                    or eventPlayer.bot_state_id != BotState.NAVIGATE \
                    or eventPlayer.isDead(), 3)
                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return
                #--- On platform — restore destination to top node and pause ---
                eventPlayer.bot_patrol_destination = map_nodes[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index - 1])]
                eventPlayer.bot_throttle_paused = true

                while eventPlayer.bot_state_id == BotState.NAVIGATE and eventPlayer.isAlive():
                    #--- Wait for elevator to lift bot past Y threshold ---
                    waitUntil(\
                        abs(eventPlayer.getPosition().y - eventPlayer.current_dest_node_ground_pos.y) <= abs(eventPlayer.prev_dest_node_ground_pos.y - eventPlayer.current_dest_node_ground_pos.y) * BOT_ELEVATOR_Y_THRESHOLD \
                        or eventPlayer.bot_state_id != BotState.NAVIGATE \
                        or eventPlayer.isDead(), 3)

                    if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                        break

                    #--- Not lifted in time — step off platform, walk back onto it ---
                    if abs(eventPlayer.getPosition().y - eventPlayer.current_dest_node_ground_pos.y) > abs(eventPlayer.prev_dest_node_ground_pos.y - eventPlayer.current_dest_node_ground_pos.y) * BOT_ELEVATOR_Y_THRESHOLD:
                        eventPlayer.bot_throttle_paused = false
                        eventPlayer.bot_patrol_destination = eventPlayer.getPosition() + directionTowards(\
                            eventPlayer.current_dest_node_ground_pos * vect(1, 0, 1), \
                            eventPlayer.getPosition() * vect(1, 0, 1)) * 5
                        waitUntil(\
                            distance(eventPlayer.getPosition(), eventPlayer.prev_dest_node_ground_pos) >= BOT_ELEVATOR_STEP_OFF_DIST \
                            or eventPlayer.bot_state_id != BotState.NAVIGATE \
                            or eventPlayer.isDead(), 3)
                        eventPlayer.bot_patrol_destination = eventPlayer.prev_dest_node_ground_pos
                        waitUntil(\
                            (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.prev_dest_node_ground_pos * vect(1, 0, 1)) < NODE_ARRIVAL_INNER_RADIUS \
                            and abs(eventPlayer.getPosition().y - eventPlayer.prev_dest_node_ground_pos.y) < BOT_NODE_ARRIVE_VERTICAL) \
                            or eventPlayer.bot_state_id != BotState.NAVIGATE \
                            or eventPlayer.isDead(), 3)
                        eventPlayer.bot_patrol_destination = map_nodes[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index - 1])]
                        eventPlayer.bot_throttle_paused = true
                        continue

                    #--- Lifted — walk off platform, verify bot stayed up ---
                    eventPlayer.bot_throttle_paused = false
                    waitUntil(\
                        (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                        and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL) \
                        or abs(eventPlayer.getPosition().y - eventPlayer.current_dest_node_ground_pos.y) > abs(eventPlayer.prev_dest_node_ground_pos.y - eventPlayer.current_dest_node_ground_pos.y) * BOT_ELEVATOR_Y_THRESHOLD \
                        or eventPlayer.bot_state_id != BotState.NAVIGATE \
                        or eventPlayer.isDead(), 3)

                    #--- Arrived at destination node ---
                    if distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                        and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL:
                        break
                    #--- Y dropped back — retry elevator ---
                    elif abs(eventPlayer.getPosition().y - eventPlayer.current_dest_node_ground_pos.y) > abs(eventPlayer.prev_dest_node_ground_pos.y - eventPlayer.current_dest_node_ground_pos.y) * BOT_ELEVATOR_Y_THRESHOLD:
                        eventPlayer.bot_throttle_paused = true
                        continue
                    #--- Interrupted or timeout — exit ---
                    else:
                        break

                eventPlayer.bot_throttle_paused = false

                if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                    eventPlayer.bot_throttle_paused = true
                    return

                #--- Elevator arrived — skip shared arrival (same as shadow step) ---
                eventPlayer.pathfinder_path_index -= 1
                continue

            #--- Normal walk (no attribute) ---
            else:
                eventPlayer.bot_throttle_paused = false

            #--- Wait for arrival ---
            eventPlayer.bot_timeout_end = getTotalTimeElapsed() + distance(eventPlayer.getPosition(), eventPlayer.bot_patrol_destination) / BOT_EFFECTIVE_SPEED * BOT_STUCK_TIMEOUT_MULT + BOT_STUCK_TIMEOUT_BUFFER
            waitUntil(\
                (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL) \
                or eventPlayer.bot_state_id != BotState.NAVIGATE \
                or eventPlayer.isDead(), \
                eventPlayer.bot_timeout_end - getTotalTimeElapsed())
            eventPlayer.bot_timeout_end = 0

            if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
                eventPlayer.bot_throttle_paused = true
                return
                
            #--- Check if arrived (outer radius) ---
            if distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_OUTER_RADIUS \
                and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL:
                #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
                eventPlayer.debug_bot_state = "NAV: THROUGH"
                eventPlayer.pathfinder_path_index -= 1

                #--- Clear attribute 3 after door break (forward + reverse edge) ---
                if eventPlayer.bot_edge_attr == 3:
                    #--- Clear forward: from_node → to_node ---
                    for i in range(len(map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index + 1])])):
                        if round(map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index + 1])][i][0]) == round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index]):
                            map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index + 1])][i] = [round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index]), []]
                    #--- Clear reverse: to_node → from_node ---
                    for i in range(len(map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index])])):
                        if round(map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index])][i][0]) == round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index + 1]):
                            map_neighbors[round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index])][i] = [round(eventPlayer.pathfinder_path[eventPlayer.pathfinder_path_index + 1]), []]
            else:
                #--- Timed out (stuck): clear path and re-plan ---
                #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
                eventPlayer.debug_bot_state = "NAV: TIMED OUT"
                eventPlayer.bot_throttle_paused = true
                if not eventPlayer.bot_off_network:
                    debug_bot_walk_fail_pos = eventPlayer.getPosition()
                eventPlayer.bot_off_network = true
                eventPlayer.pathfinder_path = []
                eventPlayer.bot_state_id = BotState.IDLE
                return

        #--- Wake up paused bot at destination before walking to center ---
        eventPlayer.idle_bots_at_destination = sorted([bot for bot in getAllPlayers() if bot.isDummy() and bot != eventPlayer and bot.bot_state_id == BotState.IDLE and distance(bot, eventPlayer.bot_patrol_destination) < NODE_ARRIVAL_OUTER_RADIUS], lambda bot: distance(bot, eventPlayer))
        if len(eventPlayer.idle_bots_at_destination) > 0:
            eventPlayer.idle_bots_at_destination[0].bot_state_id = BotState.NAVIGATE
            #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
            eventPlayer.debug_bot_state = "NAV: POKE"

        #--- Walk to center of final destination (inner radius) ---
        #--- Bot Status Ticker: to disable, comment out with /**/ — do not remove ---
        eventPlayer.debug_bot_state = "NAV: ARRIVED"
        eventPlayer.bot_patrol_destination = map_nodes[round(eventPlayer.pathfinder_path[0])]
        eventPlayer.bot_face_target = eventPlayer.current_dest_node_ground_pos + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)
        waitUntil(\
            (distance(eventPlayer.getPosition() * vect(1, 0, 1), eventPlayer.bot_patrol_destination * vect(1, 0, 1)) < NODE_ARRIVAL_INNER_RADIUS \
            and abs(eventPlayer.getPosition().y - eventPlayer.bot_patrol_destination.y) < BOT_NODE_ARRIVE_VERTICAL) \
            or eventPlayer.bot_state_id != BotState.NAVIGATE \
            or eventPlayer.isDead(), 3)

        eventPlayer.bot_throttle_paused = true
    else:
        eventPlayer.debug_no_path_found = true

    if eventPlayer.bot_state_id != BotState.NAVIGATE or eventPlayer.isDead():
        eventPlayer.bot_state_id = BotState.IDLE
        return

    #--- Pre-compute next path during upcoming pause ---
    bot_compute_path()

    #--- Navigation complete — path is pre-computed for next cycle ---
    eventPlayer.bot_off_network = false
    eventPlayer.bot_strafe = 0
    if eventPlayer.bot_state_id == BotState.NAVIGATE:
        eventPlayer.bot_state_id = BotState.IDLE


# ============================================================
# COMPUTE PATH — find nearest node, pick dest, A*, reconstruct
# Called synchronously from navigate (both first-time and pre-compute).
# On failure, sets state to IDLE.
# ============================================================

def bot_compute_path():
    @Name "BOT - - - Compute Path"

    if eventPlayer.bot_off_network:
        #--- Sort nodes by distance for recovery raycast validation ---
        eventPlayer.nearest_nodes_when_timed_out = sorted(map_nodes, lambda node: distance(eventPlayer.getPosition(), node) + abs(eventPlayer.getPosition().y - node.y) * 5)

        #--- Raycast-validate nearest nodes using ground positions for accuracy ---
        eventPlayer.pathfinder_source = -1
        for i in range(BOT_RECOVERY_RAYCAST_COUNT):
            #--- Get ground position of candidate node (nodes can be ~1m above/below ground) ---
            eventPlayer.current_dest_node_ground_pos = raycast(eventPlayer.nearest_nodes_when_timed_out[i] + vect(0, 1, 0), eventPlayer.nearest_nodes_when_timed_out[i] + vect(0, -10, 0), null, null, false).getHitPosition()
            #--- LOS check: bot eye → node ground + 1m up ---
            eventPlayer.recovery_raycast_hit = raycast(eventPlayer.getEyePosition(), eventPlayer.current_dest_node_ground_pos + vect(0, 1, 0), null, null, false).getHitPosition()
            if distance(eventPlayer.recovery_raycast_hit, eventPlayer.current_dest_node_ground_pos + vect(0, 1, 0)) < 1:
                eventPlayer.pathfinder_source = nodeIndexFromPos(eventPlayer.nearest_nodes_when_timed_out[i])
                eventPlayer.bot_off_network = false
                break

        if eventPlayer.pathfinder_source == -1:
            #--- STEALTH TELEPORT FALLBACK — no reachable node found ---
            eventPlayer.setInvisibility(Invis.ALL)
            playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR, Color.TEAM_1, eventPlayer.getPosition(), 1)
            playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
            eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
            eventPlayer.bot_throttle_paused = true
            eventPlayer.debug_bot_state = "RECOVERY"

            #--- Wait: 1 second per meter, minimum 5 seconds + wait for clear destination ---
            eventPlayer.current_dest_node_ground_pos = raycast(eventPlayer.nearest_nodes_when_timed_out[0] + vect(0, 1, 0), eventPlayer.nearest_nodes_when_timed_out[0] + vect(0, -10, 0), null, null, false).getHitPosition()
            wait(max(5, distance(eventPlayer.getPosition(), eventPlayer.nearest_nodes_when_timed_out[0])))
            waitUntil(len([p for p in getAllPlayers() if p != eventPlayer and distance(p.getPosition(), eventPlayer.current_dest_node_ground_pos) < 1]) == 0, 10)

            #--- Teleport to nearest node ground position ---
            eventPlayer.teleport(eventPlayer.current_dest_node_ground_pos)
            eventPlayer.setInvisibility(Invis.NONE)
            playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_REAPPEAR, Color.TEAM_2, eventPlayer.getPosition(), 1)
            playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_REAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
            eventPlayer.clearStatusEffect(Status.PHASED_OUT)

            eventPlayer.pathfinder_source = nodeIndexFromPos(eventPlayer.nearest_nodes_when_timed_out[0])
            eventPlayer.bot_off_network = false
    else:
        #--- Normal case: use nearest node directly ---
        eventPlayer.pathfinder_source = nodeIndexFromPos(sorted(map_nodes, lambda node: distance(eventPlayer.getPosition(), node) + abs(eventPlayer.getPosition().y - node.y) * 5)[0])

    wait()

    #--- Pick destination (must differ from source) ---
    eventPlayer.pathfinder_destination = nodeIndexFromPos(random.choice([node for node in map_dest_nodes if nodeIndexFromPos(node) != eventPlayer.pathfinder_source]))

    #--- Wait for A* slot (serialized for load control) ---
    waitUntil(pathfinder_owner == null or eventPlayer.bot_state_id != BotState.NAVIGATE, 15)

    if eventPlayer.bot_state_id != BotState.NAVIGATE:
        return
    if pathfinder_owner != null:
        eventPlayer.bot_state_id = BotState.IDLE
        return

    #--- Claim slot ---
    pathfinder_owner = eventPlayer
    wait()
    if pathfinder_owner != eventPlayer:
        eventPlayer.bot_state_id = BotState.IDLE
        return

    #--- Initialize A* ---
    eventPlayer.pathfinder_open = [0]
    eventPlayer.pathfinder_entry_nodes = [eventPlayer.pathfinder_source]
    eventPlayer.pathfinder_entry_parents = [-1]
    eventPlayer.pathfinder_entry_cost = [0]
    eventPlayer.pathfinder_visited = [eventPlayer.pathfinder_source]
    eventPlayer.pathfinder_done = false
    async(bot_astar_step, AsyncBehavior.NOOP)

    #--- Wait for A* to finish ---
    waitUntil(eventPlayer.pathfinder_done == true or eventPlayer.bot_state_id != BotState.NAVIGATE, 5)

    if eventPlayer.bot_state_id != BotState.NAVIGATE:
        pathfinder_owner = null
        return

    if eventPlayer.pathfinder_done == false:
        eventPlayer.debug_astar_timed_out = true
        pathfinder_owner = null
        eventPlayer.bot_state_id = BotState.IDLE
        return

    #--- Reconstruct path ---
    eventPlayer.pathfinder_path = []
    eventPlayer.pathfinder_reconstruction_entry = eventPlayer.pathfinder_entry_nodes.index(eventPlayer.pathfinder_destination)
    eventPlayer.pathfinder_reconstructing = true
    async(bot_path_reconstruct, AsyncBehavior.NOOP)
    waitUntil(eventPlayer.pathfinder_reconstructing == false or eventPlayer.bot_state_id != BotState.NAVIGATE, 5)

    pathfinder_owner = null

    #--- Start turning toward first node while still paused ---
    if len(eventPlayer.pathfinder_path) > 1:
        eventPlayer.bot_face_target = map_nodes[round(eventPlayer.pathfinder_path[len(eventPlayer.pathfinder_path) - 2])] + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)


# ============================================================
# A* STEP — async subroutine, started via async() from navigate
# Uses player variables (each bot has own data).
# Serialized via pathfinder_owner (load control).
# ============================================================

def bot_astar_step():
    @Name "BOT - - - A* Step"

    while not eventPlayer.pathfinder_done and eventPlayer.bot_state_id == BotState.NAVIGATE:
        #--- Calculate budget for this tick (1 = compute, 0 = pause) ---
        pathfinder_budget = 1 if max(getAverageServerLoad(), getServerLoad()) < BOT_PATHFINDER_BUDGET_THRESHOLD else 0

        #--- Expand up to budget nodes this tick ---
        while pathfinder_budget > 0:
            #--- No nodes left: no path ---
            if len(eventPlayer.pathfinder_open) == 0:
                eventPlayer.pathfinder_done = true
                return

            #--- Find open entry with lowest f = g + h ---
            eventPlayer.pathfinder_best_entry = eventPlayer.pathfinder_open[0]
            for i in range(1, len(eventPlayer.pathfinder_open), 1):
                eventPlayer.current_pathfinder_node = eventPlayer.pathfinder_open[i]
                if eventPlayer.pathfinder_entry_cost[eventPlayer.current_pathfinder_node] + distance(map_nodes[eventPlayer.pathfinder_entry_nodes[eventPlayer.current_pathfinder_node]], map_nodes[eventPlayer.pathfinder_destination]) < eventPlayer.pathfinder_entry_cost[eventPlayer.pathfinder_best_entry] + distance(map_nodes[eventPlayer.pathfinder_entry_nodes[eventPlayer.pathfinder_best_entry]], map_nodes[eventPlayer.pathfinder_destination]):
                    eventPlayer.pathfinder_best_entry = eventPlayer.current_pathfinder_node

            eventPlayer.pathfinder_current_node = round(eventPlayer.pathfinder_entry_nodes[eventPlayer.pathfinder_best_entry])
            eventPlayer.pathfinder_open.remove(eventPlayer.pathfinder_best_entry)

            #--- Destination reached ---
            if abs(eventPlayer.pathfinder_current_node - eventPlayer.pathfinder_destination) < 0.5:
                eventPlayer.pathfinder_done = true
                return

            #--- Expand neighbors (yield after each, like Deltin's pfTick) ---
            for eventPlayer.pathfinder_neighbor_index in range(0, len(map_neighbors[eventPlayer.pathfinder_current_node]), 1):
                eventPlayer.current_pathfinder_node = round(map_neighbors[eventPlayer.pathfinder_current_node][eventPlayer.pathfinder_neighbor_index][0])
                if eventPlayer.pathfinder_visited.index(eventPlayer.current_pathfinder_node) == -1:
                    eventPlayer.pathfinder_entry_nodes.append(eventPlayer.current_pathfinder_node)
                    eventPlayer.pathfinder_entry_parents.append(eventPlayer.pathfinder_best_entry)
                    eventPlayer.pathfinder_entry_cost.append(eventPlayer.pathfinder_entry_cost[eventPlayer.pathfinder_best_entry] + distance(map_nodes[eventPlayer.pathfinder_current_node], map_nodes[eventPlayer.current_pathfinder_node]))
                    eventPlayer.pathfinder_open.append(len(eventPlayer.pathfinder_entry_nodes) - 1)
                    eventPlayer.pathfinder_visited.append(eventPlayer.current_pathfinder_node)
                wait()

            pathfinder_budget -= 1

        wait()


# ============================================================
# PATH RECONSTRUCT — traces entry indices back to src.
# No .index() during traversal (only once to find dest entry).
# ============================================================

def bot_path_reconstruct():
    @Name "BOT - - - Path Reconstruct"

    while eventPlayer.pathfinder_reconstructing and eventPlayer.bot_state_id == BotState.NAVIGATE:
        #--- Append current entry's node to path ---
        eventPlayer.pathfinder_path.append(round(eventPlayer.pathfinder_entry_nodes[eventPlayer.pathfinder_reconstruction_entry]))

        #--- Follow parent entry index ---
        eventPlayer.pathfinder_reconstruction_entry = eventPlayer.pathfinder_entry_parents[eventPlayer.pathfinder_reconstruction_entry]

        #--- Done when parent is -1 (reached src) ---
        if eventPlayer.pathfinder_reconstruction_entry < 0:
            eventPlayer.pathfinder_reconstructing = false
            return

        #--- Safety: stop if path exceeds node count ---
        if len(eventPlayer.pathfinder_path) >= len(map_nodes):
            eventPlayer.pathfinder_reconstructing = false
            return

        wait()


# ============================================================
# STATE: COMBAT — face target, walk toward, shoot
# ============================================================

def bot_sm_combat():
    @Name "BOT - - - [STATE] Combat"

    #--- Validate target ---
    if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or not eventPlayer.bot_combat_target.hasSpawned() or eventPlayer.bot_combat_target.isDummy() or eventPlayer.bot_combat_target.browsing_shop or eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH]:
        eventPlayer.bot_combat_target = null
        eventPlayer.pathfinder_path = []
        eventPlayer.bot_state_id = BotState.NAVIGATE
        return

    #--- Reaction time (0.25s if shot, skip if scanned — awareness timer already waited 1s) ---
    eventPlayer.debug_bot_state = "COMBAT: REACTING"
    eventPlayer.bot_face_target = eventPlayer.bot_combat_target.getPosition() + vect(0, eventPlayer.bot_combat_target.stats[Stat.EYE_HEIGHT] / 2, 0)
    eventPlayer.bot_throttle_paused = false
    eventPlayer.bot_patrol_destination = eventPlayer.bot_combat_target.getPosition()
    if eventPlayer.bot_was_shot:
        waitUntil(eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead(), BOT_COMBAT_REACTION_SHOT)
        eventPlayer.bot_was_shot = false
        if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead():
            eventPlayer.bot_combat_target = null
            eventPlayer.pathfinder_path = []
            eventPlayer.bot_state_id = BotState.NAVIGATE
            return

    #--- Combat teleport: shadow step if target is far and ability is ready ---
    if distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) >= BOT_COMBAT_TELEPORT_RANGE and eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0:
        eventPlayer.debug_bot_state = "COMBAT: TELEPORT"
        eventPlayer.bot_throttle_paused = true
        eventPlayer.bot_using_teleport = true
        waitUntil(angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), eventPlayer.bot_face_target)) < BOT_SHADOW_STEP_AIM_ANGLE or eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead(), 2)
        if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead():
            eventPlayer.bot_using_teleport = false
            eventPlayer.bot_combat_target = null
            eventPlayer.pathfinder_path = []
            eventPlayer.bot_state_id = BotState.NAVIGATE
            return
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        wait()
        eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
        waitUntil(eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead(), 1.5)
        eventPlayer.bot_using_teleport = false
        eventPlayer.bot_throttle_paused = false
        if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead():
            eventPlayer.bot_combat_target = null
            eventPlayer.pathfinder_path = []
            eventPlayer.bot_state_id = BotState.NAVIGATE
            return

    #--- Engage: start shooting + walk toward target ---
    eventPlayer.debug_bot_state = "COMBAT: ENGAGED"
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)

    #--- Stay engaged until LOS lost, target invalid, target too far, or bot dies ---
    waitUntil(\
        eventPlayer.bot_combat_target == null \
        or eventPlayer.bot_combat_target.isDead() \
        or not eventPlayer.bot_combat_target.hasSpawned() \
        or eventPlayer.bot_combat_target.isDummy() \
        or eventPlayer.bot_combat_target.browsing_shop \
        or eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] \
        or eventPlayer.isDead() \
        or distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) > BOT_DISENGAGE_RANGE \
        or distance(raycast(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getEyePosition(), null, eventPlayer, false).getHitPosition(), eventPlayer.bot_combat_target.getEyePosition()) >= 1, \
        99999)

    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

    #--- Determine why we exited ---
    if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or not eventPlayer.bot_combat_target.hasSpawned() or eventPlayer.bot_combat_target.isDummy() or eventPlayer.bot_combat_target.browsing_shop or eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] or eventPlayer.isDead() or distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) > BOT_DISENGAGE_RANGE:
        #--- Target invalid or too far — return to navigation ---
        eventPlayer.bot_combat_target = null
        eventPlayer.pathfinder_path = []
        eventPlayer.bot_state_id = BotState.NAVIGATE
    else:
        #--- LOS lost — transition to searching ---
        eventPlayer.bot_search_destination = eventPlayer.bot_combat_target.getPosition()
        eventPlayer.bot_state_id = BotState.SEARCHING


# ============================================================
# STATE: SEARCHING — walk to last known position, look for target
# ============================================================

def bot_sm_searching():
    @Name "BOT - - - [STATE] Searching"

    eventPlayer.debug_bot_state = "SEARCHING"
    eventPlayer.bot_patrol_destination = eventPlayer.bot_search_destination
    eventPlayer.bot_face_target = eventPlayer.bot_search_destination + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)
    eventPlayer.bot_throttle_paused = false

    #--- Wait until: target reacquired (LOS + alive), arrived at search pos, target invalid, or timeout ---
    waitUntil(\
        (eventPlayer.bot_combat_target != null \
            and not eventPlayer.bot_combat_target.isDead() \
            and eventPlayer.bot_combat_target.hasSpawned() \
            and not eventPlayer.bot_combat_target.browsing_shop \
            and not eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] \
            and distance(raycast(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getEyePosition(), null, eventPlayer, false).getHitPosition(), eventPlayer.bot_combat_target.getEyePosition()) < 1) \
        or eventPlayer.bot_combat_target == null \
        or eventPlayer.bot_combat_target.isDead() \
        or eventPlayer.isDead() \
        or distance(eventPlayer.getPosition(), eventPlayer.bot_search_destination) < 2, \
        BOT_SEARCH_DURATION)

    #--- Check if target reacquired ---
    if eventPlayer.bot_combat_target != null and not eventPlayer.bot_combat_target.isDead() and eventPlayer.bot_combat_target.hasSpawned() and not eventPlayer.bot_combat_target.browsing_shop and not eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] and eventPlayer.isAlive() and distance(raycast(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getEyePosition(), null, eventPlayer, false).getHitPosition(), eventPlayer.bot_combat_target.getEyePosition()) < 1:
        eventPlayer.bot_state_id = BotState.COMBAT
    else:
        eventPlayer.bot_combat_target = null
        eventPlayer.pathfinder_path = []
        eventPlayer.bot_state_id = BotState.NAVIGATE





# ============================================================
# STRAFE & COMBAT SCAN — global serialized loop
# Cycles through bots one at a time.
# Full cycle takes BOT_STRAFE_CHECK_INTERVAL.
# ============================================================

def bot_strafe_and_scan():
    @Name "BOT - - - Strafe & Combat Scan (Global)"

    while true:
        strafe_bots = [bot for bot in getAllPlayers() if bot.isDummy() and bot.isAlive() and bot.bot_state_id != BotState.DEAD]
        if len(strafe_bots) > 0:
            for strafe_index in range(len(strafe_bots)):

                #--- Strafe check (navigating + not paused only) ---
                if strafe_bots[strafe_index].bot_state_id == BotState.NAVIGATE and not strafe_bots[strafe_index].bot_throttle_paused:
                    if raycast(strafe_bots[strafe_index].getPosition() + vect(0, strafe_bots[strafe_index].stats[Stat.EYE_HEIGHT] / 2, 0), strafe_bots[strafe_index].getPosition() + vect(0, strafe_bots[strafe_index].stats[Stat.EYE_HEIGHT] / 2, 0) + angleToDirection(horizontalAngleOfDirection(directionTowards(strafe_bots[strafe_index].getPosition(), strafe_bots[strafe_index].bot_patrol_destination)), 0) * 1.5, getAllPlayers(), strafe_bots[strafe_index], false).getPlayerHit() != null:
                        strafe_bots[strafe_index].bot_strafe = BOT_STRAFE_AMOUNT
                    else:
                        strafe_bots[strafe_index].bot_strafe = 0

                #--- Combat scan (not already in combat, bots hostile) ---
                if not bots_friendly and strafe_bots[strafe_index].bot_state_id != BotState.COMBAT and strafe_bots[strafe_index].bot_state_id != BotState.SEARCHING and strafe_bots[strafe_index].bot_combat_target == null:
                    #--- Cheap gate: players in view angle + distance + filters ---
                    scan_visible_players = sorted([player for player in strafe_bots[strafe_index].getPlayersInViewAngle(Team.ALL, BOT_VIEW_ANGLE) if not player.isDummy() and player.isAlive() and distance(strafe_bots[strafe_index].getPosition(), player.getPosition()) <= BOT_DETECTION_RANGE and not player.browsing_shop and not player.is_using_ability[Talent.STEALTH]], lambda player: distance(strafe_bots[strafe_index].getPosition(), player.getPosition()))
                    if len(scan_visible_players) > 0:
                        #--- Expensive: raycast eye → closest player body center ---
                        if distance(raycast(strafe_bots[strafe_index].getEyePosition(), scan_visible_players[0].getEyePosition(), null, strafe_bots[strafe_index], false).getHitPosition(), scan_visible_players[0].getEyePosition()) < 1:
                            #--- Player visible — update alert meter ---
                            if strafe_bots[strafe_index].bot_combat_awareness_start == 0:
                                strafe_bots[strafe_index].bot_combat_awareness_start = getTotalTimeElapsed()
                            elif getTotalTimeElapsed() - strafe_bots[strafe_index].bot_combat_awareness_start >= BOT_COMBAT_REACTION_SCAN:
                                #--- 1 second of awareness — enter combat ---
                                strafe_bots[strafe_index].bot_combat_target = scan_visible_players[0]
                                strafe_bots[strafe_index].bot_combat_awareness_start = 0
                                strafe_bots[strafe_index].bot_state_id = BotState.COMBAT
                        else:
                            strafe_bots[strafe_index].bot_combat_awareness_start = 0
                    else:
                        strafe_bots[strafe_index].bot_combat_awareness_start = 0

                wait(BOT_STRAFE_CHECK_INTERVAL / len(strafe_bots))
        else:
            wait(BOT_STRAFE_CHECK_INTERVAL)



rule "DEBUG - - - Re-enable Ability 2 for non-bots (testing Shadow Step as Reaper)":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Hero reaper

    wait(1)
    eventPlayer.setAbility2Enabled(true)


