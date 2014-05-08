$(function() {

  var getOffsetLeft = function ( elem ){
      var offsetLeft = 0;
      do {
        if ( !isNaN( elem.offsetLeft ) )
        {
            offsetLeft += elem.offsetLeft;
        }
      } while( elem = elem.offsetParent );
      return offsetLeft;
  }

  var getOffsetTop = function( elem ){
      var offsetTop = 0;
      do {
        if ( !isNaN( elem.offsetTop ) )
        {
            offsetTop += elem.offsetTop;
        }
      } while( elem = elem.offsetParent );
      return offsetTop;
  }

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
    var ball = p5.trig();
    // var o = gyro.getOrientation();
    var args = [rhizome.userId, ball[0], ball[1], ball[2], ball[3]];
    console.log("triger at user", args);
    rhizome.send('/haze/trig', args);
    // p5.setControl(0, o.beta, o.gamma);
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
    
    var offsetLeft = getOffsetLeft(canvas);
    var offsetTop = getOffsetTop(canvas);

    var hammertime = new Hammer(canvas, options);

  
    var options = {
      dragLockToAxis: true,
      holdThreshold: 1,
      dragBlockHorizontal: true,
      preventDefault: true
    };

    var hammertime = new Hammer(canvas, options);
    
    hammertime.on("rotate pitch transform", function(event){ 
      var angle = event.gesture.angle;
      p5.rotateV(angle);
    });
    
    hammertime.on("tap hold", function(event){
      var touch = event.gesture.touches[0];
      var x = touch.pageX - offsetLeft;
      var y = touch.pageY - offsetTop;
      console.log(x, y);
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
