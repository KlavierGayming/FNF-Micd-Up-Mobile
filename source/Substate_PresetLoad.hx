package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import MainVariables._variables;

using StringTools;

class Substate_PresetLoad extends MusicBeatSubstate
{
    public static var curSelected:Int = 0;

    var goingBack:Bool = false;

    var camLerp:Float = 0.16;

    var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

    var initPresets:Array<Dynamic>;
    private var grpPresets:FlxTypedGroup<Alphabet>;
    var presetText:Alphabet;

    public static var coming:String = "";

    public function new()
    {
        super();

        switch (coming)
	    {
			case "Modifiers":
				initPresets = Substate_Preset.presets;
			case "Marathon":
				initPresets = Marathon_Substate.presets;
			case "Survival":
				initPresets = Survival_Substate.presets;
		}

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.y = 750;
        FlxTween.tween(blackBarThingie, { 'scale.x': 700}, 0.5, { ease: FlxEase.expoOut});

        grpPresets = new FlxTypedGroup<Alphabet>();
		add(grpPresets);

		for (i in 0...initPresets.length)
		{
			presetText = new Alphabet(0, (70 * i) + 30, initPresets[i], true, false);
			presetText.itemType = "Vertical";
			presetText.targetY = i;
            presetText.scrollFactor.set();
			grpPresets.add(presetText);
            presetText.alpha = 0;
            presetText.x = 308;
            FlxTween.tween(presetText, { alpha: 1}, 0.7, { ease: FlxEase.expoOut});
		}

        new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				selectable = true;
			});
//crap but better
        #if mobileC
        addVirtualPad(UP_DOWN, A_B);
        #end
    }

    var selectable:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        blackBarThingie.y = 360 - blackBarThingie.height/2;
        blackBarThingie.x = 640 - blackBarThingie.width/2;

        if (selectable && !goingBack)
        {
            if (controls.UP_P)
            {
                changeSelection(-1);
            }
            if (controls.DOWN_P)
            {
                changeSelection(1);
            }

            if (controls.BACK)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'), _variables.svolume/100);
                    FlxTween.tween(blackBarThingie, { 'scale.y': 0, 'scale.x': 2200}, 0.5, { ease: FlxEase.expoIn});

                    grpPresets.kill();

                    new FlxTimer().start(0.5, function(tmr:FlxTimer)
                        {
                            FlxG.state.closeSubState();
                            switch (coming)
                            {
                                case "Modifiers":
                                    FlxG.state.openSubState(new Substate_Preset());
                                case "Marathon":
                                    FlxG.state.openSubState(new Marathon_Substate());
                                case "Survival":
                                    FlxG.state.openSubState(new Survival_Substate());
                            }
                        });
                }
        
            if (controls.ACCEPT)
            {
                switch (coming)
                {
                    case "Modifiers":
                        ModifierVariables.loadPreset(initPresets[curSelected]);
                        MenuModifiers.calculateStart();
                    case "Marathon":
                        MenuMarathon.loadPreset(initPresets[curSelected]);
                    case "Survival":
                        MenuSurvival.loadPreset(initPresets[curSelected]);
                }

                goingBack = true;
                        
                FlxTween.tween(blackBarThingie, { 'scale.y': 750, 'scale.x': 2200}, 0.5, { ease: FlxEase.expoIn});
                FlxTween.tween(FlxG.camera, { y:-720 }, 0.5, { ease: FlxEase.expoIn});

                FlxG.sound.play(Paths.sound('confirmMenu'), _variables.svolume/100);
                new FlxTimer().start(0.5, function(tmr:FlxTimer)
                {
                    FlxG.resetState();
                    MenuModifiers.substated = false;
                });
            }
        }
    }

    function changeSelection(change:Int = 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4*_variables.svolume/100);
    
            curSelected += change;
    
            if (curSelected < 0)
                curSelected = initPresets.length - 1;
            if (curSelected >= initPresets.length)
                curSelected = 0;
    
            // selector.y = (70 * curSelected) + 30;
    
            var bullShit:Int = 0;
    
            for (item in grpPresets.members)
            {
                item.targetY = bullShit - curSelected;
                bullShit++;
    
                item.alpha = 0.6;
                // item.setGraphicSize(Std.int(item.width * 0.8));
    
                if (item.targetY == 0)
                {
                    item.alpha = 1;
                    // item.setGraphicSize(Std.int(item.width));
                }
            }
        }
}