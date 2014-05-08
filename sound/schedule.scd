~processing = NetAddr("127.0.0.1", 12000);

~processing.sendMsg('/mode', 0);
// part1- haze
(
~processing.sendMsg('/text', 0, 0);
~processing.sendMsg('/mode', 1);
)

// haze - interactive
(
~processing.sendMsg('/interaction_text', 0);
~processing.sendMsg('/mode', 2);
)


// part2 - body dance
(
~processing.sendMsg('/text', 1, 1);
~processing.sendMsg('/mode', 1);
)

// body dance - interactive
(
~processing.sendMsg('/interaction_text', 1);
~processing.sendMsg('/mode', 2);
)

// part3 - blind
(
~processing.sendMsg('/text', 2, 2);
~processing.sendMsg('/mode', 1);
)