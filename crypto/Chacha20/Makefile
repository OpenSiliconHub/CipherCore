.PHONY: sim clean

BUILD_DIR = build
SIM_DIR   = $(BUILD_DIR)/sim_results

sim:
	@rm -rf $(SIM_DIR)
	@mkdir -p $(SIM_DIR)

	@iverilog -o $(SIM_DIR)/chacha20_sim chacha20.v sim/chacha20_tb.v
	@vvp $(SIM_DIR)/chacha20_sim

	@iverilog -o $(SIM_DIR)/chacha12_sim chacha20.v sim/chacha12_tb.v
	@vvp $(SIM_DIR)/chacha12_sim

	@iverilog -o $(SIM_DIR)/chacha8_sim chacha20.v sim/chacha8_tb.v
	@vvp $(SIM_DIR)/chacha8_sim

clean:
	@rm -rf $(BUILD_DIR)
