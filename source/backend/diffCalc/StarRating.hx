package backend.diffCalc;
import backend.Section.SwagSection;
import backend.Song.SwagSong;
import backend.Song;
import backend.ClientPrefs;

class StarRating {
    public static function calcForSong(song:SwagSong):Float {
        if (song == null || song.notes == null || song.notes.length == 0) return 0;
        var objs:Array<ManiaObj> = [];
        var totalColumns = 0;
        for (sec in song.notes) {
            var notes:Array<Dynamic> = sec.sectionNotes;
            if (notes == null) continue;
            for (n in notes) {
                if (n == null || n.length < 2) continue;
                var rawLane:Int = Std.int(n[1]);
                if (rawLane < 0) continue;
                if (!includeNote(sec, rawLane, song)) continue;
                if (rawLane + 1 > totalColumns) totalColumns = rawLane + 1;
            }
        }
        if (totalColumns <= 0) return 0;
        for (sec in song.notes) {
            var notes:Array<Dynamic> = sec.sectionNotes;
            if (notes == null) continue;
            for (n in notes) {
                if (n == null || n.length < 2) continue;
                var rawLane:Int = Std.int(n[1]);
                if (rawLane < 0) continue;
                if (!includeNote(sec, rawLane, song)) continue;
                var start:Float = n[0];
                var sustain:Float = (n.length >= 3 && n[2] != null) ? n[2] : 0.0;
                var end:Float = start + (sustain > 0 ? sustain : 0);
                objs.push({ startTime: start, endTime: end, column: rawLane, index: 0, deltaTime: 0, previousIndex: -1, previousStart: 0, previousHitByColumn: [], columnStrainTime: 0 });
            }
        }
        if (objs.length <= 1) return 0;
        objs.sort(function(a, b) return a.startTime < b.startTime ? -1 : (a.startTime > b.startTime ? 1 : 0));
        var perColumn:Array<Array<Int>> = [];
        for (i in 0...totalColumns) perColumn.push([]);
        var prevByColumn:Array<Int> = [];
        for (i in 0...totalColumns) prevByColumn.push(-1);
        var objects:Array<ManiaObj> = [];
        for (i in 1...objs.length) {
            var prev = objs[i - 1];
            var cur = objs[i];
            var idx = objects.length;
            var delta = cur.startTime - prev.startTime;
            var prevHit:Array<Int> = prevByColumn.copy();
            var col = cur.column;
            var colList = perColumn[col];
            var prevInCol:Int = colList.length > 0 ? colList[colList.length - 1] : -1;
            var colStrainTime:Float = prevInCol >= 0 ? cur.startTime - objects[prevInCol].startTime : cur.startTime;
            var m:ManiaObj = {
                startTime: cur.startTime,
                endTime: cur.endTime,
                column: col,
                index: idx,
                deltaTime: delta,
                previousIndex: i - 1,
                previousStart: prev.startTime,
                previousHitByColumn: prevHit,
                columnStrainTime: colStrainTime
            };
            objects.push(m);
            colList.push(idx);
            prevByColumn[col] = idx;
        }
        var individualStrains:Array<Float> = [];
        for (i in 0...totalColumns) individualStrains.push(0);
        var highestIndividualStrain:Float = 0;
        var overallStrain:Float = 1;
        var currentStrain:Float = 0;
        var sectionLength:Int = 400;
        var decayWeight:Float = 0.9;
        var currentSectionPeak:Float = 0;
        var currentSectionEnd:Float = Math.ceil(objects[0].startTime / sectionLength) * sectionLength;
        var strainPeaks:Array<Float> = [];
        for (obj in objects) {
            while (obj.startTime > currentSectionEnd) {
                strainPeaks.push(currentSectionPeak);
                var offset = currentSectionEnd;
                var prevStart = obj.previousStart;
                var initial = applyDecay(highestIndividualStrain, offset - prevStart, 0.125) + applyDecay(overallStrain, offset - prevStart, 0.30);
                currentSectionPeak = initial;
                currentSectionEnd += sectionLength;
            }
            var col = obj.column;
            individualStrains[col] = applyDecay(individualStrains[col], obj.columnStrainTime, 0.125);
            var indAdd = evaluateIndividual(obj, objects, totalColumns);
            individualStrains[col] += indAdd;
            highestIndividualStrain = obj.deltaTime <= 1 ? Math.max(highestIndividualStrain, individualStrains[col]) : individualStrains[col];
            overallStrain = applyDecay(overallStrain, obj.deltaTime, 0.30);
            var overallAdd = evaluateOverall(obj, objects, totalColumns);
            overallStrain += overallAdd;
            var sValueOf = highestIndividualStrain + overallStrain - currentStrain;
            currentStrain += sValueOf;
            currentSectionPeak = Math.max(currentStrain, currentSectionPeak);
        }
        var peaks:Array<Float> = [];
        for (p in strainPeaks) if (p > 0) peaks.push(p);
        if (currentSectionPeak > 0) peaks.push(currentSectionPeak);
        peaks.sort(function(a, b) return a > b ? -1 : (a < b ? 1 : 0));
        var difficulty:Float = 0;
        var weight:Float = 1;
        for (p in peaks) {
            difficulty += p * weight;
            weight *= decayWeight;
        }
        return difficulty * 0.018;
    }
    static function includeNote(sec:SwagSection, rawLane:Int, song:SwagSong):Bool {
        var playOpp = ClientPrefs.data.playOpponent == true;
        var gottaHit:Bool = sec.mustHitSection;
        if (Song.isNewVersion) {
            gottaHit = (rawLane < 4);
        } else {
            if (rawLane > song.mania) {
                gottaHit = !sec.mustHitSection;
            }
        }
        return playOpp ? !gottaHit : gottaHit;
    }
    static inline function applyDecay(value:Float, deltaTime:Float, decayBase:Float):Float {
        return value * Math.pow(decayBase, deltaTime / 1000);
    }
    static function evaluateIndividual(obj:ManiaObj, objects:Array<ManiaObj>, totalColumns:Int):Float {
        var start = obj.startTime;
        var end = obj.endTime;
        var holdFactor:Float = 1.0;
        for (c in 0...totalColumns) {
            var idx = obj.previousHitByColumn[c];
            if (idx < 0) continue;
            var prev = objects[idx];
            if (defBigger(prev.endTime, end, 1) && defBigger(start, prev.startTime, 1)) {
                holdFactor = 1.25;
                break;
            }
        }
        return 2.0 * holdFactor;
    }
    static function evaluateOverall(obj:ManiaObj, objects:Array<ManiaObj>, totalColumns:Int):Float {
        var start = obj.startTime;
        var end = obj.endTime;
        var isOverlapping = false;
        var closestEndTime:Float = Math.abs(end - start);
        var holdFactor:Float = 1.0;
        for (c in 0...totalColumns) {
            var idx = obj.previousHitByColumn[c];
            if (idx < 0) continue;
            var prev = objects[idx];
            if (defBigger(prev.endTime, start, 1) && defBigger(end, prev.endTime, 1) && defBigger(start, prev.startTime, 1)) isOverlapping = true;
            if (defBigger(prev.endTime, end, 1) && defBigger(start, prev.startTime, 1)) holdFactor = 1.25;
            var diff = Math.abs(end - prev.endTime);
            if (diff < closestEndTime) closestEndTime = diff;
        }
        var holdAddition:Float = 0;
        if (isOverlapping) holdAddition = logistic(closestEndTime, 30, 0.27, 1);
        return (1 + holdAddition) * holdFactor;
    }
    static inline function logistic(x:Float, midpointOffset:Float, multiplier:Float, maxValue:Float = 1):Float {
        return maxValue / (1 + Math.exp(multiplier * (midpointOffset - x)));
    }
    static inline function defBigger(a:Float, b:Float, eps:Float):Bool {
        return a > b + eps;
    }
}

typedef ManiaObj = {
    var startTime:Float;
    var endTime:Float;
    var column:Int;
    var index:Int;
    var deltaTime:Float;
    var previousIndex:Int;
    var previousStart:Float;
    var previousHitByColumn:Array<Int>;
    var columnStrainTime:Float;
}