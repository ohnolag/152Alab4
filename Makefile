TOP=top_joystick_test
PART=xc7a35tcpg236-1
DEVICE=xc7a35tcpg236-1
XDC=constraints.xdc
BUILD=build
CHIPDB=$(BUILD)/$(DEVICE).bin
XRAY_DB=/opt/openxc7/share/nextpnr/prjxray-db/artix7
NEXTPNR_XILINX=/toolchain-installer/nextpnr-xilinx
SOURCES=top_joystick_test.v \
	joystick/joystick_poll_timer.v \
	joystick/pmod_jstk_driver.v \
	joystick/spi_ctrl_5byte.v \
	joystick/spi_mode0.v \
	joystick/clk_div_jstk.v

all: $(BUILD)/$(TOP).bit

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/$(TOP).json: $(SOURCES) | $(BUILD)
	yosys -p "read_verilog $(SOURCES); synth_xilinx -flatten -abc9 -arch xc7 -top $(TOP); write_json $@"

$(BUILD)/$(DEVICE).bba: | $(BUILD)
	python3 $(NEXTPNR_XILINX)/xilinx/python/bbaexport.py --xray $(XRAY_DB) --device $(DEVICE) --constids $(NEXTPNR_XILINX)/xilinx/constids.inc --bba $@

$(CHIPDB): $(BUILD)/$(DEVICE).bba
	bbasm -l $< $@

$(BUILD)/$(TOP).fasm: $(BUILD)/$(TOP).json $(XDC) $(CHIPDB)
	nextpnr-xilinx --chipdb $(CHIPDB) --xdc $(XDC) --json $< --write $(BUILD)/$(TOP)_routed.json --fasm $@

$(BUILD)/$(TOP).frames: $(BUILD)/$(TOP).fasm
	python3 /opt/prjxray/utils/fasm2frames.py --part $(PART) --db-root /opt/openxc7/lib/external/prjxray-db/artix7 $< > $@

$(BUILD)/$(TOP).bit: $(BUILD)/$(TOP).frames
	xc7frames2bit --part_file /opt/openxc7/lib/external/prjxray-db/artix7/$(PART)/part.yaml --part_name $(PART) --frm_file $< --output_file $@

clean:
	rm -rf $(BUILD)
