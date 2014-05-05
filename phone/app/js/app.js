$(function() {

  var $statusData = $("#status-data");
  var $trigBtn = $('#trig');

  var setSection = function(args) {
    var sectionName = args[1];
    var sectionList = ["control", "schedule", "end"];

    sectionList.map(function(item){
      if(item==sectionName) {
        $('#' + item).show();
      } else {
        $('#' + item).hide();
      }
    });
  };

  $trigBtn.on("click", function(){
    var args = [rhizome.userId];
    console.log("triger at user", args);
    rhizome.send('/haze/trig', args);
  });


  rhizome.on('connected', function() {
    rhizome.send('/sys/subscribe', ['/section']);
    rhizome.send('/get_section');
  })


  rhizome.start(function(err) {

    if (err) return alert(err)

    var userId = rhizome.userId;

    gyro.frequency = 1000;
    
    gyro.startTracking(function(o) {
      var args = [userId, o.x, o.y, o.z, o.alpha, o.beta, o.gamma];
      var status = args.slice(1).join(", ");
      $statusData.text(status);

      rhizome.send('/haze/update', args);

    });
  })
  
  rhizome.on('message', function(address, args) {
    if (address === '/sys/subscribed') {
      console.log('successfully subscribed to ' + args[0])
    }
    else if (address === '/section') {
      setSection(args);
    }
  })
})
