using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.ActivityMonitor;

class TotallySimpleView extends WatchUi.WatchFace {

	// change the color based on closeness to step goal
	var stepGoal = 0;
	// custom font for the time 
	var timeFont = null;

    function initialize() {
        WatchFace.initialize();
        stepGoal = ActivityMonitor.getInfo().stepGoal;
        timeFont = loadResource(Rez.Fonts.roboto);
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }
    
    function drawHours() {
    }
    
    function drawMinutes() {
    }
    
 	function drawSeconds() {
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var clockTime = System.getClockTime();
        var minutes = clockTime.min;
        var seconds = clockTime.sec;
        var hourString = Lang.format("$1$", [clockTime.hour]);
        
        // + draw background circle 
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillCircle(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2);
        // - draw background circle
        
        // + draw minute arc
        var degreeOffset = minutes * 6; // every minute = 6 degrees around circle
        var startDegree = 90;
        var endDegree = startDegree - degreeOffset;
        if (endDegree < 0) {
        	endDegree = 360 + endDegree; 
        }
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
        dc.setPenWidth(15);
        dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2, 1, startDegree, endDegree); // 1 == the arc direction. opposite would be 0
        // - draw minute arc
        
        // + draw time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timeFontSize = 64;
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2) - (timeFontSize / 2), timeFont, hourString, Graphics.TEXT_JUSTIFY_CENTER); 
        // - draw time
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
