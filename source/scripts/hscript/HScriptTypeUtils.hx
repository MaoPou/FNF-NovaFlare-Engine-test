package scripts.hscript;

import crowplexus.hscript.Tools;
import crowplexus.hscript.Expr;
import crowplexus.iris.Iris;

class HScriptTypeUtils {
  public static var enabled:Bool = false;

  public static function setEnabled(v:Bool):Void {
    enabled = v;
  }
  public static function collectImports(e: Expr): {names: Map<String, Bool>, packs: Map<String, Bool>} {
    var names = new Map<String, Bool>();
    var packs = new Map<String, Bool>();
    function visit(x: Expr): Void {
      switch (Tools.expr(x)) {
        case EImport(v, as, star):
          if (star) {
            packs.set(v, true);
            #if STAR_CLASSES
            if (Iris.starPackageClasses.exists(v)) {
              for (c in Iris.starPackageClasses.get(v)) {
                names.set(c.name, true);
              }
            }
            #end
          } else {
            var n = (as != null && StringTools.trim(as) != "" ? as : Tools.last(v.split(".")));
            names.set(n, true);
          }
        default:
      }
      Tools.iter(x, visit);
    }
    if (e != null) visit(e);
    return {names: names, packs: packs};
  }

  public static inline function isImportedType(tp: crowplexus.hscript.Expr.TypePath, imp: {names: Map<String, Bool>, packs: Map<String, Bool>}): Bool {
    var short = (tp.sub != null && tp.sub.length > 0 ? tp.sub : tp.name);
    var pack = (tp.pack != null && tp.pack.length > 0 ? tp.pack.join(".") : "");
    return imp.names.exists(short) || (pack != "" && imp.packs.exists(pack));
  }

  public static function detectTypes(e: Expr, imp: {names: Map<String, Bool>, packs: Map<String, Bool>}): Void {
    if (!enabled || e == null) return;
    switch (Tools.expr(e)) {
      case EVar(n, d, t, en, gt, st, c, ass):
        if (en != null) detectTypes(en, imp);
        var nt = t;
        switch (en == null ? null : Tools.expr(en)) {
          case ENew(cl, _):
            if (nt == null && isImportedType(cl, imp)) nt = CType.CTPath(cl);
          default:
        }
        if (nt != t) e.e = EVar(n, d, nt, en, gt, st, c, ass);
      case EFunction(args, body, depth, name, ret, access):
        var changed = false;
        var newArgs: Array<crowplexus.hscript.Expr.Argument> = null;
        if (args != null && args.length > 0) {
          newArgs = [];
          for (a in args) {
            var at = a.t;
            if (a.value != null) {
              detectTypes(a.value, imp);
              switch (Tools.expr(a.value)) {
                case ENew(cl, _):
                  if (at == null && isImportedType(cl, imp)) at = CType.CTPath(cl);
                default:
              }
            }
            if (at != a.t) changed = true;
            newArgs.push({name: a.name, t: at, opt: a.opt, value: a.value});
          }
        }
        if (body != null) detectTypes(body, imp);
        if (changed) e.e = EFunction(newArgs, body, depth, name, ret, access);
      case EParent(x):
        detectTypes(x, imp);
      case EBlock(el):
        for (x in el) detectTypes(x, imp);
      case EField(x, _, _):
        detectTypes(x, imp);
      case EBinop(_, e1, e2):
        detectTypes(e1, imp);
        detectTypes(e2, imp);
      case EUnop(_, _, x):
        detectTypes(x, imp);
      case ECall(f, args):
        detectTypes(f, imp);
        for (x in args) detectTypes(x, imp);
      case EIf(c, e1, e2):
        detectTypes(c, imp);
        detectTypes(e1, imp);
        if (e2 != null) detectTypes(e2, imp);
      case EWhile(c, b):
        detectTypes(c, imp);
        detectTypes(b, imp);
      case EDoWhile(c, b):
        detectTypes(c, imp);
        detectTypes(b, imp);
      case EFor(_, it, b):
        detectTypes(it, imp);
        detectTypes(b, imp);
      case EReturn(x):
        if (x != null) detectTypes(x, imp);
      case EArray(a, i):
        detectTypes(a, imp);
        detectTypes(i, imp);
      case EArrayDecl(el):
        for (x in el) detectTypes(x, imp);
      case ENew(_, el):
        for (x in el) detectTypes(x, imp);
      case EThrow(x):
        detectTypes(x, imp);
      case ETry(b, _, _, c):
        detectTypes(b, imp);
        detectTypes(c, imp);
      case EObject(fl):
        for (fi in fl) detectTypes(fi.e, imp);
      case ETernary(c, e1, e2):
        detectTypes(c, imp);
        detectTypes(e1, imp);
        detectTypes(e2, imp);
      case ESwitch(se, cases, def):
        detectTypes(se, imp);
        for (c in cases) {
          for (v in c.values) detectTypes(v, imp);
          detectTypes(c.expr, imp);
          if (c.ifExpr != null) detectTypes(c.ifExpr, imp);
        }
        if (def != null) detectTypes(def, imp);
      case EMeta(_, args, me):
        if (args != null) for (a in args) detectTypes(a, imp);
        detectTypes(me, imp);
      case ECheckType(x, _):
        detectTypes(x, imp);
      default:
    }
  }
}
