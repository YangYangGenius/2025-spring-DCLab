// ---------- Local Parameters ---------- //

    // Timing parameters for different resolutions and frame rates
    localparam VGA_640x480_H_A = 96, VGA_640x480_H_B = 48, VGA_640x480_H_D = 16;
    localparam VGA_640x480_V_A = 2, VGA_640x480_V_B = 33, VGA_640x480_V_D = 10;

    localparam VGA_1600x900_H_A = 24, VGA_1600x900_H_B = 80, VGA_1600x900_H_D = 96;
    localparam VGA_1600x900_V_A = 1, VGA_1600x900_V_B = 3, VGA_1600x900_V_D = 96;

    // Dynamically select timing parameters at elaboration
    localparam H_A = (H_SIZE == 640 && V_SIZE == 480 && FRAME_RATE == 60) ? VGA_640x480_H_A :
                     (H_SIZE == 1600 && V_SIZE == 900 && FRAME_RATE == 60) ? VGA_1600x900_H_A :
                     VGA_1600x900_H_A; // Default value

    localparam H_B = (H_SIZE == 640 && V_SIZE == 480 && FRAME_RATE == 60) ? VGA_640x480_H_B :
                     (H_SIZE == 1600 && V_SIZE == 900 && FRAME_RATE == 60) ? VGA_1600x900_H_B :
                     VGA_1600x900_H_B; // Default value

    localparam H_D = (H_SIZE == 640 && V_SIZE == 480 && FRAME_RATE == 60) ? VGA_640x480_H_D :
                     (H_SIZE == 1600 && V_SIZE == 900 && FRAME_RATE == 60) ? VGA_1600x900_H_D :
                     VGA_1600x900_H_D; // Default value

    localparam V_A = (H_SIZE == 640 && V_SIZE == 480 && FRAME_RATE == 60) ? VGA_640x480_V_A :
                     (H_SIZE == 1600 && V_SIZE == 900 && FRAME_RATE == 60) ? VGA_1600x900_V_A :
                     VGA_1600x900_V_A; // Default value

    localparam V_B = (H_SIZE == 640 && V_SIZE == 480 && FRAME_RATE == 60) ? VGA_640x480_V_B :
                     (H_SIZE == 1600 && V_SIZE == 900 && FRAME_RATE == 60) ? VGA_1600x900_V_B :
                     VGA_1600x900_V_B; // Default value

    localparam V_D = (H_SIZE == 640 && V_SIZE == 480 && FRAME_RATE == 60) ? VGA_640x480_V_D :
                     (H_SIZE == 1600 && V_SIZE == 900 && FRAME_RATE == 60) ? VGA_1600x900_V_D :
                     VGA_1600x900_V_D; // Default value