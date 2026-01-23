#if !macro
// Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

// Psych
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

#if hxvlc
import backend.VideoSprite;
#end

// Android
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
#end

// Mobile Controls
import mobile.objects.MobileControls;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import mobile.flixel.input.FlxMobileInputID;
import mobile.backend.Data;
import mobile.backend.SUtil;

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import language.Language;

import backend.Paths;
import backend.Cache;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;
import backend.ui.*; // Psych-UI
import backend.data.*;
import backend.mouse.*;
import backend.gc.*;
import backend.extraKeys.ExtraKeysHandler;

import objects.Alphabet;
import objects.BGSprite;
import objects.AudioDisplay;

import developer.display.mouseEvent.*;
import developer.display.*;

import shapeEx.*;
import objects.state.general.*;

import states.PlayState;
import states.LoadingState;

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

import sound.FlxStreamSound;

//Spine
import spine.animation.AnimationStateData;
import spine.animation.AnimationState;
import openfl.Assets;
import spine.atlas.TextureAtlas;
import spine.SkeletonData;
import spine.flixel.SkeletonSprite;
import spine.flixel.FlixelTextureLoader;

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
import shaders.flixel.system.FlxShader;

using StringTools;
#end
