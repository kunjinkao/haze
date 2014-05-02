(
SynthDef(\granular, {arg out = 0, buff, pos = 0, spread = 0.05, dur = 0.40, p = 0.5, t_trig = 0, rate= 1, t = 300, a = 0.1, l = 1, pa = 0, att = 6, f = 100;
    var trigger = Impulse.ar(t);
    var sp = TRand.ar((-1)*spread, spread, trigger);
    var pan = TRand.ar((-1)*p, p, trigger);
    var sig = GrainBuf.ar(1, trigger, dur, buff, rate + LFNoise0.ar(f).range(-0.05, 0.05), Lag.kr(pos, l) + sp, pan:pan);
    var env = EnvGen.kr(Env.linen(att, 4, 8), gate: t_trig, doneAction:0);
    Out.ar(out, Pan2.ar(sig*env*a, pa));
}).add;

SynthDef(\del, {arg out = 0, in, feed = 0.93;
    var sig = In.ar(in, 2) + LocalIn.ar(2);
    var delL = DelayL.ar(sig[0], 2.0, 0.2);
    var delR = DelayL.ar(sig[1], 2.0, 0.5);
    LocalOut.ar([delL, delR]*feed);
    Out.ar(out, Compander.ar(sig, sig, 0.5, 1, 0.5, 0.01, 0.1));
}).add;

)
~path = "~/sounds/greedy/".asAbsolutePath;

~del = Bus.audio(s, 2);


y = Synth(\del, [\in: ~del]);

~buff = Buffer.readChannel(s, ~path ++ "banknote.wav", channels: [0]);
~buff2 = Buffer.readChannel(s, ~path ++ "coin2.wav", channels: [0]);
~buff3 = Buffer.readChannel(s, ~path ++ "coinfall.wav", channels: [0]);
~buff4 = Buffer.readChannel(s, ~path ++ "showme.wav", channels: [0]);
~buff5 = Buffer.readChannel(s, ~path ++ "shakecoin.wav", channels: [0]);

~buffers = [~buff, ~buff2, ~buff3, ~buff4, ~buff5];


~synths = Array.fill(5, {Synth(\granular, [\buff: ~buff, \t_trig:0, \pos: 0.5, \rate: ([0, 4, 5, 7, 9, 12, 16, 17] - 12).choose.midiratio, \spread: 0.05, \out:~del ])});

~synths = [];

Synth(\granular, [\buff: ~buff, \t_trig:1, \pos: 0.2, \rate: 1.5, \spread: 0.05, \spread, 0.2, \out:~del])

a = Synth(\granular, [\buff: ~buff3, \t_trig:1, \pos: 0.2, \rate: 1.5, \spread: 0.05, \spread, 0.2, \out:0, \l, 1])

a.set(\t_trig, 1)

a.set(\rate, 0.4)
a.set(\spread, 0.6)


(
// Dust randomly triggers Decay to create an exponential
// decay envelope for the WhiteNoise input source
{
z = Decay.ar(Dust.ar(1,0.5), 0.3, WhiteNoise.ar);
DelayL.ar(z, 0.2, 0.2, 1, z); // input is mixed with delay via the add input
}.play
)

(
// recursive application of delay.
{
z = Decay2.ar(Dust.ar(1, 0.5), 0.01, 0.1, Saw.ar(100 + [0, 1]));
5.do { |i| z = DelayL.ar(RLPF.ar(z, Rand(100, 3000), 0.03), 1, 1 / (2**i), 1, z * 0.5) };
z
}.play
)
Quarks.gui

