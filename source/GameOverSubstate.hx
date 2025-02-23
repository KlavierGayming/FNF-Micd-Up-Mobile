package;

import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import MainVariables._variables;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var camLerp:Float = 0.14;
	var zoomLerp:Float = 0.09;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daStage:String = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'tankStage2':
				daBf = 'bf-holding-gf-dead';
			default:
				daBf = 'bf';
		}

		PlayState.ended = false;

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(PlayState.cameraX, PlayState.cameraY, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix ,'shared'),_variables.svolume/100);
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		FlxG.camera.flash(0xFF0000, 0.4);

		if (PlayState.gameplayArea == "Marathon" || PlayState.gameplayArea == "Endless" || PlayState.gameplayArea == "Survival")
		{
			var press:FlxText = new FlxText(20, 15, 1200, "GAME OVER!\nGo back to try again.", 32);
			press.alignment = CENTER;
			press.scrollFactor.set();
			press.setFormat(Paths.font("vcr.ttf"), 72);
			press.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
			press.updateHitbox();
			add(press);

			press.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

			press.alpha = 0;
			FlxTween.tween(press, {alpha: 1, y: 550 - press.height}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		}
		//crap but better
        #if mobileC
		addVirtualPad(NONE, A_B);
		
		var camcontrol = new FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		_virtualpad.cameras = [camcontrol];
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var daStage2:String = PlayState.curStage;

		if (controls.ACCEPT && PlayState.gameplayArea != "Marathon" && PlayState.gameplayArea != "Endless" && PlayState.gameplayArea != "Survival")
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			PlayState.curDeaths = 0;
			FlxG.sound.music.stop();

			switch (PlayState.gameplayArea)
			{
				case "Story":
					FlxG.switchState(new MenuWeek());
				case "Freeplay":
					FlxG.switchState(new MenuFreeplay());
				case "Marathon":
					FlxG.switchState(new MenuMarathon());
				case "Endless":
					FlxG.switchState(new MenuEndless());
				case "Survival":
					FlxG.switchState(new MenuSurvival());
				case "Charting":
					FlxG.switchState(new ChartingState());
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, zoomLerp/(_variables.fps/60));

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			FlxG.camera.follow(camFollow, LOCKON, camLerp);
			camFollow.x = FlxMath.lerp(camFollow.x, bf.getGraphicMidpoint().x, (camLerp * _variables.cameraSpeed)/(_variables.fps/60));
			camFollow.y = FlxMath.lerp(camFollow.y, bf.getGraphicMidpoint().y, (camLerp * _variables.cameraSpeed)/(_variables.fps/60));
			if (daStage2 == 'tankStage' || daStage2 == 'tankStage2')
			{
			    FlxG.sound.play(Paths.sound('jeffGameover-' + FlxG.random.int(1, 25), 'week7'));
			}
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame >= 16)
			shake += 0.00007;

		if ((bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame >= 16) || (bf.animation.curAnim.name != 'firstDeath' && bf.animation.curAnim.name != 'deathConfirm') )
		{
			FlxG.camera.shake(shake, 0.05);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix, 'shared'),_variables.mvolume/100);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	var shake:Float = 0;

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix, 'shared'), _variables.mvolume/100);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
