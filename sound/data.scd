// loading the pm2.5 of xi'an 2013 data

n = NetAddr("127.0.0.1", 12000); 	// processing listens to 12000

s.meter


(
var data_file_path = "~/Desktop/haze/data/".absolutePath;
~date = parseJson(File(data_file_path++"date.txt", "r").readAllString).collect(_.asSymbol);
d = Dictionary.new;
~loc_maps = ();

~loc_maps.putPairs([
  \xian, 0,
  // \caotan, 4,
  \gaoya, 5,
  // \qujiang, 4,
  \xingqing, 1,
  \changan, 9,
  // \guangyuntan, 4,
  // \tiyuchang, 1,
  \yanliang, 4,
  \fangzhicheng, 7,
  // \jingkai, 6,
  \gaoxin, 6,
  // \lintong, 4
]);

~loc_maps.keys.do({|loc_name|
  var path = data_file_path ++ loc_name ++".json";
  var file =File(path, "r");
  var pm25, pm10, so2, no2, co, rate, date;
  var json = parseJson(file.readAllString);
  var data = ();

  json.do({|item|
    var obj;
    date = item.at("时间").stripWhiteSpace();
    pm10 = item.at("PM10").asInteger;
    pm25 = item.at("PM2.5").asInteger;
    so2 = item.at("SO2").asInteger;
    no2 = item.at("NO2").asInteger;
    co = item.at("CO").asInteger;
    rate = switch (item.at("首要污染物"))
    {"优"} { 1 }
    {"良"} { 2 }
    {"轻度"}   { 3 }
    {"中度"} { 4 }
    {"重度"} { 5 }
    {"严重"} { 5 }
    {"轻微污染"}   { 3 }
    {"中度污染"}   { 4 };

    rate = rate ? 0;
    obj = (
      pm10: pm10,
      so2: so2,
      no2: no2,
      rate: rate,
      pm25: pm25,
      co: co,
      date: date
    );
    data.put(date.asSymbol, obj);
  });

  d.put(loc_name, data).postln;
});

)



(
~buffers.collect(_.free);
~path = "~/sounds/haze/".asAbsolutePath;
~buff1 = Buffer.readChannel(s, ~path ++ "banknote.wav", channels: [0]);
~buff2 = Buffer.readChannel(s, ~path ++ "train.wav", channels: [0]);
~buff3 = Buffer.readChannel(s, ~path ++ "coin_spin.wav", channels: [0]);
~buff4 = Buffer.readChannel(s, ~path ++ "rain.aiff", channels: [0]);
~buff5 = Buffer.readChannel(s, ~path ++ "thunder.wav", channels: [0]);
~buff6 = Buffer.readChannel(s, ~path ++ "whistle.wav", channels: [0]);
~buff7 = Buffer.readChannel(s, ~path ++ "slowdown.aiff", channels: [0]);
~buffers = [~buff1, ~buff2, ~buff3, ~buff4, ~buff5, ~buff6, ~buff7];
)


~del = Bus.audio(s, 2);
~del.index


(
Ndef(\delay).fadeTime = 5;
Ndef(\delay, { |in=4, feed=0.5|
    var sig = In.ar(in, 2) + LocalIn.ar(2);
    var delL = DelayL.ar(sig[0], 0.5, 0.2);
    var delR = DelayL.ar(sig[1], 0.5, 0.2);
    LocalOut.ar([delL, delR]*feed);
    Compander.ar(sig, sig, 0.5, 1, 0.5, 0.01, 0.02)
  // Out.ar(out, Compander.ar(sig, sig, 0.5, 1, 0.5, 0.01, 0.02));
}).play(0, 2);
)

s.meter

(
~setfunc = {|key, gas_data|
  ~synths.at(key).set(
    \t_trig, 1,
    \t, gas_data.so2.linexp(0, 100, 10, 300),
    // \l, rrand(0.4, 4),
    \l, gas_data.no2.linexp(0, 100, 0.5, 4),
    \f, gas_data.no2.linlin(0, 100, 50, 150),
    // \pa, ~loc_maps.at(key).linlin(0, 10, 1, -1),
    \pa, 0,
    \p, ~loc_maps.at(key).linlin(0, 10, -0.5, 0.5),
    \spread, gas_data.pm10.linlin(0, 200, 0.05, 0.8),
    \dur, gas_data.no2.asFloat.linlin(0, 50, 0.05, 0.5),
    \att, rrand(6, 9),
    \rate, ([0, 4, 5, 7, 9, 12, 16, 17] - 12).choose.midiratio,
    // \rate, gas_data.pm10.asFloat.linlin(0, 400, 0.3, 1.4),
    \a, gas_data.at('rate').asFloat.linlin(0, 5, 0.02, 0.07),
    \pos, rrand(0.0, 0.8),
    // \pos, gas_data.so2.asFloat.linlin(0, 80, 0.0, 1.0),
    \a, rrand(0.05, 0.1)
    // \a, ~loc_maps.at(key).linlin(0, 10, 0.02, 0.08)
  );
};

)


~locs = ~loc_maps.keys.asArray.scramble[0];

~processing = NetAddr("192.168.1.101", 12000);
~processing.sendMsg('/date', '2010-1-3');

(
~new_date = {|date|
  var loc_keys = ~loc_maps.keys.asArray;
  var locs;

  // locs = loc_keys.choose;
  // locs = loc_keys.scramble[0..4];
  n.sendMsg('/date', date);
  date.postln;

  ~locs.asArray.do({|key|
      var gas_data = d.at(key).at(date);
      if (gas_data!=nil) {
        gas_data.postln;
        ~setfunc.value(key, gas_data);
      }
    });
  // rrand(0.1, 4).wait;
  rrand(4, 9).wait;
};
)

~synths.size


(
~synths.collect(_.release);
~synths = ();

~loc_maps.keys.asArray.do({|key, index|
  var sound = Synth(\granular, [\buff: ~buffers[index], \t_trig:0, \pos: 0.5, \rate: 0.5, \spread: 0.05, \out:~del, \a, 0.05]);
  ~synths.put(key,sound);
});

t = Task({
  ~date[300..].do({|date|
    try {
      ~new_date.value(date);
    } { |error|
      error.species.name.postln;
    };
  });
}).play;
)

t.stop
