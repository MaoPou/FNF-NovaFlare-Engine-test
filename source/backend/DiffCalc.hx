package backend;

import haxe.ds.IntMap;
import haxe.ds.List;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import haxe.ds.ArraySort;
import haxe.Math;
import haxe.ds.GenericStack;
import haxe.ds.PriorityQueue;

class Main {
    public static function calculate(jsonData:Dynamic, noteSeq:Array<Dynamic> = [], lambda2:Float = 7.0, lambda4:Float = 0.1, w0:Float = 0.4, w1:Float = 2.7, p1:Float = 1.5, w2:Float = 0.27, p0:Float = 1.0):Float {
        var p = jsonData.notes.sectionNotes;
        
        var x = 0.3 * Math.pow((64.5 - Math.ceil(18)) / 500, 0.5);
        
        noteSeq.sort(function(a, b) {
            if (a.h == b.h) {
                return a.k - b.k;
            }
            return a.h - b.h;
        });

        var noteDict:Map<Int, Array<Dynamic>> = new Map();
        for (value in noteSeq) {
            if (!noteDict.exists(value.k)) {
                noteDict.set(value.k, []);
            }
            noteDict.get(value.k).push(value);
        }
        
        noteSeq.sort(function(a, b:(Int, Int, Int)):Int {
            if (a[1] != b[1]) return a[1] - b[1];
            return a[0] - b[0];
        });

        var noteDict:IntMap< Vector<(Int, Int, Int)> > = new IntMap();
        for (value in noteSeq) {
            if (!noteDict.exists(value[0])) {
                noteDict.set(value[0], new Vector());
            }
            noteDict.get(value[0]).push(value);
        }

        // Preprocessing
        var noteSeqByColumn:Array< Vector<(Int, Int, Int)> > = noteDict.toArray();
        noteSeqByColumn.sort(function(a, b:Vector<(Int, Int, Int)>):Int {
            return a[0][0] - b[0][0];
        });
        var LNSeq:Vector<(Int, Int, Int)> = new Vector();
        for (t in noteSeq) {
            if (t[2] >= 0) LNSeq.push(t);
        }
        LNSeq.sort(function(a, b:(Int, Int, Int)):Int {
            return a[2] - b[2];
        });

        var LNDict:IntMap< Vector<(Int, Int, Int)> > = new IntMap();
        for (value in LNSeq) {
            if (!LNDict.exists(value[0])) {
                LNDict.set(value[0], new Vector());
            }
            LNDict.get(value[0]).push(value);
        }

        var LNSeqByColumn:Array< Vector<(Int, Int, Int)> > = LNDict.toArray();
        LNSeqByColumn.sort(function(a, b:Vector<(Int, Int, Int)>):Int {
            return a[0][0] - b[0][0];
        });

        var K:Int = p[0];
        var T:Int = Math.max(
            haxe.ds.Vector.getMax(noteSeq.map(function(t:(Int, Int, Int)):Int { return t[1]; })),
            haxe.ds.Vector.getMax(noteSeq.map(function(t:(Int, Int, Int)):Int { return t[2]; }))
        ) + 1;

        // Helper functions
        function smooth(lst:Array<Float>):Array<Float> {
            var lstbar:Array<Float> = new Array();
            for (i in 0...T) lstbar.push(0);
            var windowSum:Float = 0;
            for (i in 0...Math.min(500, T)) windowSum += lst[i];
            for (s in 0...T) {
                lstbar[s] = 0.001 * windowSum;
                if (s + 500 < T) windowSum += lst[s + 500];
                if (s - 500 >= 0) windowSum -= lst[s - 500];
            }
            return lstbar;
        }

        function smooth2(lst:Array<Float>):Array<Float> {
            var lstbar:Array<Float> = new Array();
            for (i in 0...T) lstbar.push(0);
            var windowSum:Float = 0;
            var windowLen:Int = Math.min(500, T);
            for (i in 0...Math.min(500, T)) windowSum += lst[i];
            for (s in 0...T) {
                lstbar[s] = windowSum / windowLen;
                if (s + 500 < T) {
                    windowSum += lst[s + 500];
                    windowLen += 1;
                }
                if (s - 500 >= 0) {
                    windowSum -= lst[s - 500];
                    windowLen -= 1;
                }
            }
            return lstbar;
        }

        // Section 2.3
        function jackNerfer(delta:Float):Float {
            return 1 - 7 * Math.pow(10, -5) * Math.pow(0.15 + Math.abs(delta - 0.08), -4);
        }

        var JKs: Array< Array<Float> > = [];
        for (k in 0...K) {
            var inner: Array<Float> = [];
            for (s in 0...T) inner.push(0);
            JKs.push(inner);
        }

        var deltaKs: Array< Array<Float> > = [];
        for (k in 0...K) {
            var inner: Array<Float> = [];
            for (s in 0...T) inner.push(1e9);
            deltaKs.push(inner);
        }

        for (k in 0...K) {
            var column = noteSeqByColumn[k];
            for (i in 0...column.length - 1) {
                var delta:Float = 0.001 * (column[i + 1][1] - column[i][1]);
                var val:Float = Math.pow(delta, -1) * Math.pow(delta + lambda1 * Math.pow(x, 0.25), -1);
                var jnf:Float = jackNerfer(delta) * val;
                for (s in column[i][1] ... column[i + 1][1]) {
                    deltaKs[k][s] = delta;
                    JKs[k][s] = jnf;
                }
            }
        }

        var JbarKs: Array< Array<Float> > = [];
        for (k in 0...K) {
            JbarKs.push(smooth(JKs[k]));
        }

        var Jbar: Array<Float> = [];
        for (s in 0...T) {
            var JbarKsVals: Array<Float> = [];
            var weights: Array<Float> = [];
            for (i in 0...K) {
                JbarKsVals.push(JbarKs[i][s]);
                weights.push(1 / deltaKs[i][s]);
            }
            var weightedSum:Float = 0;
            var weightTotal:Float = 0;
            for (i in 0...JbarKsVals.length) {
                weightedSum += Math.pow(Math.max(JbarKsVals[i], 0), lambdaN) * weights[i];
                weightTotal += weights[i];
            }
            var weightedAvg:Float = Math.pow(weightedSum / Math.max(1e-9, weightTotal), 1 / lambdaN);
            Jbar.push(weightedAvg);
        }

        // Section 2.4
        var Xks: Array< Array<Float> > = [];
        for (k in 0...K + 1) {
            var inner: Array<Float> = [];
            for (s in 0...T) inner.push(0);
            Xks.push(inner);
        }

        for (k in 0...K + 1) {
            var notesInPair: Vector<(Int, Int, Int)> = if (k == 0) {
                noteSeqByColumn[0];
            } else if (k == K) {
                noteSeqByColumn[K - 1];
            } else {
                // Merge two sorted lists
                var merged = new Vector<(Int, Int, Int)>();
                var a = noteSeqByColumn[k - 1];
                var b = noteSeqByColumn[k];
                var i:Int = 0;
                var j:Int = 0;
                while (i < a.length && j < b.length) {
                    if (a[i][1] < b[j][1]) {
                        merged.push(a[i++]);
                    } else {
                        merged.push(b[j++]);
                    }
                }
                while (i < a.length) merged.push(a[i++]);
                while (j < b.length) merged.push(b[j++]);
                merged;
            };
            for (i in 1...notesInPair.length) {
                var delta:Float = 0.001 * (notesInPair[i][1] - notesInPair[i - 1][1]);
                var val:Float = 0.16 * Math.pow(Math.max(x, delta), -2);
                for (s in notesInPair[i - 1][1] ... notesInPair[i][1]) {
                    Xks[k][s] = val;
                }
            }
        }

        var crossMatrix: Array< Array<Float> > = [
            [-1],
            [0.075, 0.075],
            [0.125, 0.05, 0.125],
            [0.125, 0.125, 0.125, 0.125],
            [0.175, 0.25, 0.05, 0.25, 0.175],
            [0.175, 0.25, 0.175, 0.175, 0.25, 0.175],
            [0.225, 0.35, 0.25, 0.05, 0.25, 0.35, 0.225],
            [0.225, 0.35, 0.25, 0.225, 0.225, 0.25, 0.35, 0.225],
            [0.275, 0.45, 0.35, 0.25, 0.05, 0.25, 0.35, 0.45, 0.275],
            [0.275, 0.45, 0.35, 0.25, 0.275, 0.275, 0.25, 0.35, 0.45, 0.275],
            [0.325, 0.55, 0.45, 0.35, 0.25, 0.05, 0.25, 0.35, 0.45, 0.55, 0.325]
        ];

        var X: Array<Float> = [];
        for (s in 0...T) {
            var sumVal: Float = 0;
            for (k in 0...Xks.length) {
                sumVal += Xks[k][s] * crossMatrix[K][k];
            }
            X.push(sumVal);
        }

        var Xbar: Array<Float> = smooth(X);

        // Section 2.5
        var P: Array<Float> = [];
        for (i in 0...T) P.push(0);
        var LN_bodies: Array<Float> = new Array();
        for (i in 0...T) LN_bodies.push(0);
        for ((k, h, t) in LNSeq) {
            var t1:Int = Math.min(h + 80, t);
            for (s in h...t1) {
                LN_bodies[s] += 0.5;
            }
            for (s in t1...t) {
                LN_bodies[s] += 1;
            }
        }

        function b(delta:Float):Float {
            var val: Float = 7.5 / delta;
            if (160 < val && val < 360) {
                return 1 + 1.4 * Math.pow(10, -7) * (val - 160) * Math.pow(val - 360, 2);
            }
            return 1;
        }

        for (i in 0...noteSeq.length - 1) {
            var delta: Float = 0.001 * (noteSeq[i + 1][1] - noteSeq[i][1]);
            if (delta < 1e-9) {
                P[noteSeq[i][1]] += Math.pow(0.02 * (4 / x - lambda3), 0.25) * 1000;
            } else {
                var h_l:Int = noteSeq[i][1];
                var h_r:Int = noteSeq[i + 1][1];
                var v: Float = 1 + lambda2 * 0.001 * haxe.ds.Vector.sum(LN_bodies.slice(h_l, h_r));
                if (delta < 2 * x / 3) {
                    for (s in h_l...h_r) {
                        P[s] += Math.pow(0.08 * Math.pow(x, -1) * (1 - lambda3 * Math.pow(x, -1) * Math.pow(delta - x / 2, 2)), 0.25) * b(delta) * v / delta;
                    }
                } else {
                    for (s in h_l...h_r) {
                        P[s] += Math.pow(0.08 * Math.pow(x, -1) * (1 - lambda3 * Math.pow(x, -1) * Math.pow(x / 6, 2)), 0.25) * b(delta) * v / delta;
                    }
                }
            }
        }

        var Pbar: Array<Float> = smooth(P);

        // Section 2.6
        // Local Key Usage by Column/Time
        var KU_ks: Array< Array<Bool> > = [];
        for (k in 0...K) {
            var inner: Array<Bool> = [];
            for (s in 0...T) inner.push(false);
            KU_ks.push(inner);
        }
        for ((k, h, t) in noteSeq) {
            var startTime: Int = Math.max(0, h - 500);
            var endTime: Int;
            if (t < 0) {
                endTime = Math.min(h + 500, T - 1);
            } else {
                endTime = Math.min(t + 500, T - 1);
            }
            for (s in startTime...endTime) {
                KU_ks[k][s] = true;
            }
        }

        // Local Key Usage by Time but as a list of column numbers for each point s in T
        var KU_s_cols: Array< Array<Int> > = [];
        for (s in 0...T) {
            var cols: Array<Int> = [];
            for (k in 0...K) {
                if (KU_ks[k][s]) cols.push(k);
            }
            KU_s_cols.push(cols);
        }

        var dks: Array< Array<Float> > = [];
        for (k in 0...K - 1) {
            var inner: Array<Float> = [];
            for (s in 0...T) inner.push(0);
            dks.push(inner);
        }

        for (s in 0...T) {
            var cols: Array<Int> = KU_s_cols[s];
            for (i in 0...cols.length - 1) {
                if (cols[i + 1] > K - 1) continue;
                dks[cols[i]][s] = Math.abs(deltaKs[cols[i]][s] - deltaKs[cols[i + 1]][s]) + Math.max(0, Math.max(deltaKs[cols[i + 1]][s], deltaKs[cols[i]][s]) - 0.3);
            }
        }

        var A: Array<Float> = [];
        for (i in 0...T) A.push(1);
        for (s in 0...T) {
            var cols: Array<Int> = KU_s_cols[s];
            for (i in 0...cols.length - 1) {
                if (cols[i + 1] > K - 1) continue;
                if (dks[cols[i]][s] < 0.02) {
                    A[s] *= Math.min(0.75 + 0.5 * Math.max(deltaKs[cols[i + 1]][s], deltaKs[cols[i]][s]), 1);
                } else if (dks[cols[i]][s] < 0.07) {
                    A[s] *= Math.min(0.65 + 5 * dks[cols[i]][s] + 0.5 * Math.max(deltaKs[cols[i + 1]][s], deltaKs[cols[i]][s]), 1);
                } else {
                    // Do nothing
                }
            }
        }

        var Abar: Array<Float> = smooth2(A);

        // Section 2.7
        function findNextNoteInColumn(note:(Int, Int, Int), noteSeqByColumn:Array< Vector<(Int, Int, Int)> >): (Int, Int, Int) {
            var k = note[0];
            var h = note[1];
            var t = note[2];
            var secondValues: Array<Int> = noteSeqByColumn[k].map(function(n:(Int, Int, Int)):Int { return n[1]; });
            var index: Int = haxe.ds.ArrayTools.indexOf(secondValues, function(value:Int): Bool { return value >= h; });
            if (index + 1 < noteSeqByColumn[k].length) {
                return noteSeqByColumn[k][index + 1];
            }
            return (0, 1e9, 1e9);
        }

        var I: Array<Float> = [];
        for (i in 0...LNSeq.length) I.push(0);
        for (i in 0...LNSeq.length) {
            var (k, h_i, t_i) = tailSeq[i];
            var (k_next, h_j, t_j) = findNextNoteInColumn((k, h_i, t_i), noteSeqByColumn);
            var I_h: Float = 0.001 * Math.abs(t_i - h_i - 80) / x;
            var I_t: Float = 0.001 * Math.abs(h_j - t_i - 80) / x;
            I[i] = 2 / (2 + Math.exp(-5 * (I_h - 0.75)) + Math.exp(-5 * (I_t - 0.75)));
        }

        var Is: Array<Float> = [];
        var R: Array<Float> = [];
        for (i in 0...T) {
            Is.push(0);
            R.push(0);
        }
        for (i in 0...tailSeq.length - 1) {
            var delta_r: Float = 0.001 * (tailSeq[i + 1][2] - tailSeq[i][2]);
            for (s in tailSeq[i][2]...tailSeq[i + 1][2]) {
                Is[s] = 1 + I[i];
                R[s] = 0.08 * Math.pow(delta_r, -0.5) * Math.pow(x, -1) * (1 + lambda4 * (I[i] + I[i + 1]));
            }
        }

        var Rbar: Array<Float> = smooth(R);

        // Section 3
        var C: Array<Int> = [];
        for (i in 0...T) C.push(0);
        var start: Int = 0;
        var end_: Int = 0;
        for (t in 0...T) {
            while (start < noteSeq.length && noteSeq[start][1] < t - 500) {
                start += 1;
            }
            while (end_ < noteSeq.length && noteSeq[end_][1] < t + 500) {
                end_ += 1;
            }
            C[t] = end_ - start;
        }

        // Local Key Usage as an integer for each point s in T (the number of columns used, minimum 1)
        var K_s: Array<Int> = [];
        for (s in 0...T) {
            var count: Int = 0;
            for (k in 0...K) {
                if (KU_ks[k][s]) count += 1;
            }
            K_s.push(Math.max(count, 1));
        }

        // Assuming a DataFrame equivalent, using a custom class or a library
        var df = new DataFrame();
        df.setColumn("Jbar", Jbar);
        df.setColumn("Xbar", Xbar);
        df.setColumn("Pbar", Pbar);
        df.setColumn("Abar", Abar);
        df.setColumn("Rbar", Rbar);
        df.setColumn("C", C);
        df.setColumn("Ks", K_s);
        df.clipLower(0);

        df.setColumn("S", (function() {
            var s:Array<Float> = [];
            for (i in 0...T) {
                var part1 = Math.pow(w0 * Math.pow(Math.pow(df.get("Abar")[i], 3 / df.get("Ks")[i]) * df.get("Jbar")[i], 1.5), 2 / 3);
                var part2 = Math.pow((1 - w0) * Math.pow(Math.pow(df.get("Abar")[i], 2 / 3) * (0.8 * df.get("Pbar")[i] + df.get("Rbar")[i]), 1.5), 2 / 3);
                s.push(part1 + part2);
            }
            return s;
        })());

        df.setColumn("T", (function() {
            var t:Array<Float> = [];
            for (i in 0...T) {
                t.push(Math.pow(df.get("Abar")[i], 3 / df.get("Ks")[i]) * df.get("Xbar")[i] / (df.get("Xbar")[i] + df.get("S")[i] + 1));
            }
            return t;
        })());

        df.setColumn("D", (function() {
            var d:Array<Float> = [];
            for (i in 0...T) {
                d.push(w1 * Math.pow(df.get("S")[i], 0.5) * Math.pow(df.get("T")[i], p1) + df.get("S")[i] * w2);
            }
            return d;
        })());

        var SR: Float = Math.pow(haxe.ds.Vector.sum(df.get("D").map(function(dVal:Float, i:Int):Float { return Math.pow(dVal, lambdaN) * df.get("C")[i]; })) / haxe.ds.Vector.sum(df.get("C")), 1 / lambdaN);
        SR = Math.pow(SR, p0) / Math.pow(8, p0) * 8;
        SR *= (noteSeq.length + 0.5 * LNSeq.length) / (noteSeq.length + 0.5 * LNSeq.length + 60);
        if (SR <= 2) {
            SR = Math.pow(SR * 2, 0.5);
        }
        SR *= (0.96 + 0.01 * K);

        return SR;
    }
}
