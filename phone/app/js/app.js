$(function() {

  var $controlSection  = $("#control");
  var $statusData = $("#status-data");
  var $trigBtn = $('#trig');
  var $saveBtn = $('#save');
  var $slider = $('#slider');
  var canvas = document.getElementById("noise");
  var p5;

  $("button").on("click", function(e){
    $(this).css({
      "background-color": "white",
      "color": "black"
    });
    e.preventDefault();
  })
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
    
    var offset = $(canvas).offset();
    var offsetLeft = offset.left;
    var offsetTop = offset.top;

    var hammertime = new Hammer(canvas, options);

  
    var options = {
      preventDefault: true
    };

    var hammertime = new Hammer(canvas, options);
    
    hammertime.on("transform", function(event){ 
      // var scale = event.gesture.scale;
      // // p5.setScale(scale);
      // console.log(scale);
    });
    
    hammertime.on("tap hold", function(event){
      var touch = event.gesture.touches[0];
      var x = touch.pageX - offsetLeft;
      var y = touch.pageY - offsetTop;
      p5.addForce(x, y);
    });

    hammertime.on("doubletap", function(event){
      p5.reverse();
    });

    hammertime.on("swipe", function(event){
      var x = event.gesture.deltaX;
      var y = event.gesture.deltaY;
      p5.swipe(x, y);
    });

    console.log(rhizome.userId);

    gyro.frequency = 2;
    gyro.startTracking(function(o){
      var args = [o.x, o.y, o.z, o.alpha, o.beta, o.gamma];

      var xAcc = Math.ceil(Math.abs(o.x)) * 5;
      var color = "rgb(" + xAcc +',' + xAcc + ',' + xAcc + ")";
      document.body.style.background = color;

      var margin = Math.min(Math.max(5 + o.beta/2, 5), 50)

      $controlSection.css({
        "margin-top": margin,
        "position": "relative",
        "left": o.gamma/3
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
