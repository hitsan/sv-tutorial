#include "Vudp_rx_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Instantiate DUT
    Vudp_rx_tb* tb = new Vudp_rx_tb;

    // Initialize VCD tracing
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("udp_rx_tb.vcd");

    // Run simulation
    while (!Verilated::gotFinish()) {
        tb->eval();
        tfp->dump(Verilated::time());
        Verilated::timeInc(1);
    }

    // Cleanup
    tfp->close();
    delete tb;
    delete tfp;

    return 0;
}
