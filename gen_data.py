import random

# --- CONFIGURATION ---
NUM_TEST_VECTORS = 10000   # Scaled up to 10,000!
RND_SEED = 42

random.seed(RND_SEED)

def pack_activations(acts):
    return (acts[3] << 12) | (acts[2] << 8) | (acts[1] << 4) | (acts[0])

f_activations = open("activations.hex", "w")
f_weights     = open("weights.hex", "w")
f_mask        = open("mask.hex", "w")
f_expected    = open("expected.hex", "w")

print(f"Generating {NUM_TEST_VECTORS} test vectors (Hardware-Aligned)...")

for i in range(NUM_TEST_VECTORS):
    activations = [random.randint(0, 15) for _ in range(4)]
    weights_raw = [random.randint(0, 15) for _ in range(4)]

    # 1. Find the Top 2 Weights (by Value)
    indexed_weights = [(val, idx) for idx, val in enumerate(weights_raw)]
    sorted_by_val = sorted(indexed_weights, key=lambda x: (-x[0], x[1]))
    top2_by_val = sorted_by_val[:2]

    # 2. Sort by Index (Hardware Expectation)
    top2_sorted_by_index = sorted(top2_by_val, key=lambda x: x[1])

    w_bot_pair = top2_sorted_by_index[0] # Lower index
    w_top_pair = top2_sorted_by_index[1] # Higher index

    w_bot_val = w_bot_pair[0]
    w_bot_idx = w_bot_pair[1]
    
    w_top_val = w_top_pair[0]
    w_top_idx = w_top_pair[1]

    # 3. Create Bitmask
    mask = 0
    mask |= (1 << w_bot_idx)
    mask |= (1 << w_top_idx)

    # 4. Expected Result
    expected_result = (w_top_val * activations[w_top_idx]) + (w_bot_val * activations[w_bot_idx])

    # 5. Write to files
    f_activations.write(f"{pack_activations(activations):04x}\n")
    
    # Write weights: Higher Index FIRST, then Lower Index
    f_weights.write(f"{w_top_val:02x}\n") 
    f_weights.write(f"{w_bot_val:02x}\n") 
    
    f_mask.write(f"{mask:01x}\n")
    f_expected.write(f"{expected_result:04x}\n")

f_activations.close()
f_weights.close()
f_mask.close()
f_expected.close()

print("Files generated. Ready for simulation.")