var NanoWindow = function () 
{
    var offsetX, offsetY;
    var minWidth = 280;
    var minHeight = 140;

    var setPos = function (x, y) {
        NanoUtility.winset("pos", x + "," + y);
    };
    var setSize = function (w, h) {
       NanoUtility.winset("size", w + "," + h);
    };

    var obeyLimits = function () {
        // Alignment (Thanks Goon (CC BY-NC-SA v3))
        var prevX = window.screenLeft;
        var prevY = window.screenTop;
        //Put the window at top left
        setPos(0, 0);
        //Get any offsets still present
        offsetX = window.screenLeft;
        offsetY = window.screenTop;
        // Clamp it to the viewport
        var clampedX = prevX - offsetX;
        var clampedY = prevY - offsetY;
        clampedX = clampedX < offsetX ? 0 : clampedX;
        clampedY = clampedY < offsetY ? 0 : clampedY;
        // Put it back
        setPos(clampedX, clampedY)
        // Done with alignment

        // Size constraints
        var height = $(window).height();
        var width = $(window).width();
        if($("body").height() >= ($(window).height() - 29)) { // Scrollbar!!!
            width += 17 // 17 pixels is the width of a scrollbar
        }
        if($(document).width() > $(window).width()) { // Horizontal Scrollbar!!!
            height += 17
        }
        var newWidth = Math.max(minWidth, width);
        var newHeight = Math.max(minHeight, height);
        setSize(newWidth, newHeight);
    };

    var init = function () {
        /* We want nanoUI windows to obey the limits regardless, 
        and we're hijacking this library to do so, even if fancy mode is turned off.
        To be fair, this doesn't stop the user from shrinking them past their intended limit when they're not in fancy mode, 
        but it's a nice safeguard against shoddily-coded UIs. */
        obeyLimits();

        if(!NanoStateManager.getData().config.user.fancy) {
            return
        }

        fancyChrome();
        // ... but when fancy mode is turned on, we have to do it again to make sure
        // that the window offsets are correct for the slightly different window.
        obeyLimits();
 
        attachButtons();
        attachDragAndResize();
    };

    var fancyChrome = function() {
        NanoUtility.winset("titlebar", 0);
        NanoUtility.winset("can-resize", 0);
        NanoUtility.winset("transparent-color", "#FF00E4")
        $('.fancy').show();
        $('#uiTitleFluff').css("right", "72px");
        $('.statusicon').css("left", "34px");
        $('#uiTitleText').css("left", "66px");
    };

    var attachButtons = function() {
        var close = function() {
            return NanoUtility.close();
        };
        var minimize = function() {
            return NanoUtility.winset("is-minimized", "true");
        };
        $(".close").on("click", function (event) {
            close();
        });
        $(".minimize").on("click", function (event) {
            minimize();
        });
    };

    var attachDragAndResize = function() {
        /* Drag */
        $("body").on("mousemove", "#uiTitleWrapper", function (ev) {
            drag(ev);
        });

        $("body").on("mousedown", "#uiTitleWrapper", function () {
            dragging = true;
            if ($(this)[0].setCapture) { $(this)[0].setCapture(); }
        });

        $("body").on("mouseup", "#uiTitleWrapper", function () {
            dragging = false;
            if ($(this)[0].releaseCapture) { $(this)[0].releaseCapture(); }
        });

        /* Resize */
        $("body").on("mousemove", "div.resizeArea", function (ev) {
            resize.call(this, ev);
        });

        $("body").on("mousedown", "div.resizeArea", function () {
            resizing = true;
            if (this.setCapture) { this.setCapture(); }
        })

        $("body").on("mouseup", "div.resizeArea", function () {
            resizing = false;
            if (this.releaseCapture) { this.releaseCapture(); }
        });
    };

    /* Stolen Goon code ftw (CC BY-NC-SA v3.0) */
    var dragging, lastX, lastY;
    var drag = function (ev) {
        ev = ev || window.event;
        if (lastX === ev.screenX && lastY === ev.screenY) {
            return
        }

        if (lastX === undefined) {
            lastX = ev.screenX;
            lastY = ev.clientY;
        }

        if (dragging) {
            var dx = (ev.screenX - lastX);
            var dy = (ev.screenY - lastY);
            dx += window.screenLeft - offsetX;
            dy += window.screenTop - offsetY;

            setPos(dx, dy);
        }

        lastX = ev.screenX;
        lastY = ev.screenY;
    }

    var resizing, resizeWorking
    var resize = function (ev) {
        if (resizeWorking) {
            return;
        }

        resizeWorking = true;
        ev = ev || window.event;

        if (lastX === undefined) {
            lastX = ev.screenX - offsetX;
            lastY = ev.screenY - offsetY;
        }

        if (resizing) {
            var width = $(window).width();
            var height = $(window).height();

            if($("body").height() >= ($(window).height() - 29)) { // Vertical Scrollbar!!!
                width += 17 // 17 pixels is the width of a scrollbar
            }

            if($(document).width() > $(window).width()) { // Horizontal Scrollbar!!!
                height += 17
            }

            var rx = Number($(this).attr("rx"));
            var ry = Number($(this).attr("ry"));
            
            var dx = ((ev.screenX-offsetX) - lastX);
            var dy = ((ev.screenY-offsetY) - lastY);
            
            var newX = window.screenLeft - offsetX;
            var newY = window.screenTop - offsetY;
            
            var newW = width + (dx * rx);
            if(rx == -1){
                newX += dx;
            }
            var newH = height + (dy * ry);
            if(ry == -1){
                newY += dy;
            }
            
            newW = Math.max(minWidth, newW);
            newH = Math.max(minHeight, newH); 
            setPos(newX, newY);
            setSize(newW, newH);
        }

        lastX = ev.screenX - offsetX;
        lastY = ev.screenY - offsetY;

        resizeWorking = false;
    };
    /* End stolen Goon code */

    return {
        init: function () { //crazy but ensures correct load order (nanoutil - nanotemplate - nanowindow)
            $(document).on('templatesLoaded', function () {
                init();
            }); 
        }
    };
}();