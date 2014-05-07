$(function() {

  var $controlSection  = $("#control");
  var $statusData = $("#status-data");
  var $trigBtn = $('#trig');
  var $saveBtn = $('#save');
  var $slider = $('#slider');
  var canvas = document.getElementById("noise");
  var p5;

  var setSection = function(sectionName) {
    var sectionList = ["welcome", "control", "schedule", "end"];

    sectionList.map(function(item){
      if(item==sectionName) {
        $('#' + item).show();
      } else {
        $('#' + item).hide();
      }
    });
  };


  $trigBtn.on("click", function(e){
    var o = gyro.getOrientation();
    var args = [rhizome.userId, o.x, o.y, o.z, o.alpha, o.beta, o.gamma];
    var sliderVal = parseInt($slider.attr('data-slider'));
    console.log("triger at user", args);
    rhizome.send('/haze/trig', args);
    p5.setControl(sliderVal, o.beta, o.gamma);

    e.preventDefault();
  });

  $saveBtn.on("click", function(e){
    var image = canvas.toDataURL("image/png");
    window.location.href=image;
    e.preventDefault();
  });


  rhizome.on('connected', function() {
    rhizome.send('/sys/subscribe', ['/section']);
    rhizome.send('/get_section');
  })


  rhizome.start(function(err) {
    if (err) return alert(err)

    setSection("control");

    $(document).foundation();

    p5 = Processing.getInstanceById("noise");
    p5.setUserId(rhizome.userId);

    console.log(rhizome.userId);

    gyro.frequency = 2;
    gyro.startTracking(function(o){
      var args = [o.x, o.y, o.z, o.alpha, o.beta, o.gamma];

      var xAcc = Math.ceil(Math.abs(o.x)) * 5;
      var color = "rgb(" + xAcc +',' + xAcc + ',' + xAcc + ")";
      document.body.style.background = color;

      var margin = Math.min(Math.max(5 + o.beta/3, 5), 50)
      $controlSection.css({
        "margin-top": margin,
        "position": "relative",
        "left": o.gamma/4
      });
    })

  })

  
  rhizome.on('message', function(address, args) {
    if (address === '/sys/subscribed') {
      console.log('successfully subscribed to ' + args[0])
    }
    else if (address === '/section') {
      setSection(args[1]);
    }
  })
})
