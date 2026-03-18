#if !macro
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import developer.display.*;
import developer.display.mouseEvent.*;

//Spine
import openfl.Assets;

import spine.animation.AnimationStateData;
import spine.animation.AnimationState;
import spine.atlas.TextureAtlas;
import spine.SkeletonData;
import spine.flixel.SkeletonSprite;
import spine.flixel.FlixelTextureLoader;

#if flxanimate
import flxanimate.*;
import general.flxanimate.PsychFlxAnimate as FlxAnimate;
#end

// Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

// Lime 
import lime.system.BackendThread;
import haxe.MainLoop;

// Mobile Controls
import mobile.objects.MobileControls;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import mobile.backend.Data;
import mobile.backend.SUtil;

// Android
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
#end

// Discord API
#if DISCORD_ALLOWED
import general.backend.Discord;
#end

// Psych
#if ACHIEVEMENTS_ALLOWED
import general.backend.Achievements;
#end

import general.backend.language.Language;
import general.backend.Paths;
import general.backend.Cache;
import general.backend.Controls;
import general.backend.CoolUtil;
import general.backend.MusicBeatState;
import general.backend.MusicBeatSubstate;
import general.backend.CustomFadeTransition;
import general.backend.ClientPrefs;
import general.backend.Conductor;
import general.backend.Mods;
import general.backend.ui.*; // Psych-UI
import general.backend.data.*;
import general.backend.mouse.*;
import general.backend.gc.*;

#if hxvlc
import general.objects.VideoSprite;
#end

import general.shapeEX.*;

import general.objects.Alphabet;
import general.objects.BGSprite;
import general.objects.AudioDisplay;
import general.objects.state.general.*;

import general.shaders.flixel.system.FlxShader;

import states.loadingState.LoadingState;

import games.funkin_legacy.PlayState;
import games.funkin_legacy.stages.base.BaseStage;
import games.funkin_legacy.backend.Difficulty;
import games.funkin_legacy.backend.ExtraKeysHandler;

using StringTools;
#end

