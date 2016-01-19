var NanoWindow = function () 
{
    var setPos = function (x, y) {
        NanoUtility.winset("pos", x + "," + y);
    };
    var setSize = function (w, h) {
       NanoUtility.winset("size", w + "," + h);
    };

    var init = function () {
        if(NanoStateManager.getData().config.user.fancy) {
            fancyChrome();
            attachButtons();
            attachDrag();
            attachResize();
        }
    };
    var fancyChrome = function() {
        NanoUtility.winset("titlebar", 0);
        NanoUtility.winset("can-resize", 0);
        $('.fancy').show();
        $('#uiTitleFluff').css("right", "65px");
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
    var dragging, xDrag, yDrag;
    var attachDrag = function() {
        $("#uiTitleWrapper").on("mousemove", function (event) {
            drag();
        });
        $("#uiTitleWrapper").on("mousedown", function (event) {
            dragging = true;
        });
        $("#uiTitleWrapper").on("mouseup", function (event) {
            dragging = false;
            xDrag = null;
            yDrag = null;
        });
    };
    var drag = function(event) {
        var x, y;
        if (event == null) {
            event = window.event;
        }

        if (!dragging) {
            return;
        }

        if (xDrag == null) {
            xDrag = event.screenX;
        }

        if (yDrag == null) {
            yDrag = event.screenY;
        }

        x = (event.screenX - xDrag) + (window.screenLeft);
        y = (event.screenY - yDrag) + (window.screenTop);

        setPos(x, y);
        xDrag = event.screenX;
        yDrag = event.screenY;
    };
    var resizing, xResize, yResize;
    var attachResize = function () {
        $("#resize").on("mousemove", function (event) {
            resize();
        });
        $("#resize").on("mousedown", function (event) {
            resizing = true;
        });
        $("#resize").on("mouseup", function (event) {
            resizing = false;
        });
    };
    var resize = function() {
        var x, y;
        if (event == null) {
            event = window.event;
        }

        if (!resizing) {
            return;
        }

        if (xResize == null) {
            xResize = event.screenX;
        }

        if (yResize == null) {
            yResize = event.screenY;
        }

        x = Math.max(150, (event.screenX - xResize) + window.innerWidth);
        y = Math.max(150, (event.screenY - yResize) + window.innerHeight);
        setSize(x, y);
        xResize = event.screenX;
        yResize = event.screenY;
    };
    return {
        init: function () { //crazy but ensures correct load order (nanoutil - nanotemplate - nanowindow)
            $(document).on('templatesLoaded', function () {
                init();
            }); 
        }
    };
}();