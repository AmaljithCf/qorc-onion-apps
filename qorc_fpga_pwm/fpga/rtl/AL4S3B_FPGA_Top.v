
module AL4S3B_FPGA_Top (
    
    // LEDs from constraint file
    red_led,
    green_led,
    blue_led
);

// MODULE Parameters =====================================================================

parameter PWM_RESOLUTION_BITS = 8;

// MODULE Internal Parameters ============================================================

localparam switch_count = 32'h12C0000;


// MODULE PORT Declarations and Data Types ===============================================

output      wire            red_led              ;
output      wire            green_led            ;
output      wire            blue_led             ;


// MODULE INTERNAL Signals ===============================================================

wire                                    Sys_Clk0        ;
wire                                    Sys_Clk0_Rst    ;

wire                                    Sys_Clk1        ;
wire                                    Sys_Clk1_Rst    ;

wire                                    CLK_IP          ; // Selected FPGA Clock
wire                                    RST_IP          ; // Selected FPGA Reset


reg     [PWM_RESOLUTION_BITS-1:0]       red_val         ; // duty-cycle for the red PWM
reg     [PWM_RESOLUTION_BITS-1:0]       green_val       ; // duty-cycle for the green PWM
reg     [PWM_RESOLUTION_BITS-1:0]       blue_val        ; // duty-cycle for the blue PWM

reg                                     red_en          ; // reset for the red PWM
reg                                     green_en        ; // reset for the green PWM
reg                                     blue_en         ; // reset for the blue PWM


reg     [31:0]                          count           ;
initial count <= 0;

reg     [31:0]                          state           ;
initial state <= 0;

reg                                     toggle          ;


// MODULE LOGIC ==========================================================================

// Sys_Clk1_Rst provides a reset signal for the other FPGA IP logic
assign RST_IP = Sys_Clk0_Rst;
// Sys_Clk1 provides a clock signal for the other FPGA IP logic
assign CLK_IP = Sys_Clk0;


always@(*)
begin
    case (state)

    32'd0       :   begin   // state 0
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 1
                        red_val <= 20;
                        green_val <= 20;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 1
                        red_val <= 20;
                        green_val <= 0;
                        blue_val <= 20;
                    end     // toggle LOW
                    end     // state 0

    32'd1       :   begin   // state 1
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 2
                        red_val <= 40;
                        green_val <= 40;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 2
                        red_val <= 40;
                        green_val <= 0;
                        blue_val <= 40;
                    end     // toggle LOW
                    end     // state 1

    32'd2       :   begin   // state 2
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 3
                        red_val <= 60;
                        green_val <= 60;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 3
                        red_val <= 60;
                        green_val <= 0;
                        blue_val <= 60;
                    end     // toggle LOW
                    end     // state 2

    32'd3       :   begin   // state 3
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 4
                        red_val <= 80;
                        green_val <= 80;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 4
                        red_val <= 80;
                        green_val <= 0;
                        blue_val <= 80;
                    end     // toggle LOW
                    end     // state 3

    32'd4       :   begin   // state 4
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 5
                        red_val <= 100;
                        green_val <= 100;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 5
                        red_val <= 100;
                        green_val <= 0;
                        blue_val <= 100;
                    end     // toggle LOW
                    end     // state 4

    32'd5       :   begin   // state 5
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 6
                        red_val <= 127;
                        green_val <= 127;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 6
                        red_val <= 127;
                        green_val <= 0;
                        blue_val <= 127;
                    end     // toggle LOW
                    end     // state 5

    32'd6       :   begin   // state 6
                    if(toggle)
                    begin   // toggle HIGH
                        // YELLOW - LEVEL 7
                        red_val <= 150;
                        green_val <= 150;
                        blue_val <= 0;
                    end     // toggle HIGH
                    else
                    begin   // toggle LOW
                        // MAGENTA - LEVEL 7
                        red_val <= 150;
                        green_val <= 0;
                        blue_val <= 150;
                    end     // toggle LOW
                    end     // state 6

    default     :   begin   // state error
                    // RED
                    red_val <= 255;
                    green_val <= 0;
                    blue_val <= 0;
                    end     // state error

    endcase
end

always @(posedge CLK_IP or posedge RST_IP) 
begin
    if (RST_IP)
    begin // handle reset
        count <= 0;
        red_en <= 0;
        green_en <= 0;
        blue_en <= 0;
        state <= 0;
        toggle <= 0;
        
    end // handle reset
    else
    begin // not reset

        red_en <= 1;
        green_en <= 1;
        blue_en <= 1;

        if (count == switch_count)
        begin // at sentinel counter
            count <= 0;
            case (state)
            32'd0       :   state <= 32'd1;
            32'd1       :   state <= 32'd2;
            32'd2       :   state <= 32'd3;
            32'd3       :   state <= 32'd4;
            32'd4       :   state <= 32'd5;
            32'd5       :   state <= 32'd6;
            32'd6       :   begin
                            state <= 32'd0; 
                            toggle <= ~toggle;
                            end
            default     :   ;
            endcase
        end // at sentinel counter
        else 
        begin
            count <= count + 1;
        end
    end // not reset
end


// Instantiate (sub)Modules ==============================================================

// we need only the clocks/resets from the cell macro
qlal4s3b_cell_macro u_qlal4s3b_cell_macro (
    // FB Clocks
    .Sys_Clk0                  ( Sys_Clk0                       ), // output
    .Sys_Clk0_Rst              ( Sys_Clk0_Rst                   ), // output
    .Sys_Clk1                  ( Sys_Clk1                       ), // output
    .Sys_Clk1_Rst              ( Sys_Clk1_Rst                   ), // output
);

ONION_PWM
    #(
        .PWM_RESOLUTION_BITS    ( PWM_RESOLUTION_BITS          )
    )
    r_pwm 
    (
        .clk(CLK_IP),
        .duty_cycle(red_val),
        .reset(red_en),
        .PWM_o(red_led)
    );


ONION_PWM
    #(
        .PWM_RESOLUTION_BITS    ( PWM_RESOLUTION_BITS          )
    )
    g_pwm 
    (
        .clk(CLK_IP),
        .duty_cycle(green_val),
        .reset(green_en),
        .PWM_o(green_led)
    );


ONION_PWM
    #(
        .PWM_RESOLUTION_BITS    ( PWM_RESOLUTION_BITS          )
    )
    b_pwm 
    (
        .clk(CLK_IP),
        .duty_cycle(blue_val),
        .reset(blue_en),
        .PWM_o(blue_led)
    );


endmodule

