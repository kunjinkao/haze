~processing = NetAddr("127.0.0.1", 12000);
n = ~processing;
~rhizome = NetAddr.new("127.0.0.1", 9000);

s.meter

~section = 'control';
~section = 'schedule';

(
~user_dict = ();
~synth_ids = ~synths.asArray.collect(_.nodeID);
)

(
// device connect
OSCdef(\open, { |args|
  var user_id = args[1];
  args.postln;
  ("new user connect: " + user_id).postln;
  ~user_dict.put(user_id, ~synth_ids.pop);
  if(~section!=nil) {
    ~rhizome.sendMsg('/section', 9001, ~section)
  };
}, '/broadcast/websockets/open', nil, 9001);

OSCdef(\get_section, { |args|
  if(~section!=nil) {
    ~rhizome.sendMsg('/section', 9001, ~section)
  };
}, '/get_section', nil, 9001);

// device closed
OSCdef(\close, { |args|
  var user_id = args[1];

  ("user disconnect: " + user_id).postln;

  if(~user_dict.at(user_id) != nil, {
    ~synth_ids.add(~user_dict.at(user_id));
  });

}, '/broadcast/websockets/close', nil, 9001);




OSCdef(\trig, { |args|
  var user_id = args[1];

  var vx = args[2];
  var vy = args[3];
  var locx = args[3];
  var locy = args[4];

  var node_id = ~user_dict.at(user_id);
  var speed = hypot(vx, vy);

  args.postln;
  ("trigger" + user_id + node_id).postln;
  s.sendMsg(\n_set, node_id,
    \t, (speed*15).max(200),
    \dur, (vx.abs/20),
    \pos, locx,
    \l, rrand(0.4, 4),
    \rate, ([0, 4, 5, 7, 9, 12, 16, 17]).choose.midiratio,
    \spread, (vy.abs/20),
    \p, rrand(-0.3, 0.3),
    \pa, vx/4.max(1).min(-1),
    \att, rrand(6, 9),
    \a, locy.linlin(0, 1, 0.01, 0.04),
    \f, rrand(50, 150),
    \t_trig, 1
  );

}, '/haze/trig', nil, 9001);


// successful subscriebed
OSCdef(\subscribed, { |args|
  ("subed" + args).postln;
}, '/sys/subscribed', nil, 9001);
)


(
OSCdef.all.do {|item|
  ~rhizome.sendMsg('/sys/subscribe', 9001, item.path.asString);
};
)

// change section
(
~section = 'end';
~rhizome.sendMsg('/section', 9001, ~section);
)

