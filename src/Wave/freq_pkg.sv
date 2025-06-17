package freq_pkg;

    localparam int FREQ [0:24] = '{
        12'd536,  // adjusted frequency for C5  (523.251 Hz * (32768 / 32000) = 535.809)
        12'd568,  // adjusted frequency for C♯5 (554.365 Hz * (32768 / 32000) = 567.669)
        12'd601,  // adjusted frequency for D5  (587.329 Hz * (32768 / 32000) = 601.425)
        12'd637,  // adjusted frequency for D♯5 (622.254 Hz * (32768 / 32000) = 637.188)
        12'd675,  // adjusted frequency for E5  (659.255 Hz * (32768 / 32000) = 675.077)
        12'd715,  // adjusted frequency for F5  (698.456 Hz * (32768 / 32000) = 715.218)
        12'd758,  // adjusted frequency for F♯5 (739.989 Hz * (32768 / 32000) = 757.749)
        12'd803,  // adjusted frequency for G5  (783.991 Hz * (32768 / 32000) = 802.807)
        12'd851,  // adjusted frequency for G♯5 (830.609 Hz * (32768 / 32000) = 850.544)
        12'd901,  // adjusted frequency for A5  (880.000 Hz * (32768 / 32000) = 901.120)
        12'd955,  // adjusted frequency for A♯5 (932.328 Hz * (32768 / 32000) = 954.704)
        12'd1011, // adjusted frequency for B5  (987.767 Hz * (32768 / 32000) = 1011.473)
        12'd1072, // adjusted frequency for C6  (1046.502 Hz * (32768 / 32000) = 1071.618)
        12'd1135, // adjusted frequency for C♯6 (1108.731 Hz * (32768 / 32000) = 1135.341)
        12'd1203, // adjusted frequency for D6  (1174.659 Hz * (32768 / 32000) = 1202.851)
        12'd1274, // adjusted frequency for D♯6 (1244.508 Hz * (32768 / 32000) = 1274.376)
        12'd1350, // adjusted frequency for E6  (1318.510 Hz * (32768 / 32000) = 1350.154)
        12'd1430, // adjusted frequency for F6  (1396.913 Hz * (32768 / 32000) = 1430.439)
        12'd1515, // adjusted frequency for F♯6 (1479.978 Hz * (32768 / 32000) = 1515.497)
        12'd1606, // adjusted frequency for G6  (1567.982 Hz * (32768 / 32000) = 1605.614)
        12'd1701, // adjusted frequency for G♯6 (1661.219 Hz * (32768 / 32000) = 1701.088)
        12'd1802, // adjusted frequency for A6  (1760.000 Hz * (32768 / 32000) = 1802.240)
        12'd1909, // adjusted frequency for A♯6 (1864.655 Hz * (32768 / 32000) = 1909.407)
        12'd2023, // adjusted frequency for B6  (1975.533 Hz * (32768 / 32000) = 2023.946)
        12'd2143  // adjusted frequency for C7  (2093.005 Hz * (32768 / 32000) = 2143.237)
    };
    
endpackage