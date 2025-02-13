package backend;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.ArraySort;
import Math;

class DataFrame {
    private var data:Map<String, Array<Dynamic>>;

    public function new(data:Map<String, Array<Dynamic>>) {
        this.data = data;
    }

    public function print() {
        var columns = data.keys().toArray();
        var rows = data.values().toArray()[0].length;

        trace(columns.join("\t"));

        for (i in 0...rows) {
            var row = columns.map(function(col) return data.get(col)[i]);
            trace(row.join("\t"));
        }
    }
	
    public function mean(column:String):Float {
        var values = data.get(column);
        if (values == null) throw "Column not found: $column";

        var sum  =0.0;
        for (value in values) {
            if (Std.isOfType(value, Float)) {
                sum += value;
            } else {
                throw "Column $column is not numeric";
            }
        }
        return sum / values.length;
    }
	
    public function filter(column:String, value:Dynamic):DataFrame {
        var values = data.get(column);
        if (values == null) throw "Column not found: $column";

        var filteredData = new Map<String, Array<Dynamic>>();
        for (col in data.keys()) {
            filteredData.set(col, []);
        }

        for (i in 0...values.length) {
            if (values[i] == value) {
                for (col in data.keys()) {
                    filteredData.get(col).push(data.get(col)[i]);
                }
            }
        }

        return new DataFrame(filteredData);
    }

    public function setColumn(column:String, values:Array<Dynamic>) {
        if (values.length != data.values().toArray()[0].length) {
            throw "New column length does not match existing data length";
        }
        data.set(column, values);
    }
}


class Calculator {
    public static function calculate(jsonData:Dynamic, noteSeq:Array<Dynamic> = null, lambda2:Float = 7.0, lambda4:Float = 0.1, w0:Float = 0.4, w1:Float = 2.7, p1:Float = 1.5, w2:Float = 0.27, p0:Float = 1.0):Float {
        var lambdaN:Float = 5;
        var lambda1:Float = 0.11;
        var lambda3:Float = 24;
		
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

        // Preprocessing
        var noteSeqByColumn:Array<Array<Dynamic>> = [];
        for (column in noteDict) {
            if (column != null && column.hasOwnProperty("value")) {
                noteSeqByColumn.push(column.value);
            }
        }
        noteSeqByColumn.sort(function(a, b) {
            return a[0].k - b[0].k;
        });
        var LNSeq:Array<Dynamic> = [];
        for (t in noteSeq) {
            if (t.t >= 0) {
                LNSeq.push(t);
            }
        }
        LNSeq.sort(function(a, b) {
            return a.t - b.t;
        });

	var tail_seq = LNSeq;

        var LNDict:Map<Int, Array<Dynamic>> = new Map();
        for (value in LNSeq) {
            if (!LNDict.exists(value.k)) {
                LNDict.set(value.k, []);
            }
            LNDict.get(value.k).push(value);
        }

        var LNSeqByColumn:Array<Array<Dynamic>> = [];
        for (column in LNDict) {
            LNSeqByColumn.push(column.value);
        }
        LNSeqByColumn.sort(function(a, b) {
            return a[0].k - b[0].k;
        });

        var K:Int = 4;
        var T:Int = 1;
        for (s in noteSeq) {
            if (s.h > T) T = s.h + 1;
            if (s.t > T) T = s.t + 1;
        }

        // Hyperparameters and parameters

        // Helper functions
        function smooth(lst:Array<Float>):Array<Float> {
            var lstbar:Array<Float> = [];
            for (i in 0...T) lstbar.push(0);
            var windowSum:Float = 0;
            for (i in 0...Math.min(500, T)) windowSum += lst[i];
            for (s in 0...T) {
                lstbar[s] = 0.001 * windowSum;
                if (s + 500 < T) {
                    windowSum += lst[s + 500];
                }
                if (s - 500 >= 0) {
                    windowSum -= lst[s - 500];
                }
            }
            return lstbar;
        }

        function smooth2(lst:Array<Float>):Array<Float> {
            var lstbar:Array<Float> = [];
            for (i in 0...T) lstbar.push(0);
            var windowSum:Float = 0;
            var windowLen:Int = Math.min(500, T);
            for (i in 0...windowLen) windowSum += lst[i];
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

        var J_ks:Array<Array<Float>> = [];
        var delta_ks:Array<Array<Float>> = [];
        for (k in 0...K) {
            var J_k:Array<Float> = [];
            var delta_k:Array<Float> = [];
            for (s in 0...T) {
                J_k.push(0);
                delta_k.push(Math.pow(10, 9));
            }
            J_ks.push(J_k);
            delta_ks.push(delta_k);
        }

        for (k in 0...K) {
            for (i in 0...noteSeqByColumn[k].length - 1) {
                var delta:Float = 0.001 * (noteSeqByColumn[k][i + 1].h - noteSeqByColumn[k][i].h);
                var val:Float = Math.pow(delta, -1) * Math.pow(delta + lambda1 * Math.pow(x, 0.25), -1);
                for (s in noteSeqByColumn[k][i].h...noteSeqByColumn[k][i + 1].h) {
                    delta_ks[k][s] = delta;
                    J_ks[k][s] = val * jackNerfer(delta);
                }
            }
        }

        var Jbar_ks:Array<Array<Float>> = [];
        for (k in 0...K) {
            Jbar_ks.push(smooth(J_ks[k]));
        }

        var Jbar:Array<Float> = [];
        for (s in 0...T) {
            var Jbar_ks_vals:Array<Float> = [];
            var weights:Array<Float> = [];
            for (i in 0...K) {
                Jbar_ks_vals.push(Jbar_ks[i][s]);
                weights.push(1 / delta_ks[i][s]);
            }
            var weightedSum:Float = 0;
            var weightsSum:Float = 0;
            for (i in 0...Jbar_ks_vals.length) {
                weightedSum += Math.pow(Math.max(Jbar_ks_vals[i], 0), lambdaN) * weights[i];
                weightsSum += weights[i];
            }
            var weightedAvg:Float = Math.pow(weightedSum / Math.max(Math.pow(10, -9), weightsSum), 1 / lambdaN);
            Jbar.push(weightedAvg);
        }

        // Section 2.4
        var X_ks:Array<Array<Float>> = [];
	var notesInPair:Dynamic;
        for (k in 0...K + 1) {
            var X_k:Array<Float> = [];
            for (s in 0...T) X_k.push(0);
            if (k == 0) {
                notesInPair = noteSeqByColumn[0];
            } else if (k == K) {
                notesInPair = noteSeqByColumn[K - 1];
            } else {
                // Note: Haxe does not have a direct equivalent of heapq.merge. Sorting is handled differently.
                var notesInPair:Array<Dynamic> = noteSeqByColumn[k - 1].concat(noteSeqByColumn[k]);
                notesInPair.sort(function(a, b) {
                    return a.h - b.h;
                });
            }
            for (i in 1...notesInPair.length) {
                var delta:Float = 0.001 * (notesInPair[i].h - notesInPair[i - 1].h);
                var val:Float = 0.16 * Math.pow(Math.max(x, delta), -2);
                for (s in notesInPair[i - 1].h...notesInPair[i].h) {
                    X_k[s] = val;
                }
            }
            X_ks.push(X_k);
        }
        var cross_matrix:Array<Array<Float>> = [
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

        var X:Array<Float> = [];
        for (s in 0...T) {
            var sumVal:Float = 0;
            for (a in 0...X_ks.length) {
                sumVal += X_ks[a][s] * cross_matrix[K][a];
            }
            X.push(sumVal);
        }

        var Xbar:Array<Float> = smooth(X);

        // Section 2.5
        var P:Array<Float> = [];
        for (i in 0...T) P.push(0);
        var LN_bodies:Array<Float> = [];
        for (i in 0...T) LN_bodies.push(0);
        for (note in LNSeq) {
            var t1:Float = Math.min(note.h + 80, note.t);
            for (s in note.h...t1) {
                LN_bodies[s] += 0.5;
            }
            for (s in t1...note.t) {
                LN_bodies[s] += 1;
            }
        }

        function b(delta:Float):Float {
            var val:Float = 7.5 / delta;
            if (160 < val && val < 360) {
                return 1 + 1.4 * Math.pow(10, -7) * Math.pow((val - 160) * (val - 360), 2);
            }
            return 1;
        }

        for (i in 0...noteSeq.length - 1) {
            var delta:Float = 0.001 * (noteSeq[i + 1].h - noteSeq[i].h);
            if (delta < Math.pow(10, -9)) {
                P[noteSeq[i].h] += Math.pow(0.02 * (4 / x - lambda3), 0.25) * 1000;
            } else {
                var h_l:Int = noteSeq[i].h;
                var h_r:Int = noteSeq[i + 1].h;
                var v:Float = 1 + lambda2 * 0.001 * sumSlice(LN_bodies, h_l, h_r);
                if (delta < 2 * x / 3) {
                    for (s in h_l...h_r) {
                        P[s] += Math.pow(delta, -1) * Math.pow(0.08 * Math.pow(x, -1) * (1 - lambda3 * Math.pow(x, -1) * Math.pow(delta - x / 2, 2)), 0.25) * b(delta) * v;
                    }
                } else {
                    for (s in h_l...h_r) {
                        P[s] += Math.pow(delta, -1) * Math.pow(0.08 * Math.pow(x, -1) * (1 - lambda3 * Math.pow(x, -1) * Math.pow(x / 6, 2)), 0.25) * b(delta) * v;
                    }
                }
            }
        }

        var Pbar:Array<Float> = smooth(P);

        // Section 2.6
        // Local Key Usage by Column/Time
        var KU_ks:Array<Array<Bool>> = [];
        for (k in 0...K) {
            var KU_k:Array<Bool> = [];
            for (s in 0...T) KU_k.push(false);
            KU_ks.push(KU_k);
        }
        for (note in noteSeq) {
            var startTime:Int = Math.max(0, note.h - 500);
            var endTime:Int;
            if (note.t < 0) {
                endTime = Math.min(note.h + 500, T - 1);
            } else {
                endTime = Math.min(note.t + 500, T - 1);
            }
            for (s in startTime...endTime) {
                KU_ks[note.k][s] = true;
            }
        }

        // Local Key Usage by Time but as a list of column numbers for each point s in T
        var KU_s_cols:Array<Array<Int>> = [];
        for (s in 0...T) {
            var cols:Array<Int> = [];
            for (k in 0...K) {
                if (KU_ks[k][s]) {
                    cols.push(k);
                }
            }
            KU_s_cols.push(cols);
        }

        // The outer loop is no longer needed here as the columns come from KU_s_cols
        var dks:Array<Array<Float>> = [];
        for (k in 0...K - 1) {
            var dks_k:Array<Float> = [];
            for (s in 0...T) dks_k.push(0);
            dks.push(dks_k);
        }
        for (s in 0...T) {
            var cols = KU_s_cols[s];
            for (i in 0...cols.length - 1) {
                if (cols[i + 1] > K - 1) continue;
                dks[cols[i]][s] = Math.abs(delta_ks[cols[i]][s] - delta_ks[cols[i + 1]][s]) + Math.max(0, Math.max(delta_ks[cols[i + 1]][s], delta_ks[cols[i]][s]) - 0.3);
            }
        }

        var A:Array<Float> = [];
        for (i in 0...T) A.push(1);
        for (s in 0...T) {
            var cols = KU_s_cols[s];
            for (i in 0...cols.length - 1) {
                if (cols[i + 1] > K - 1) continue;
                if (dks[cols[i]][s] < 0.02) {
                    A[s] *= Math.min(0.75 + 0.5 * Math.max(delta_ks[cols[i + 1]][s], delta_ks[cols[i]][s]), 1);
                } else if (dks[cols[i]][s] < 0.07) {
                    A[s] *= Math.min(0.65 + 5 * dks[cols[i]][s] + 0.5 * Math.max(delta_ks[cols[i + 1]][s], delta_ks[cols[i]][s]), 1);
                } else {
                    // Do nothing
                }
            }
        }

        var Abar:Array<Float> = smooth2(A);

        // Section 2.7
        function find_next_note_in_column(note:Dynamic, noteSeqByColumn:Array<Array<Dynamic>>):Dynamic {
            var k:Int = note.k;
            var h:Int = note.h;
            var t:Int = note.t;
            var secondValues:Array<Int> = [];
            for (n in noteSeqByColumn[k]) {
                secondValues.push(n.h);
            }
            var index:Int = bisect_left(secondValues, h);
            if (index + 1 < noteSeqByColumn[k].length) {
                return noteSeqByColumn[k][index + 1];
            } else {
                return {k:0, h:Math.pow(10, 9), t:Math.pow(10, 9)};
            }
        }

        var I:Array<Float> = [];
        for (i in 0...LNSeq.length) I.push(0);
        for (i in 0...LNSeq.length) {
            var tail = tail_seq[i];
            var nextNote = find_next_note_in_column(tail, noteSeqByColumn);
            var I_h:Float = 0.001 * Math.abs(tail.t - tail.h - 80) / x;
            var I_t:Float = 0.001 * Math.abs(nextNote.h - tail.t - 80) / x;
            I[i] = 2 / (2 + Math.exp(-5 * (I_h - 0.75)) + Math.exp(-5 * (I_t - 0.75)));
        }

        var Is:Array<Float> = [];
        var R:Array<Float> = [];
        for (i in 0...T) {
            Is.push(0);
            R.push(0);
        }
        for (i in 0...tail_seq.length - 1) {
            var delta_r:Float = 0.001 * (tail_seq[i + 1].t - tail_seq[i].t);
            for (s in tail_seq[i].t...tail_seq[i + 1].t) {
                Is[s] = 1 + I[i];
                R[s] = 0.08 * Math.pow(delta_r, -0.5) * Math.pow(x, -1) * (1 + lambda4 * (I[i] + I[i + 1]));
            }
        }

        var Rbar:Array<Float> = smooth(R);

        // Section 3
        var C:Array<Int> = [];
        for (i in 0...T) C.push(0);
        var start:Int = 0;
        var end:Int = 0;
        for (t in 0...T) {
            while (start < noteSeq.length && noteSeq[start].h < t - 500) {
                start++;
            }
            while (end < noteSeq.length && noteSeq[end].h < t + 500) {
                end++;
            }
            C[t] = end - start;
        }

        // Local Key Usage as an integer for each point s in T (the number of columns used, minimum 1)
        var K_s:Array<Int> = [];
        for (s in 0...T) {
            var count:Int = 0;
            for (k in 0...K) {
                if (KU_ks[k][s]) count++;
            }
            K_s.push(Math.max(count, 1));
        }

        // Since Haxe does not have a built-in DataFrame like pandas, we use a custom structure or external library.
        // For simplicity, we will assume a DataFrame-like structure exists.
        var df = new DataFrame();
        df.setColumn("Jbar", Jbar);
        df.setColumn("Xbar", Xbar);
        df.setColumn("Pbar", Pbar);
        df.setColumn("Abar", Abar);
        df.setColumn("Rbar", Rbar);
        df.setColumn("C", C);
        df.setColumn("Ks", K_s);
        df.clipLower(0);

        df.setColumn("S", 
            Math.pow(
                (w0 * Math.pow(Math.pow(df.getColumn("Abar"), 3 / df.getColumn("Ks")) * df.getColumn("Jbar"), 1.5)) +
                ((1 - w0) * Math.pow(Math.pow(df.getColumn("Abar"), 2 / 3) * (0.8 * df.getColumn("Pbar") + df.getColumn("Rbar")), 1.5)),
                2 / 3
            )
        );
        df.setColumn("T", (Math.pow(df.getColumn("Abar"), 3 / df.getColumn("Ks")) * df.getColumn("Xbar")) / 
            (df.getColumn("Xbar") + df.getColumn("S") + 1));
        df.setColumn("D", w1 * Math.pow(df.getColumn("S"), 0.5) * Math.pow(df.getColumn("T"), p1) + df.getColumn("S") * w2);

        // Calculating SR
        var sumDlambdaN_C:Float = 0;
        var sumC:Float = 0;
        for (i in 0...T) {
            sumDlambdaN_C += Math.pow(df.get("D", i), lambdaN) * df.get("C", i);
            sumC += df.get("C", i);
        }
        var SR:Float = Math.pow(sumDlambdaN_C / Math.max(Math.pow(10, -9), sumC), 1 / lambdaN);
        SR = Math.pow(SR, p0) / Math.pow(8, p0) * 8;
        SR *= (noteSeq.length + 0.5 * LNSeq.length) / (noteSeq.length + 0.5 * LNSeq.length + 60);
        if (SR <= 2) {
            SR = Math.pow(SR * 2, 0.5);
        }
        SR *= (0.96 + 0.01 * K);

        // Visualization
        // Note: Haxe does not have a built-in plotting library like matplotlib. This section would require an external library.
        /*
        var plt = new Matplotlib();
        plt.figure(10, 6);
        // plt.plot(df.getColumn("Jbar"), label="Jbar", marker="o", linewidth=0.5, markersize=1, color="orange");
        // plt.plot(df.getColumn("Xbar"), label="Xbar", marker="o", linewidth=0.5, markersize=1, color="#3333FF");
        // plt.plot(df.getColumn("Pbar"), label="Pbar", marker="o", linewidth=0.5, markersize=1, color="green");
        // plt.plot(df.getColumn("Rbar"), label="Rbar", marker="o", linewidth=0.5, markersize=1, color="purple");
        // plt.plot(df.getColumn("S"), label="S", marker="o", linewidth=0.5, markersize=4);
        plt.plot(df.getColumn("D"), label="D", marker="o", linewidth=0.5, markersize=2, color="orange");
        plt.plot(df.getColumn("Ks"), label="Ks", marker="o", linewidth=0.5, markersize=2, color="red");

        var ax1 = plt.gca();
        var ax2 = ax1.twinx();
        ax2.plot(df.getColumn("Abar"), label="Abar (Right Axis)", color="r", marker="o", linewidth=0.5, markersize=1);
        // Set the limits for the secondary y-axis
        ax2.set_ylim(0, 1);

        // Adding titles and labels
        plt.title("Difficulty Plot");
        ax1.set_xlabel("Index");
        ax1.set_ylabel("Values");
        // ax2.set_ylabel("Values");

        // Combine legends and place outside the plot
        var lines1 = ax1.getLegendHandles();
        // var lines2 = ax2.getLegendHandles();
        // ax1.legend(lines1 + lines2, ["Jbar", "Xbar", "Pbar", "Rbar", "D", "Ks", "Abar (Right Axis)"], "upper_center", "bbox_to_anchor=(0.5, -0.15)", 5);

        // Adjust layout to make room for the legend
        plt.tight_layout("rect=(0, 0.03, 1, 0.95)");

        // Display the plot
        plt.show();
        */

        return SR;
    }

    static function sumSlice(arr:Array<Float>, start:Int, end:Int):Float {
        var sum:Float = 0;
        for (i in start...end) {
            sum += arr[i];
        }
        return sum;
    }

    static function bisect_left(arr:Array<Int>, x:Int):Int {
        var low:Int = 0;
        var high:Int = arr.length;
        while (low < high) {
            var mid:Int = (low + high) >>> 1;
            if (arr[mid] < x) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return low;
    }
}
