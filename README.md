# Verilog Sequence Detector (Moore FSM)

A Moore finite state machine in Verilog that detects several specific 11-bit serial sequences on a single input bit stream, with a lockout mechanism to prevent immediate re-triggering after a detection, and a corrected testbench verifying both detection and lockout behavior.

## Design

`Group13_SequenceDetector.v` implements a 28-state Moore FSM that watches a serial input (`x_in`), one bit per clock cycle, and asserts `detected` when one of three target 11-bit sequences has been fully received.

### Ports

| Port     | Direction | Width | Description                          |
|----------|-----------|-------|----------------------------------------|
| clk      | input     | 1     | Clock                                  |
| reset    | input     | 1     | Asynchronous, active-high reset        |
| x_in     | input     | 1     | Serial input bit, sampled each cycle   |
| detected | output    | 1     | High for one cycle when a target sequence is fully matched |

### Target sequences
The FSM recognizes three distinct 11-bit patterns, sharing common leading bits before branching:
- `10010010011`
- `10001111111`
- `10001101010`

### Lockout mechanism
After a successful detection, the FSM does not immediately return to its idle state. It instead requires exactly three more `1` bits (any number of `0`s in between is fine) before it is willing to start scanning for a new match. This prevents a detection from immediately re-triggering off overlapping bits in the incoming stream.

## Testbench

`tb_Group13_Detector.sv` drives input bits on the negative clock edge and lets the FSM sample them on the following positive edge, avoiding race conditions between testbench stimulus and DUT sampling.

Covered scenarios:
1. Detection of each of the three target sequences from a clean idle state.
2. Correct clearing of the lockout mechanism after the required three `1` bits.
3. Insufficient lockout clearing (only two bits) genuinely blocking a subsequent detection attempt, verified directly against the FSM's internal state.
4. Full lockout clearing followed by a successful re-detection.

Each check prints PASS or FAIL with the relevant signal or state values to the simulation console.

## the simulation
