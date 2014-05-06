~processing = NetAddr("127.0.0.1", 12000);

(
~processing.sendMsg('/text', 0, 0);
~processing.sendMsg('/mode', 1);
)


(
~processing.sendMsg('/text', 1, 1);
~processing.sendMsg('/mode', 1);
)


(
~processing.sendMsg('/text', 2, 2);
~processing.sendMsg('/mode', 1);
)