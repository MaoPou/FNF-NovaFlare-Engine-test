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
import flxanimate.PsychFlxAnimate as FlxAnimate;
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
import backend.Discord;
#end

// Psych
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

import backend.language.Language;
import backend.Paths;
import backend.Cache;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Mods;
import backend.ui.*; // Psych-UI
import backend.data.*;
import backend.mouse.*;
import backend.gc.*;

#if hxvlc
import objects.VideoSprite;
#end

import shapeEx.*;

import objects.Alphabet;
import objects.BGSprite;
import objects.AudioDisplay;
import objects.state.general.*;

import shaders.flixel.system.FlxShader;

import states.loadingState.LoadingState;

import games.funkin.PlayState;
import games.funkin.stages.base.BaseStage;
import games.funkin.backend.Difficulty;
import games.funkin.backend.ExtraKeysHandler;

using StringTools;
#end

