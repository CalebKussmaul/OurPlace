var zoom = 10;
var canvas_offset_x = 0;
var canvas_offset_y = 0;
var hover_x = 0;
var hover_y = 0;
var down = false;
var dragging = false;
var touch_x = 0;
var touch_y = 0;
var gesture = false;
var mobile_center_x;
var mobile_center_y;

var game_data = {
blocks: []
};

var selected_block = {
type:"color",
color:"#F00"
}

function onDown() {
  down = true;
}

function onMove(x, y, movement_x, movement_y, canvas, ctx, mobile) {
  if(mobile) {
    hover_x = Math.round((mobile_center_x - canvas_offset_x)/zoom);
    hover_y = Math.round((mobile_center_y - canvas_offset_y)/zoom);
  }
  if(down) {
    dragging = true;
    canvas_offset_x += movement_x;
    canvas_offset_y += movement_y;
  }
  else {
    hover_x = Math.round((x - canvas_offset_x)/zoom);
    hover_y = Math.round((y - canvas_offset_y)/zoom);
  }
  draw(canvas, ctx);
}

function onUp(x, y, canvas, ctx) {
  down = false;
  if(dragging) {
    dragging = false;
    return;
  }
  selected_block.x = Math.round((x - canvas_offset_x) / zoom);
  selected_block.y = Math.round((y - canvas_offset_y) / zoom);
  place(selected_block, canvas, ctx);
}

function onZoom(z, canvas, ctx, mobile) {
  if(mobile) {
    hover_x = Math.round((mobile_center_x - canvas_offset_x)/zoom);
    hover_y = Math.round((mobile_center_y - canvas_offset_y)/zoom);
  }
  zoom *= z;
  zoom = Math.max(1, Math.min(100, zoom));
  draw(canvas, ctx);
}

$(document).ready(function() {
                  var canvas = $("#game");
                  mobile_center_x = canvas.width()/2;
                  mobile_center_y = canvas.height()/2;
                  canvas[0].width = canvas.width();
                  canvas[0].height = canvas.height();
                  canvas_offset_x = canvas.width()/2;
                  canvas_offset_y = canvas.height()/2;
                  var ctx = canvas[0].getContext('2d');
                  ctx.imageSmoothingEnabled = false;
                  refresh(canvas, ctx);
                  setInterval(function() {
                              refreshTimer();
                              }, 500);
                  
                  canvas
                  .mousemove(function(e) {
                             onMove(e.clientX, e.clientY, e.originalEvent.movementX, e.originalEvent.movementY, canvas, ctx, false);
                             })
                  .on("touchmove", function(e) {
                      e.preventDefault();
                      dragging = true;
                      if(gesture) {
                        return;
                      }
                      var touch = e.originalEvent.touches[0];
//                      if(e.originalEvent.touches.length > 1) {
//                        down = true;
//                      }
                      onMove(mobile_center_x, mobile_center_y, (touch.clientX - touch_x), (touch.clientY - touch_y),  canvas, ctx, true);
                      touch_x = touch.clientX;
                      touch_y = touch.clientY;
                      })
                  .on("gesturechange", function(e) {
                      e.preventDefault();
                      gesture = true;
                      onZoom((e.originalEvent.scale-1)/10 +1, canvas, ctx, true);
                      })
                  .on("gestureend", function(e) {
                      e.preventDefault();
                      window.setTimeout(function() {gesture = false;}, 1000);
                      })
                  .mouseup(function (e) {
                           onUp(e.clientX, e.clientY, canvas, ctx);
                           })
                  .on("touchend", function(e) {
                      e.preventDefault();
                      onUp(mobile_center_x, mobile_center_y, canvas, ctx);
                      })
                  .mousedown(function(e) {
                             onDown();
                             })
                  .on("touchstart", function(e) {
                      e.preventDefault();
                      var touch = e.originalEvent.touches[0];
                      touch_x = touch.clientX;
                      touch_y = touch.clientY;
                      onDown();
                      })
                  .on("wheel", function(e) {
                      onZoom(1 +e.originalEvent.deltaY/300.0, canvas, ctx, false);
                      });
                  $(window).resize(function(e) {
                                   e.preventDefault();
                                   canvas[0].width = canvas.width();
                                   canvas[0].height = canvas.height();
                                   draw(canvas, ctx);
                                   });
                  $(".color-block").click(function(e) {
                                          selected_block = {
                                          type:"color",
                                          color:$(this).css('backgroundColor')
                                          };
                                          $(".color-block").removeClass("selected-block");
                                          $(this).addClass("selected-block");
                                          });
                  });

function refreshTimer() {
  if(game_data.timeout == null) {
    $("#timer").text("-:--");
    return;
  }
  var secsRemaining = Math.round((Date.parse(game_data.timeout) - Date.now())/1000);
  
  if(secsRemaining <= 0) {
    $("#timer").text("0:00");
  } else {
    var mins = Math.floor(secsRemaining/60);
    var secs = secsRemaining % 60;
    if(secs < 10)
      secs = "0"+secs;
    $("#timer").text(mins+":"+secs);
  }
}

function refresh(canvas, ctx) {
  $.ajax({
         url: "./world",
         method: "GET",
         contentType: "application/json",
         })
  .done(function (data) {
        game_data = data;
        console.log(data.timeout);
        draw(canvas, ctx);
        })
  .fail(function (jqXHR, textStatus, errorThrown) {
        window.alert(textStatus);
        });
}

function place(block, canvas, ctx) {
  $.ajax({
         url: "./place_block",
         data: JSON.stringify({block: block}),
         method: "POST",
         contentType: "application/json",
         success: function (data) {
           game_data = data;
           draw(canvas, ctx);
         },
         statusCode: {
              401: function() {
                promptLogin();
              }
            }
         });
}

function promptLogin() {
  if (window.confirm("You need to log in before you can place blocks. Log in with Google?")) {
    window.location.href = "/login";
  }
}

function draw(canvas, ctx) {
  
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, canvas[0].width, canvas[0].height);
  ctx.translate(canvas_offset_x, canvas_offset_y);
  ctx.translate(.5, .5);
  ctx.scale(zoom, zoom);
  
  for(idx in game_data.blocks) {
    block =game_data.blocks[idx];
    ctx.fillStyle = block.color;
    ctx.fillRect(block.x, block.y, 1, 1);
  }
  ctx.strokeStyle = "#FF0000";
  ctx.lineCap="round";
  ctx.lineWidth = Math.max(1/zoom, .1);
  ctx.strokeRect(hover_x, hover_y, 1 + .5/zoom, 1 + .5/zoom);
}
