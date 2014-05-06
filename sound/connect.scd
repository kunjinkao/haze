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


s.sendMsg(\n_set, ~synths.choose.nodeID, \t_trig, 1);

OSCdef(\trig, { |args|
  var user_id = args[1];

  var node_id = ~user_dict.at(user_id);
  ("trigger" + user_id).postln;

  s.sendMsg(\n_set, node_id, \t_trig, 1);

}, '/haze/trig', nil, 9001);

OSCdef(\update, { |args|
  var user_id = args[1];

  var xval = args[2].abs.linlin(0, 8, 0.0, 1.0);
  var yval = args[3].abs.linlin(0, 8, 0.0, 1.0);
  var zval = args[4].abs.linlin(0, 8, 0.0, 1.0);
  var alpha = args[5].linlin(0, 360, 0.0, 1.0);
  var beta = args[6].linlin(-180, 180, 0.0, 1.0);
  var gamma = args[7].linlin(-90, 90, 0.0, 1.0);

  var node_id = ~user_dict.at(user_id);
  var log = "update "++ user_id ++ "node " ++ node_id ++ "args " ++ args;
  // log.postln;

  s.sendMsg(\n_set, node_id,
    \rate, rrand(0.8, 1.3),
    \pa, rrand(-0.5, 0.5)
  );

}, '/haze/update', nil, 9001);

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

